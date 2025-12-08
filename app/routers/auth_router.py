from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import json

from app.core.database import get_db
from app.core.models import User, UserRole
from app.core.schemas import (
    UserCreate, UserResponse, Token, LoginRequest,
    MFASetupResponse, MFAVerifyRequest, MessageResponse
)
from app.core.auth import (
    authenticate_user, create_access_token, get_password_hash,
    generate_mfa_secret, generate_qr_code, verify_totp,
    generate_backup_codes, update_last_login
)
from app.core.dependencies import get_current_user, CurrentUser
from app.core.config import settings

router = APIRouter(prefix="/auth", tags=["Autenticação"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Registra um novo usuário"""
    if db.query(User).filter(User.username == user_data.username).first():
        raise HTTPException(status_code=400, detail="Username já existe")
    if db.query(User).filter(User.email == user_data.email).first():
        raise HTTPException(status_code=400, detail="Email já existe")
    
    new_user = User(
        username=user_data.username,
        email=user_data.email,
        full_name=user_data.full_name,
        hashed_password=get_password_hash(user_data.password),
        role=user_data.role
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.post("/login", response_model=Token)
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """Login com username/password + MFA (se necessário)"""
    user = authenticate_user(db, login_data.username, login_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Credenciais inválidas")
    
    if user.role in [UserRole.ROOT, UserRole.GESTOR]:
        if not user.mfa_enabled:
            return Token(access_token="", mfa_required=True)
        if not login_data.totp_code:
            raise HTTPException(status_code=403, detail="MFA obrigatório")
        if not verify_totp(user.mfa_secret, login_data.totp_code):
            raise HTTPException(status_code=403, detail="MFA inválido")
        token_data = {"sub": user.id, "totp": login_data.totp_code}
    else:
        token_data = {"sub": user.id}
    
    access_token = create_access_token(data=token_data)
    update_last_login(db, user.id)
    return Token(access_token=access_token, expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: CurrentUser = Depends(get_current_user)):
    """Retorna informações do usuário autenticado"""
    return current_user.user


@router.post("/mfa/setup", response_model=MFASetupResponse)
async def setup_mfa(
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Configura MFA para o usuário"""
    secret = generate_mfa_secret()
    backup_codes = generate_backup_codes(10)
    
    user = db.query(User).filter(User.id == current_user.id).first()
    user.mfa_secret = secret
    user.mfa_enabled = False
    user.mfa_backup_codes = json.dumps(backup_codes)
    db.commit()
    
    qr_code = generate_qr_code(user.email, secret)
    manual_key = "-".join([secret[i:i+4] for i in range(0, len(secret), 4)])
    
    return MFASetupResponse(
        secret=secret,
        qr_code=qr_code,
        backup_codes=backup_codes,
        manual_entry_key=manual_key
    )


@router.post("/mfa/verify", response_model=MessageResponse)
async def verify_mfa(
    verify_data: MFAVerifyRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Verifica e ativa MFA"""
    user = db.query(User).filter(User.id == current_user.id).first()
    
    if not user.mfa_secret:
        raise HTTPException(status_code=400, detail="MFA não configurado")
    
    if not verify_totp(user.mfa_secret, verify_data.totp_code):
        raise HTTPException(status_code=400, detail="Código inválido")
    
    user.mfa_enabled = True
    db.commit()
    
    return MessageResponse(message="MFA ativado com sucesso")
