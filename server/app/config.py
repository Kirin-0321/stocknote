"""服务器配置：全部来自环境变量（部署时写在 /etc/stocknote/stocknote.env）。"""
import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    db_path: str
    jwt_secret: str
    allow_registration: bool
    access_ttl: int  # 秒
    refresh_ttl: int  # 秒


def load() -> Settings:
    secret = os.environ.get("STOCKNOTE_JWT_SECRET", "")
    if len(secret) < 32:
        # 开发 / 测试环境未配置时用临时密钥（重启后所有登录失效）
        secret = os.urandom(32).hex()
    return Settings(
        db_path=os.environ.get("STOCKNOTE_DB", "stocknote.db"),
        jwt_secret=secret,
        allow_registration=os.environ.get("STOCKNOTE_ALLOW_REGISTRATION", "true").lower() == "true",
        access_ttl=int(os.environ.get("STOCKNOTE_ACCESS_TTL", "3600")),
        refresh_ttl=int(os.environ.get("STOCKNOTE_REFRESH_TTL", str(60 * 86400))),
    )
