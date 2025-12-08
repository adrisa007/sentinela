"""
Rotas de autenticação: login, registro, MFA, refresh token.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel.ext.asyncio.session import AsyncSession

from app.core.dependencies import get_db
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    generate_totp_secret,
    get_totp_uri,
    verify_totp_code,
)


router = APIRouter()


@router.post("/register")
async def register(db: AsyncSession = Depends(get_db)):
    """
    Registra um novo usuário no sistema.
    
    TODO: Implementar criação de usuário com validação de email.
    """
    return {"message": "Registro de usuário - a implementar"}


@router.post("/login")
async def login(db: AsyncSession = Depends(get_db)):
    """
    Autentica usuário e retorna tokens JWT.
    
    Fluxo:
    1. Valida credenciais (email + senha)
    2. Verifica se MFA está habilitado
    3. Se MFA ativo, requer código TOTP
    4. Retorna access_token e refresh_token
    
    TODO: Implementar validação completa de credenciais.
    """
    return {
        "access_token": "token_aqui",
        "refresh_token": "refresh_token_aqui",
        "token_type": "bearer"
    }


@router.post("/refresh")
async def refresh_token():
    """
    Renova access token usando refresh token válido.
    
    TODO: Implementar validação de refresh token e geração de novo access token.
    """
    return {"access_token": "novo_token_aqui", "token_type": "bearer"}


@router.post("/mfa/enable")
async def enable_mfa():
    """
    Habilita autenticação de dois fatores (MFA/TOTP) para o usuário.
    
    Retorna:
        - secret: Secret base32 para configurar no app autenticador
        - qr_code_uri: URI otpauth:// para gerar QR Code
    
    TODO: Implementar persistência do secret e validação inicial.
    """
    secret = generate_totp_secret()
    uri = get_totp_uri(secret, "user@example.com")
    
    return {
        "secret": secret,
        "qr_code_uri": uri,
        "message": "Escaneie o QR Code com Google Authenticator ou similar"
    }


@router.post("/mfa/verify")
async def verify_mfa():
    """
    Verifica código TOTP fornecido pelo usuário.
    
    TODO: Implementar validação do código TOTP contra o secret armazenado.
    """
    return {"message": "Código MFA verificado com sucesso"}


@router.post("/logout")
async def logout():
    """
    Encerra sessão do usuário (invalidar token).
    
    TODO: Implementar blacklist de tokens ou invalidação via cache.
    """
    return {"message": "Logout realizado com sucesso"}
