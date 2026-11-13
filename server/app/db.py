"""SQLite 存储。

同步数据以通用形式保存：records(user_id, tbl, id) → 客户端该行的全部列（JSON），
每次写入分配全局递增的 seq，客户端按 seq 增量拉取。
"""
import json
import sqlite3
import threading
import time

# 参与同步的表（与 App 的 drift 表名一致）
SYNC_TABLES = {
    "journal_entries",
    "market_snapshots",
    "quick_phrases",
    "entry_templates",
    "predictions",
    "prediction_results",
    "review_notes",
    "threshold_rules",
    "revisions",
    "ai_analyses",
    "accounts",
    "trades",
    "position_snapshots",
    "import_batches",
    "column_mappings",
    "agent_threads",
    "agent_messages",
    "agent_memories",
}

SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE COLLATE NOCASE,
  password_hash TEXT NOT NULL,
  display_name TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  disabled INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  last_login_at INTEGER,
  last_sync_at INTEGER
);
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  token_hash TEXT NOT NULL UNIQUE,
  device_name TEXT,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  revoked INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS records (
  user_id TEXT NOT NULL,
  tbl TEXT NOT NULL,
  id TEXT NOT NULL,
  data TEXT NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  device_id TEXT,
  seq INTEGER NOT NULL,
  PRIMARY KEY (user_id, tbl, id)
);
CREATE INDEX IF NOT EXISTS records_user_seq ON records(user_id, seq);
CREATE INDEX IF NOT EXISTS records_user_tbl ON records(user_id, tbl, updated_at);
CREATE TABLE IF NOT EXISTS audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  actor_id TEXT NOT NULL,
  action TEXT NOT NULL,
  target_user TEXT,
  tbl TEXT,
  record_id TEXT,
  before TEXT,
  after TEXT
);
CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
"""

_write_lock = threading.Lock()


def now_ms() -> int:
    return int(time.time() * 1000)


def connect(path: str) -> sqlite3.Connection:
    conn = sqlite3.connect(path, check_same_thread=False, isolation_level=None)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA busy_timeout=5000")
    return conn


def init(conn: sqlite3.Connection) -> None:
    conn.executescript(SCHEMA)


class Tx:
    """串行写事务（SQLite 单写者），保证 seq 分配不冲突。"""

    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def __enter__(self):
        _write_lock.acquire()
        self.conn.execute("BEGIN IMMEDIATE")
        return self.conn

    def __exit__(self, exc_type, exc, tb):
        try:
            self.conn.execute("ROLLBACK" if exc_type else "COMMIT")
        finally:
            _write_lock.release()


def next_seq(conn: sqlite3.Connection) -> int:
    row = conn.execute("SELECT value FROM meta WHERE key='seq'").fetchone()
    seq = (int(row["value"]) if row else 0) + 1
    conn.execute(
        "INSERT INTO meta(key, value) VALUES('seq', ?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
        (str(seq),),
    )
    return seq


def upsert_record(conn, user_id: str, tbl: str, data: dict, *, force: bool = False) -> str:
    """写入一行。last-write-wins：updated_at 不比服务器新则不写（force 时管理员覆盖）。

    返回 'applied' | 'stale' | 'same'。
    """
    rid = str(data["id"])
    updated_at = int(data.get("updated_at") or 0)
    existing = conn.execute(
        "SELECT updated_at FROM records WHERE user_id=? AND tbl=? AND id=?", (user_id, tbl, rid)
    ).fetchone()
    if existing and not force:
        if updated_at < existing["updated_at"]:
            return "stale"
        if updated_at == existing["updated_at"]:
            return "same"
    conn.execute(
        """INSERT INTO records(user_id, tbl, id, data, updated_at, deleted_at, device_id, seq)
           VALUES(?,?,?,?,?,?,?,?)
           ON CONFLICT(user_id, tbl, id) DO UPDATE SET
             data=excluded.data, updated_at=excluded.updated_at, deleted_at=excluded.deleted_at,
             device_id=excluded.device_id, seq=excluded.seq""",
        (
            user_id,
            tbl,
            rid,
            json.dumps(data, ensure_ascii=False),
            updated_at,
            data.get("deleted_at"),
            data.get("device_id"),
            next_seq(conn),
        ),
    )
    return "applied"


def audit(conn, actor: str, action: str, *, target_user=None, tbl=None, record_id=None, before=None, after=None):
    conn.execute(
        "INSERT INTO audit_log(ts, actor_id, action, target_user, tbl, record_id, before, after)"
        " VALUES(?,?,?,?,?,?,?,?)",
        (
            now_ms(),
            actor,
            action,
            target_user,
            tbl,
            record_id,
            None if before is None else json.dumps(before, ensure_ascii=False),
            None if after is None else json.dumps(after, ensure_ascii=False),
        ),
    )
