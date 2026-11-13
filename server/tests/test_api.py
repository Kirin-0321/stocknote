import pytest
from fastapi.testclient import TestClient

from app import db, security
from app.config import Settings
from app.main import create_app


@pytest.fixture()
def client(tmp_path):
    s = Settings(db_path=str(tmp_path / "t.db"), jwt_secret="x" * 40, allow_registration=True,
                 access_ttl=3600, refresh_ttl=86400)
    app = create_app(s)
    c = TestClient(app)
    c.app_conn = app.state.conn
    return c


def register(c, email="a@test.dev", pw="password1"):
    r = c.post("/api/auth/register", json={"email": email, "password": pw, "device_name": "pc"})
    assert r.status_code == 200, r.text
    return r.json()


def auth(tokens):
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def make_admin(c, email="admin@test.dev", pw="adminpass1"):
    t = register(c, email, pw)
    with db.Tx(c.app_conn) as conn:
        conn.execute("UPDATE users SET role='admin' WHERE email=?", (email,))
    return c.post("/api/auth/login", json={"email": email, "password": pw}).json()


def row(i, updated, **extra):
    return {"id": i, "created_at": 1, "updated_at": updated, "deleted_at": None, "device_id": "d1", **extra}


def test_register_login_refresh_logout(client):
    t = register(client)
    assert t["user"]["email"] == "a@test.dev" and t["user"]["role"] == "user"
    assert client.post("/api/auth/register", json={"email": "A@test.dev", "password": "password1"}).status_code == 409
    assert client.post("/api/auth/register", json={"email": "b@test.dev", "password": "short"}).status_code == 400
    assert client.get("/api/me", headers=auth(t)).json()["email"] == "a@test.dev"
    assert client.get("/api/me").status_code == 401

    assert client.post("/api/auth/login", json={"email": "a@test.dev", "password": "wrong"}).status_code == 401
    t2 = client.post("/api/auth/login", json={"email": "a@test.dev", "password": "password1"}).json()

    r = client.post("/api/auth/refresh", json={"refresh_token": t2["refresh_token"]})
    assert r.status_code == 200
    # 刷新令牌轮换：旧的不能再用
    assert client.post("/api/auth/refresh", json={"refresh_token": t2["refresh_token"]}).status_code == 401
    new = r.json()
    client.post("/api/auth/logout", json={"refresh_token": new["refresh_token"]})
    assert client.post("/api/auth/refresh", json={"refresh_token": new["refresh_token"]}).status_code == 401


def test_password_stored_hashed_and_lockout(client):
    register(client)
    h = client.app_conn.execute("SELECT password_hash FROM users").fetchone()[0]
    assert h.startswith("$argon2") and "password1" not in h
    for _ in range(5):
        client.post("/api/auth/login", json={"email": "a@test.dev", "password": "nope"})
    r = client.post("/api/auth/login", json={"email": "a@test.dev", "password": "password1"})
    assert r.status_code == 429


def test_sync_push_pull_last_write_wins(client):
    t = register(client)
    h = auth(t)
    r = client.post("/api/sync/push", headers=h, json={"changes": [
        {"tbl": "journal_entries", "data": row("e1", 100, content="hello")},
        {"tbl": "trades", "data": row("t1", 100, qty=100)},
    ]})
    assert r.json() == {"applied": 2, "stale": 0, "same": 0}
    # 旧版本被拒，相同版本不重复写
    r = client.post("/api/sync/push", headers=h, json={"changes": [
        {"tbl": "journal_entries", "data": row("e1", 50, content="old")},
        {"tbl": "trades", "data": row("t1", 100, qty=100)},
    ]})
    assert r.json() == {"applied": 0, "stale": 1, "same": 1}

    p = client.get("/api/sync/pull?since=0", headers=h).json()
    assert [c["data"]["id"] for c in p["changes"]] == ["e1", "t1"]
    cursor = p["cursor"]
    assert client.get(f"/api/sync/pull?since={cursor}", headers=h).json()["changes"] == []

    client.post("/api/sync/push", headers=h, json={"changes": [
        {"tbl": "journal_entries", "data": row("e1", 200, content="new", deleted_at=None)}]})
    p = client.get(f"/api/sync/pull?since={cursor}", headers=h).json()
    assert p["changes"][0]["data"]["content"] == "new"

    # 不允许的表
    r = client.post("/api/sync/push", headers=h, json={"changes": [{"tbl": "users", "data": {"id": "x"}}]})
    assert r.status_code == 400


def test_pull_pagination_and_user_isolation(client):
    a, b = register(client, "a@test.dev"), register(client, "b@test.dev")
    client.post("/api/sync/push", headers=auth(a), json={"changes": [
        {"tbl": "journal_entries", "data": row(f"e{i}", 100 + i)} for i in range(5)]})
    p = client.get("/api/sync/pull?since=0&limit=2", headers=auth(a)).json()
    assert len(p["changes"]) == 2 and p["has_more"]
    assert client.get("/api/sync/pull?since=0", headers=auth(b)).json()["changes"] == []


def test_admin_requires_role_and_can_edit_user_data(client):
    u = register(client)
    client.post("/api/sync/push", headers=auth(u), json={"changes": [
        {"tbl": "journal_entries", "data": row("e1", 100, content="原文")}]})
    assert client.get("/api/admin/users", headers=auth(u)).status_code == 403

    adm = make_admin(client)
    ha = auth(adm)
    users = client.get("/api/admin/users", headers=ha).json()
    target = next(x for x in users if x["email"] == "a@test.dev")
    assert target["records"] == 1
    detail = client.get(f"/api/admin/users/{target['id']}", headers=ha).json()
    assert detail["tables"]["journal_entries"]["alive"] == 1

    recs = client.get(f"/api/admin/users/{target['id']}/records?tbl=journal_entries&q=原文", headers=ha).json()
    assert recs["total"] == 1
    rec = recs["items"][0]
    edited = client.put(f"/api/admin/users/{target['id']}/records/journal_entries/e1", headers=ha,
                        json={"data": {**rec["data"], "content": "管理员修改"}}).json()
    assert edited["data"]["content"] == "管理员修改"
    assert edited["updated_at"] > 100

    # 用户下次拉取能拿到管理员的修改
    p = client.get("/api/sync/pull?since=1", headers=auth(u)).json()
    assert p["changes"][-1]["data"]["content"] == "管理员修改"

    client.delete(f"/api/admin/users/{target['id']}/records/journal_entries/e1", headers=ha)
    assert client.get(f"/api/admin/users/{target['id']}/records?tbl=journal_entries", headers=ha).json()["total"] == 0
    client.post(f"/api/admin/users/{target['id']}/records/journal_entries/e1/restore", headers=ha)
    assert client.get(f"/api/admin/users/{target['id']}/records?tbl=journal_entries", headers=ha).json()["total"] == 1

    audit = client.get("/api/admin/audit", headers=ha).json()
    assert [a["action"] for a in audit][:3] == ["record.restore", "record.delete", "record.update"]


def test_admin_user_management(client):
    u = register(client)
    adm = make_admin(client)
    ha = auth(adm)
    uid = u["user"]["id"]
    r = client.patch(f"/api/admin/users/{uid}", headers=ha, json={"disabled": True})
    assert r.json()["disabled"] is True
    assert client.get("/api/me", headers=auth(u)).status_code == 401
    assert client.post("/api/auth/login", json={"email": "a@test.dev", "password": "password1"}).status_code == 403
    client.patch(f"/api/admin/users/{uid}", headers=ha, json={"disabled": False, "password": "resetpass1"})
    assert client.post("/api/auth/login", json={"email": "a@test.dev", "password": "resetpass1"}).status_code == 200
    # 不能取消自己的管理员
    assert client.patch(f"/api/admin/users/{adm['user']['id']}", headers=ha, json={"role": "user"}).status_code == 400


def test_registration_can_be_closed(tmp_path):
    s = Settings(db_path=str(tmp_path / "t.db"), jwt_secret="y" * 40, allow_registration=False,
                 access_ttl=60, refresh_ttl=60)
    c = TestClient(create_app(s))
    assert c.post("/api/auth/register", json={"email": "a@test.dev", "password": "password1"}).status_code == 403


def test_tokens():
    tok = security.create_access_token("s" * 40, "u1", "user", 60)
    assert security.decode_access_token("s" * 40, tok)["sub"] == "u1"
    assert security.decode_access_token("t" * 40, tok) is None
