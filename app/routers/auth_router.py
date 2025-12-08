"""
Router de Autenticação
======================

Endpoints de login, MFA e gerenciamento de sessão.

⚠️ Rate Limiting:
- POST /auth/login: 10 requisições/minuto (proteção contra força bruta)
- Outras rotas: 300 requisições/minuto (limite global)
"""
from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from datetime import datetime
import pyotp

from app.core.database import get_db
from app.core.models import User, UserRole
from app.core.schemas import (
    UserLogin,
    Token,
    MFASetup,
    MFAVerify,
    MessageResponse
)
from app.core.auth import (
    verify_password,
    create_access_token,
    generate_mfa_secret,
    generate_qr_code
)
from app.core.dependencies import get_current_user, CurrentUser
from app.core.rate_limit import limiter

router = APIRouter(
    prefix="/auth",
    tags=["Autenticação"]
)


@router.post(
    "/login",
    response_model=Token,
    summary="Login de Usuário",
    description="🔐 Autenticação com username/password. **Limite: 10 req/min para prevenir força bruta**."
)
@limiter.limit("10/minute")  # ✅ Limite restritivo de 10 req/min
async def login(
    request: Request,  # ✅ Necessário para o limiter
    user_login: UserLogin,
    db: Session = Depends(get_db)
):
    """
    🔐 **Login de Usuário - Limite: 10 requisições por minuto**
    
    Autentica usuário com username e password.
    
    **Rate Limiting:**
    - ✅ 10 requisições por minuto (por IP)
    - ✅ Proteção contra ataques de força bruta
    - ✅ Header X-RateLimit-* na resposta
    
    **Validações:**
    - Username e password corretos
    - Usuário ativo
    - Se MFA habilitado, requer código TOTP
    
    **Request:**
    ```json
    {
      "username": "usuario",
      "password": "senha123",
      "totp_code": "123456"  // Opcional: apenas se MFA habilitado
    }
    ```
    
    **Response 200 OK:**
    ```json
    {
      "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "token_type": "bearer",
      "user": {
        "id": 1,
        "username": "usuario",
        "role": "GESTOR",
        "mfa_enabled": true
      }
    }
    ```
    
    **Response 429 Too Many Requests:**
    ```json
    {
      "error": "Rate Limit Exceeded",
      "message": "Você excedeu o limite de tentativas de login. Tente novamente em 1 minuto.",
      "detail": {
        "limit": "10 requisições por minuto",
        "retry_after": "60 segundos"
      }
    }
    ```
    
    **Response 401 Unauthorized:**
    - Username ou password incorretos
    - Usuário inativo
    - Código MFA inválido (se MFA habilitado)
    """
    from app.core.dependencies import logger
    
    # Log de tentativa de login
    logger.info(f"🔐 Tentativa de login: username='{user_login.username}'")
    
    # Buscar usuário
    user = db.query(User).filter(User.username == user_login.username).first()
    
    if not user:
        logger.warning(f"🚫 Login falhou: Usuário '{user_login.username}' não encontrado")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username ou password incorretos",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # Verificar password
    if not verify_password(user_login.password, user.hashed_password):
        logger.warning(f"🚫 Login falhou: Password incorreto para '{user_login.username}'")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username ou password incorretos",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # Verificar se usuário está ativo
    if not user.is_active:
        logger.warning(f"🚫 Login falhou: Usuário '{user_login.username}' está inativo")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário inativo. Contate o administrador."
        )
    
    # Validar MFA se habilitado
    token_data = {"sub": str(user.id)}
    
    if user.mfa_enabled:
        if not user_login.totp_code:
            logger.warning(f"�� Login falhou: MFA habilitado mas código não fornecido - '{user_login.username}'")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="MFA habilitado. Forneça o código TOTP."
            )
        
        # Verificar código TOTP
        totp = pyotp.TOTP(user.mfa_secret)
        if not totp.verify(user_login.totp_code, valid_window=1):
            logger.warning(f"🚫 Login falhou: Código TOTP inválido para '{user_login.username}'")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Código MFA inválido ou expirado"
            )
        
        # Adicionar código TOTP ao token
        token_data["totp"] = user_login.totp_code
    
    # Atualizar último login
    user.last_login = datetime.utcnow()
    db.commit()
    
    # Gerar token
    access_token = create_access_token(data=token_data)
    
    # Log de sucesso
    logger.info(
        f"✅ Login bem-sucedido: '{user.username}' (ID: {user.id}, Role: {user.role.value})"
    )
    
    return JSONResponse(
        status_code=200,
        content={
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "username": user.username,
                "role": user.role.value,
                "mfa_enabled": user.mfa_enabled
            }
        }
    )


@router.post(
    "/mfa/setup",
    response_model=MFASetup,
    summary="Configurar MFA (TOTP)",
    description="🔒 Gera QR Code para configurar autenticação de dois fatores."
)
async def setup_mfa(
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    🔒 **Configurar MFA - Gerar QR Code**
    
    Gera secret e QR Code para configurar MFA TOTP no aplicativo autenticador.
    
    **Limite Global**: 300 req/min
    """
    from app.core.dependencies import logger
    
    # Gerar secret se não existir
    if not current_user.mfa_secret:
        current_user.mfa_secret = generate_mfa_secret()
        db.commit()
        db.refresh(current_user)
    
    # Gerar QR Code
    qr_code = generate_qr_code(
        username=current_user.username,
        secret=current_user.mfa_secret
    )
    
    logger.info(f"🔒 MFA setup iniciado para '{current_user.username}'")
    
    return {
        "secret": current_user.mfa_secret,
        "qr_code": qr_code,
        "username": current_user.username
    }


@router.post(
    "/mfa/verify",
    response_model=MessageResponse,
    summary="Verificar e Ativar MFA",
    description="✅ Verifica código TOTP e ativa MFA na conta."
)
async def verify_mfa(
    mfa_verify: MFAVerify,
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    ✅ **Verificar Código TOTP e Ativar MFA**
    
    Verifica se o código TOTP está correto e ativa MFA na conta do usuário.
    
    **Limite Global**: 300 req/min
    """
    from app.core.dependencies import logger
    
    if not current_user.mfa_secret:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="MFA não foi configurado. Execute /auth/mfa/setup primeiro."
        )
    
    # Verificar código
    totp = pyotp.TOTP(current_user.mfa_secret)
    if not totp.verify(mfa_verify.totp_code, valid_window=1):
        logger.warning(f"🚫 Verificação MFA falhou para '{current_user.username}'")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Código MFA inválido ou expirado"
        )
    
    # Ativar MFA
    current_user.mfa_enabled = True
    db.commit()
    
    logger.info(f"✅ MFA ativado para '{current_user.username}'")
    
    return MessageResponse(
        message="MFA ativado com sucesso!",
        detail=f"A partir de agora, você precisará do código TOTP para fazer login."
    )


@router.delete(
    "/mfa/disable",
    response_model=MessageResponse,
    summary="Desativar MFA",
    description="🔓 Desativa autenticação de dois fatores."
)
async def disable_mfa(
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    🔓 **Desativar MFA**
    
    Desativa autenticação de dois fatores na conta do usuário.
    
    **Limite Global**: 300 req/min
    
    ⚠️ **Atenção**: ROOT e GESTOR devem manter MFA ativado por segurança.
    """
    from app.core.dependencies import logger
    
    # Alertar se é ROOT ou GESTOR
    if current_user.role in [UserRole.ROOT, UserRole.GESTOR]:
        logger.warning(
            f"⚠️ Usuário '{current_user.username}' (Role: {current_user.role.value}) "
            f"desativou MFA. Isso reduz a segurança!"
        )
    
    # Desativar MFA
    current_user.mfa_enabled = False
    db.commit()
    
    logger.info(f"🔓 MFA desativado para '{current_user.username}'")
    
    return MessageResponse(
        message="MFA desativado com sucesso",
        detail="Você não precisará mais de código TOTP para fazer login."
    )


@router.get(
    "/me",
    summary="Usuário Atual",
    description="👤 Retorna informações do usuário autenticado."
)
async def get_me(current_user: CurrentUser = Depends(get_current_user)):
    """
    👤 **Obter Informações do Usuário Atual**
    
    Retorna informações do usuário autenticado pelo token JWT.
    
    **Limite Global**: 300 req/min
    """
    return JSONResponse(content={
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "role": current_user.role.value,
        "mfa_enabled": current_user.mfa_enabled,
        "entidade_id": current_user.entidade_id,
        "is_active": current_user.is_active,
        "last_login": current_user.last_login.isoformat() if current_user.last_login else None
    })
