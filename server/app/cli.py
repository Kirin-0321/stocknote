"""运维命令。密码只在终端交互输入，不出现在命令行参数或日志中。

  python -m app.cli create-admin you@example.com
  python -m app.cli set-password you@example.com
  python -m app.cli list-users
"""
import getpass
import os
import sys

from . import db, security


def _conn():
    conn = db.connect(os.environ.get("STOCKNOTE_DB", "stocknote.db"))
    db.init(conn)
    return conn


def _ask_password() -> str:
    while True:
        pw = getpass.getpass("新密码：")
        if err := security.validate_password(pw):
            print(err)
            continue
        if getpass.getpass("再输一次：") != pw:
            print("两次输入不一致")
            continue
        return pw


def create_admin(email: str):
    conn = _conn()
    email = email.strip().lower()
    u = conn.execute("SELECT * FROM users WHERE email=?", (email,)).fetchone()
    if u:
        with db.Tx(conn) as c:
            c.execute("UPDATE users SET role='admin', disabled=0 WHERE id=?", (u["id"],))
        print(f"已将 {email} 设为管理员（密码未改）")
        return
    pw = _ask_password()
    with db.Tx(conn) as c:
        c.execute(
            "INSERT INTO users(id, email, password_hash, display_name, role, created_at) VALUES(?,?,?,?,?,?)",
            (security.new_id(), email, security.hash_password(pw), "管理员", "admin", db.now_ms()),
        )
    print(f"已创建管理员 {email}")


def set_password(email: str):
    conn = _conn()
    u = conn.execute("SELECT * FROM users WHERE email=?", (email.strip().lower(),)).fetchone()
    if not u:
        sys.exit("用户不存在")
    pw = _ask_password()
    with db.Tx(conn) as c:
        c.execute("UPDATE users SET password_hash=? WHERE id=?", (security.hash_password(pw), u["id"]))
        c.execute("UPDATE refresh_tokens SET revoked=1 WHERE user_id=?", (u["id"],))
    print("密码已更新，该用户所有设备需重新登录")


def list_users():
    for u in _conn().execute("SELECT email, role, disabled, created_at FROM users ORDER BY created_at"):
        print(f"{u['email']:<32} {u['role']:<6} {'停用' if u['disabled'] else ''}")


if __name__ == "__main__":
    cmds = {"create-admin": create_admin, "set-password": set_password, "list-users": list_users}
    if len(sys.argv) < 2 or sys.argv[1] not in cmds:
        sys.exit(__doc__)
    cmds[sys.argv[1]](*sys.argv[2:])
