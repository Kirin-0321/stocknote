"""交易日记云同步 API。

- /api/auth/*   注册、登录、刷新令牌、退出
- /api/me       当前用户、修改密码
- /api/sync/*   增量推送 / 拉取（last-write-wins）
- /api/admin/*  管理员：用户管理、查看与修改任意用户的数据、审计日志
"""
import json
import sqlite3
import threading
import time
from typing import Any

from fastapi import Depends, FastAPI, Header, HTTPException, Query, Request
from pydantic import BaseModel, Field

from . import db, security
from .config import Settings, load

MAX_PUSH = 1000
MAX_PULL = 1000


class AuthIn(BaseModel):
    email: str = Field(min_length=3, max_length=254)
    password: str = Field(min_length=1, max_length=128)
    display_name: str | None = Field(default=None, max_length=64)
    device_name: str | None = Field(default=None, max_length=64)


class RefreshIn(BaseModel):
    refresh_token: str


class PasswordIn(BaseModel):
    old_password: str
    new_password: str


class Change(BaseModel):
    tbl: str
    data: dict[str, Any]


class PushIn(BaseModel):
    changes: list[Change]


class UserPatch(BaseModel):
    display_name: str | None = None
    role: str | None = None
    disabled: bool | None = None
    password: str | None = None


class RecordIn(BaseModel):
    data: dict[str, Any]


class _LoginLimiter:
    """同一邮箱连续失败 5 次后锁定 5 分钟。"""

    def __init__(self):
        self._fails: dict[str, tuple[int, float]] = {}
        self._lock = threading.Lock()

    def check(self, key: str):
        with self._lock:
            n, until = self._fails.get(key, (0, 0))
            if until > time.time():
                raise HTTPException(429, "失败次数过多，请 5 分钟后再试")

    def fail(self, key: str):
        with self._lock:
            n, _ = self._fails.get(key, (0, 0))
            n += 1
            self._fails[key] = (n, time.time() + 300 if n >= 5 else 0)

    def ok(self, key: str):
        with self._lock:
            self._fails.pop(key, None)


def _user_out(u: sqlite3.Row) -> dict:
    return {
        "id": u["id"],
        "email": u["email"],
        "display_name": u["display_name"],
        "role": u["role"],
        "disabled": bool(u["disabled"]),
        "created_at": u["created_at"],
        "last_login_at": u["last_login_at"],
        "last_sync_at": u["last_sync_at"],
    }


def _record_out(r: sqlite3.Row, with_user: bool = False) -> dict:
    out = {
        "tbl": r["tbl"],
        "id": r["id"],
        "data": json.loads(r["data"]),
        "updated_at": r["updated_at"],
        "deleted_at": r["deleted_at"],
        "seq": r["seq"],
    }
    if with_user:
        out["user_id"] = r["user_id"]
    return out


def create_app(settings: Settings | None = None) -> FastAPI:
    s = settings or load()
    conn = db.connect(s.db_path)
    db.init(conn)
    limiter = _LoginLimiter()
    app = FastAPI(title="StockNote Sync", docs_url=None, redoc_url=None, openapi_url=None)
    app.state.settings = s
    app.state.conn = conn

    # ───────────── 鉴权 ─────────────

    def current_user(authorization: str | None = Header(default=None)) -> sqlite3.Row:
        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(401, "未登录")
        claims = security.decode_access_token(s.jwt_secret, authorization[7:])
        if not claims:
            raise HTTPException(401, "登录已过期")
        u = conn.execute("SELECT * FROM users WHERE id=?", (claims["sub"],)).fetchone()
        if not u or u["disabled"]:
            raise HTTPException(401, "账户不可用")
        return u

    def admin_user(u: sqlite3.Row = Depends(current_user)) -> sqlite3.Row:
        if u["role"] != "admin":
            raise HTTPException(403, "需要管理员权限")
        return u

    def issue_tokens(u: sqlite3.Row, device_name: str | None) -> dict:
        token, token_hash = security.new_refresh_token()
        now = db.now_ms()
        with db.Tx(conn) as c:
            c.execute(
                "INSERT INTO refresh_tokens(id, user_id, token_hash, device_name, created_at, expires_at)"
                " VALUES(?,?,?,?,?,?)",
                (security.new_id(), u["id"], token_hash, device_name, now, now + s.refresh_ttl * 1000),
            )
        return {
            "access_token": security.create_access_token(s.jwt_secret, u["id"], u["role"], s.access_ttl),
            "refresh_token": token,
            "expires_in": s.access_ttl,
            "user": _user_out(u),
        }

    @app.get("/api/health")
    def health():
        return {"ok": True, "registration": s.allow_registration}

    @app.post("/api/auth/register")
    def register(body: AuthIn):
        if not s.allow_registration:
            raise HTTPException(403, "暂未开放注册")
        email = body.email.strip().lower()
        if "@" not in email:
            raise HTTPException(400, "邮箱格式不正确")
        if err := security.validate_password(body.password):
            raise HTTPException(400, err)
        uid = security.new_id()
        try:
            with db.Tx(conn) as c:
                c.execute(
                    "INSERT INTO users(id, email, password_hash, display_name, created_at, last_login_at)"
                    " VALUES(?,?,?,?,?,?)",
                    (uid, email, security.hash_password(body.password), body.display_name, db.now_ms(), db.now_ms()),
                )
        except sqlite3.IntegrityError:
            raise HTTPException(409, "该邮箱已注册")
        u = conn.execute("SELECT * FROM users WHERE id=?", (uid,)).fetchone()
        return issue_tokens(u, body.device_name)

    @app.post("/api/auth/login")
    def login(body: AuthIn):
        email = body.email.strip().lower()
        limiter.check(email)
        u = conn.execute("SELECT * FROM users WHERE email=?", (email,)).fetchone()
        if not u or not security.verify_password(u["password_hash"], body.password):
            limiter.fail(email)
            raise HTTPException(401, "邮箱或密码错误")
        if u["disabled"]:
            raise HTTPException(403, "账户已被停用")
        limiter.ok(email)
        with db.Tx(conn) as c:
            c.execute("UPDATE users SET last_login_at=? WHERE id=?", (db.now_ms(), u["id"]))
        return issue_tokens(u, body.device_name)

    @app.post("/api/auth/refresh")
    def refresh(body: RefreshIn):
        h = security.hash_token(body.refresh_token)
        t = conn.execute("SELECT * FROM refresh_tokens WHERE token_hash=?", (h,)).fetchone()
        if not t or t["revoked"] or t["expires_at"] < db.now_ms():
            raise HTTPException(401, "登录已过期，请重新登录")
        u = conn.execute("SELECT * FROM users WHERE id=?", (t["user_id"],)).fetchone()
        if not u or u["disabled"]:
            raise HTTPException(401, "账户不可用")
        # 轮换：旧令牌作废
        with db.Tx(conn) as c:
            c.execute("UPDATE refresh_tokens SET revoked=1 WHERE id=?", (t["id"],))
        return issue_tokens(u, t["device_name"])

    @app.post("/api/auth/logout")
    def logout(body: RefreshIn):
        with db.Tx(conn) as c:
            c.execute("UPDATE refresh_tokens SET revoked=1 WHERE token_hash=?", (security.hash_token(body.refresh_token),))
        return {"ok": True}

    @app.get("/api/me")
    def me(u=Depends(current_user)):
        return _user_out(u)

    @app.post("/api/me/password")
    def change_password(body: PasswordIn, u=Depends(current_user)):
        if not security.verify_password(u["password_hash"], body.old_password):
            raise HTTPException(400, "原密码错误")
        if err := security.validate_password(body.new_password):
            raise HTTPException(400, err)
        with db.Tx(conn) as c:
            c.execute("UPDATE users SET password_hash=? WHERE id=?", (security.hash_password(body.new_password), u["id"]))
            c.execute("UPDATE refresh_tokens SET revoked=1 WHERE user_id=?", (u["id"],))
        return {"ok": True}

    # ───────────── 同步 ─────────────

    @app.post("/api/sync/push")
    def push(body: PushIn, u=Depends(current_user)):
        if len(body.changes) > MAX_PUSH:
            raise HTTPException(413, f"单次最多 {MAX_PUSH} 条")
        applied = stale = same = 0
        with db.Tx(conn) as c:
            for ch in body.changes:
                if ch.tbl not in db.SYNC_TABLES or "id" not in ch.data:
                    raise HTTPException(400, f"不支持的表或缺少 id：{ch.tbl}")
                r = db.upsert_record(c, u["id"], ch.tbl, ch.data)
                applied += r == "applied"
                stale += r == "stale"
                same += r == "same"
            c.execute("UPDATE users SET last_sync_at=? WHERE id=?", (db.now_ms(), u["id"]))
        return {"applied": applied, "stale": stale, "same": same}

    @app.get("/api/sync/pull")
    def pull(since: int = 0, limit: int = Query(500, ge=1, le=MAX_PULL), u=Depends(current_user)):
        rows = conn.execute(
            "SELECT * FROM records WHERE user_id=? AND seq>? ORDER BY seq LIMIT ?", (u["id"], since, limit + 1)
        ).fetchall()
        more = len(rows) > limit
        rows = rows[:limit]
        return {
            "changes": [{"tbl": r["tbl"], "data": json.loads(r["data"])} for r in rows],
            "cursor": rows[-1]["seq"] if rows else since,
            "has_more": more,
        }

    # ───────────── 管理员 ─────────────

    @app.get("/api/admin/stats")
    def admin_stats(_=Depends(admin_user)):
        users = conn.execute("SELECT COUNT(*) n FROM users").fetchone()["n"]
        per_tbl = conn.execute(
            "SELECT tbl, COUNT(*) n FROM records WHERE deleted_at IS NULL GROUP BY tbl ORDER BY n DESC"
        ).fetchall()
        active = conn.execute(
            "SELECT COUNT(*) n FROM users WHERE last_sync_at > ?", (db.now_ms() - 7 * 86400_000,)
        ).fetchone()["n"]
        return {"users": users, "active_7d": active, "tables": {r["tbl"]: r["n"] for r in per_tbl}}

    @app.get("/api/admin/users")
    def admin_users(q: str = "", _=Depends(admin_user)):
        rows = conn.execute(
            "SELECT u.*, (SELECT COUNT(*) FROM records r WHERE r.user_id=u.id AND r.deleted_at IS NULL) AS n"
            " FROM users u WHERE u.email LIKE ? OR IFNULL(u.display_name,'') LIKE ? ORDER BY u.created_at DESC",
            (f"%{q}%", f"%{q}%"),
        ).fetchall()
        return [{**_user_out(r), "records": r["n"]} for r in rows]

    def _get_user(uid: str) -> sqlite3.Row:
        u = conn.execute("SELECT * FROM users WHERE id=?", (uid,)).fetchone()
        if not u:
            raise HTTPException(404, "用户不存在")
        return u

    @app.get("/api/admin/users/{uid}")
    def admin_user_detail(uid: str, _=Depends(admin_user)):
        u = _get_user(uid)
        tables = conn.execute(
            "SELECT tbl, SUM(deleted_at IS NULL) alive, SUM(deleted_at IS NOT NULL) deleted, MAX(updated_at) last"
            " FROM records WHERE user_id=? GROUP BY tbl",
            (uid,),
        ).fetchall()
        return {**_user_out(u), "tables": {r["tbl"]: dict(r) for r in tables}}

    @app.patch("/api/admin/users/{uid}")
    def admin_patch_user(uid: str, body: UserPatch, admin=Depends(admin_user)):
        u = _get_user(uid)
        changes: dict[str, Any] = {}
        if body.display_name is not None:
            changes["display_name"] = body.display_name
        if body.role is not None:
            if body.role not in ("user", "admin"):
                raise HTTPException(400, "角色只能是 user 或 admin")
            if uid == admin["id"] and body.role != "admin":
                raise HTTPException(400, "不能取消自己的管理员权限")
            changes["role"] = body.role
        if body.disabled is not None:
            if uid == admin["id"] and body.disabled:
                raise HTTPException(400, "不能停用自己")
            changes["disabled"] = int(body.disabled)
        with db.Tx(conn) as c:
            for k, v in changes.items():
                c.execute(f"UPDATE users SET {k}=? WHERE id=?", (v, uid))
            if body.password:
                if err := security.validate_password(body.password):
                    raise HTTPException(400, err)
                c.execute("UPDATE users SET password_hash=? WHERE id=?", (security.hash_password(body.password), uid))
                c.execute("UPDATE refresh_tokens SET revoked=1 WHERE user_id=?", (uid,))
                changes["password"] = "(已重置)"
            if body.disabled:
                c.execute("UPDATE refresh_tokens SET revoked=1 WHERE user_id=?", (uid,))
            db.audit(c, admin["id"], "user.update", target_user=uid, before=_user_out(u), after=changes)
        return _user_out(_get_user(uid))

    @app.get("/api/admin/users/{uid}/records")
    def admin_records(
        uid: str,
        tbl: str,
        q: str = "",
        include_deleted: bool = False,
        offset: int = Query(0, ge=0),
        limit: int = Query(50, ge=1, le=500),
        _=Depends(admin_user),
    ):
        if tbl not in db.SYNC_TABLES:
            raise HTTPException(400, "不支持的表")
        where = "user_id=? AND tbl=?" + ("" if include_deleted else " AND deleted_at IS NULL")
        args: list[Any] = [uid, tbl]
        if q:
            where += " AND data LIKE ?"
            args.append(f"%{q}%")
        total = conn.execute(f"SELECT COUNT(*) n FROM records WHERE {where}", args).fetchone()["n"]
        rows = conn.execute(
            f"SELECT * FROM records WHERE {where} ORDER BY updated_at DESC LIMIT ? OFFSET ?", [*args, limit, offset]
        ).fetchall()
        return {"total": total, "items": [_record_out(r) for r in rows]}

    def _get_record(uid: str, tbl: str, rid: str) -> sqlite3.Row:
        r = conn.execute("SELECT * FROM records WHERE user_id=? AND tbl=? AND id=?", (uid, tbl, rid)).fetchone()
        if not r:
            raise HTTPException(404, "记录不存在")
        return r

    @app.put("/api/admin/users/{uid}/records/{tbl}/{rid}")
    def admin_put_record(uid: str, tbl: str, rid: str, body: RecordIn, admin=Depends(admin_user)):
        """管理员修改：更新 updated_at 使客户端下次同步时拉到并覆盖本地。"""
        if tbl not in db.SYNC_TABLES:
            raise HTTPException(400, "不支持的表")
        before = _get_record(uid, tbl, rid)
        data = {**body.data, "id": rid, "updated_at": max(db.now_ms(), before["updated_at"] + 1)}
        with db.Tx(conn) as c:
            db.upsert_record(c, uid, tbl, data, force=True)
            db.audit(c, admin["id"], "record.update", target_user=uid, tbl=tbl, record_id=rid,
                     before=json.loads(before["data"]), after=data)
        return _record_out(_get_record(uid, tbl, rid))

    @app.delete("/api/admin/users/{uid}/records/{tbl}/{rid}")
    def admin_delete_record(uid: str, tbl: str, rid: str, admin=Depends(admin_user)):
        """软删除（与 App 一致），可恢复。"""
        before = _get_record(uid, tbl, rid)
        now = max(db.now_ms(), before["updated_at"] + 1)
        data = {**json.loads(before["data"]), "deleted_at": now, "updated_at": now}
        with db.Tx(conn) as c:
            db.upsert_record(c, uid, tbl, data, force=True)
            db.audit(c, admin["id"], "record.delete", target_user=uid, tbl=tbl, record_id=rid)
        return _record_out(_get_record(uid, tbl, rid))

    @app.post("/api/admin/users/{uid}/records/{tbl}/{rid}/restore")
    def admin_restore_record(uid: str, tbl: str, rid: str, admin=Depends(admin_user)):
        before = _get_record(uid, tbl, rid)
        now = max(db.now_ms(), before["updated_at"] + 1)
        data = {**json.loads(before["data"]), "deleted_at": None, "updated_at": now}
        with db.Tx(conn) as c:
            db.upsert_record(c, uid, tbl, data, force=True)
            db.audit(c, admin["id"], "record.restore", target_user=uid, tbl=tbl, record_id=rid)
        return _record_out(_get_record(uid, tbl, rid))

    @app.get("/api/admin/audit")
    def admin_audit(limit: int = Query(100, ge=1, le=500), _=Depends(admin_user)):
        rows = conn.execute(
            "SELECT a.*, u.email AS actor_email, t.email AS target_email FROM audit_log a"
            " LEFT JOIN users u ON u.id=a.actor_id LEFT JOIN users t ON t.id=a.target_user"
            " ORDER BY a.id DESC LIMIT ?",
            (limit,),
        ).fetchall()
        return [dict(r) for r in rows]

    @app.exception_handler(sqlite3.Error)
    def _db_error(_: Request, exc: sqlite3.Error):
        from fastapi.responses import JSONResponse

        return JSONResponse({"detail": "数据库错误"}, status_code=500)

    return app
# 运行：uvicorn app.main:create_app --factory
