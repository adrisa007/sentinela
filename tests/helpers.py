"""
Helpers para testes - adrisa007/sentinela (ID: 1112237272)
"""
import pyotp
import time
from jose import jwt
from app.core.config import settings


def generate_valid_totp(secret: str = None) -> str:
    """
    Gera um código TOTP válido para testes
    
    Args:
        secret: Secret do TOTP (se None, usa um padrão)
    
    Returns:
        str: Código TOTP válido de 6 dígitos
    """
    if secret is None:
        secret = "JBSWY3DPEHPK3PXP"  # Secret padrão para testes
    
    totp = pyotp.TOTP(secret)
    return totp.now()


def create_test_token_with_valid_totp(
    username: str,
    role: str = "ROOT",
    entidade_id: int = None,
    secret: str = None
) -> str:
    """
    Cria token JWT com TOTP válido para testes
    
    Args:
        username: Nome do usuário
        role: Role do usuário (ROOT, GESTOR, OPERADOR)
        entidade_id: ID da entidade (se aplicável)
        secret: Secret do TOTP
    
    Returns:
        str: Token JWT com TOTP válido
    """
    totp_code = generate_valid_totp(secret)
    
    payload = {
        "sub": username,
        "role": role,
        "totp": totp_code,
        "totp_validated": True,
        "exp": time.time() + 3600
    }
    
    if entidade_id:
        payload["entidade_id"] = entidade_id
    
    token = jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return token


def mock_totp_validation(monkeypatch):
    """
    Mock que sempre retorna True para validação TOTP
    Útil para testes que não dependem de MFA
    """
    def always_valid(*args, **kwargs):
        return True
    
    monkeypatch.setattr("pyotp.TOTP.verify", always_valid)
