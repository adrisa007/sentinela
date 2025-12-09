from datetime import datetime, timedelta
from typing import Optional, List
from jose import JWTError, jwt
from passlib.context import CryptContext
import pyotp
import qrcode
from io import BytesIO
import base64
import secrets

from app.core.config import settings
from app.core.models import User

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=settings.BCRYPT_ROUNDS)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Cria token JWT com dados fornecidos
    
    Args:
        data: Dados a serem codificados (sub deve ser int ou str)
        expires_delta: Tempo de expiração customizado
        
    Returns:
        str: Token JWT codificado
    """
    to_encode = data.copy()
    
    # CORREÇÃO: Garantir que 'sub' seja string (JWT RFC 7519)
    if "sub" in to_encode:
        to_encode["sub"] = str(to_encode["sub"])
    
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire, "iat": datetime.utcnow(), "iss": settings.APP_NAME})
    
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def generate_mfa_secret() -> str:
    return pyotp.random_base32()


def generate_qr_code(user_email: str, secret: str) -> str:
    totp_uri = pyotp.totp.TOTP(secret).provisioning_uri(name=user_email, issuer_name=settings.APP_NAME)
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(totp_uri)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    buffer.seek(0)
    return f"data:image/png;base64,{base64.b64encode(buffer.getvalue()).decode()}"


def verify_totp(secret: str, token: str) -> bool:
    try:
        return pyotp.TOTP(secret).verify(token, valid_window=settings.MFA_WINDOW)
    except:
        return False


def generate_backup_codes(count: int = 10) -> List[str]:
    codes = []
    for _ in range(count):
        code = secrets.token_hex(4).upper()
        codes.append(f"{code[:4]}-{code[4:]}")
    return codes


def authenticate_user(db, username: str, password: str) -> Optional[User]:
    from app.core.models import User
    user = db.query(User).filter(User.username == username).first()
    if not user or not user.is_active or not verify_password(password, user.hashed_password):
        return None
    return user


def update_last_login(db, user_id: int):
    from app.core.models import User
    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.last_login = datetime.utcnow()
        db.commit()
