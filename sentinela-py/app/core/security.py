"""
Módulo de segurança: JWT, autenticação, MFA (TOTP), hashing de senhas.
"""

from datetime import datetime, timedelta
from typing import Optional
import pyotp
from passlib.context import CryptContext
from jose import JWTError, jwt

from app.core.config import settings


# Contexto para hashing de senhas com bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifica se a senha em texto plano corresponde ao hash armazenado.
    
    Args:
        plain_password: Senha em texto plano
        hashed_password: Hash da senha armazenada
        
    Returns:
        True se a senha corresponder, False caso contrário
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Gera hash bcrypt da senha.
    
    Args:
        password: Senha em texto plano
        
    Returns:
        Hash da senha
    """
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Cria token JWT de acesso.
    
    Args:
        data: Dados a serem codificados no token (ex: user_id, entidade_id)
        expires_delta: Tempo de expiração customizado
        
    Returns:
        Token JWT assinado
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    """
    Cria token JWT de refresh (longa duração).
    
    Args:
        data: Dados a serem codificados no token
        
    Returns:
        Refresh token JWT
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_token(token: str) -> Optional[dict]:
    """
    Decodifica e valida token JWT.
    
    Args:
        token: Token JWT a ser decodificado
        
    Returns:
        Payload do token ou None se inválido
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


# ==================== MFA/TOTP ====================

def generate_totp_secret() -> str:
    """
    Gera um secret base32 para TOTP (Google Authenticator, etc).
    
    Returns:
        Secret em formato base32
    """
    return pyotp.random_base32()


def get_totp_uri(secret: str, user_email: str) -> str:
    """
    Gera URI otpauth:// para configuração de MFA em apps autenticadores.
    
    Args:
        secret: Secret TOTP do usuário
        user_email: Email do usuário (usado como identificador)
        
    Returns:
        URI otpauth://
    """
    totp = pyotp.TOTP(secret)
    return totp.provisioning_uri(name=user_email, issuer_name=settings.MFA_ISSUER_NAME)


def verify_totp_code(secret: str, code: str) -> bool:
    """
    Verifica se o código TOTP fornecido pelo usuário está correto.
    
    Args:
        secret: Secret TOTP do usuário
        code: Código de 6 dígitos fornecido
        
    Returns:
        True se o código for válido, False caso contrário
    """
    totp = pyotp.TOTP(secret)
    return totp.verify(code, valid_window=1)  # valid_window=1 permite ±30s de margem
