"""密码哈希（Argon2）、JWT 访问令牌与轮换的刷新令牌。"""
import hashlib
import secrets
import time
import uuid

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError, VerifyMismatchError

_ph = PasswordHasher()


def hash_password(pw: str) -> str:
    return _ph.hash(pw)


def verify_password(hashed: str, pw: str) -> bool:
    try:
        return _ph.verify(hashed, pw)
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def create_access_token(secret: str, user_id: str, role: str, ttl: int) -> str:
    now = int(time.time())
    return jwt.encode(
        {"sub": user_id, "role": role, "iat": now, "exp": now + ttl, "typ": "access"}, secret, "HS256"
    )


def decode_access_token(secret: str, token: str) -> dict | None:
    try:
        claims = jwt.decode(token, secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        return None
    return claims if claims.get("typ") == "access" else None


def new_refresh_token() -> tuple[str, str]:
    """返回 (明文令牌, 哈希)。服务器只保存哈希。"""
    token = secrets.token_urlsafe(48)
    return token, hash_token(token)


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def new_id() -> str:
    return str(uuid.uuid4())


def validate_password(pw: str) -> str | None:
    if len(pw) < 8:
        return "密码至少 8 位"
    if len(pw) > 128:
        return "密码过长"
    return None
