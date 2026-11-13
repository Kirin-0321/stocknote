"""每日备份同步数据库（SQLite 在线备份），保留最近 14 份。"""
import datetime
import pathlib
import sqlite3

SRC = "/var/lib/stocknote/stocknote.db"
DIR = pathlib.Path("/var/lib/stocknote/backups")
KEEP = 14

DIR.mkdir(parents=True, exist_ok=True)
dest = DIR / f"stocknote-{datetime.date.today():%Y%m%d}.db"
with sqlite3.connect(SRC) as src, sqlite3.connect(dest) as dst:
    src.backup(dst)
for old in sorted(DIR.glob("stocknote-*.db"))[:-KEEP]:
    old.unlink()
