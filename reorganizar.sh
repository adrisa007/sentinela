# Criar app/__init__.py (se não existir)
cat > app/__init__.py << 'EOF'
"""
Sentinela - Sistema de Autenticação
"""
__version__ = "1.0.0"
EOF

# Criar app/main.py
cat > app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import init_db
from app.routers import auth_router
from app.core.config import settings

init_db()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="Sistema de Autenticação com JWT + MFA TOTP"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)

@app.get("/")
async def root():
    return {"app": settings.APP_NAME, "version": settings.VERSION, "docs": "/docs"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
EOF

# Garantir que app/core/dependencies.py está correto
cat > app/core/dependencies.py << 'EOF'
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.core.models import User, UserRole
from app.core.config import settings
from app.core.auth import verify_totp

security = HTTPBearer()

class CurrentUser:
    def __init__(self, user: User, mfa_verified: bool = False):
        self.id = user.id
        self.username = user.username
        self.email = user.email
        self.role = user.role
        self.mfa_verified = mfa_verified
        self.user = user

def decode_jwt_token(token: str) -> dict:
    try:
        return jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido")

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> CurrentUser:
    payload = decode_jwt_token(credentials.credentials)
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Usuário inválido")
    
    mfa_verified = False
    if user.role in [UserRole.ROOT, UserRole.GESTOR]:
        if not user.mfa_enabled:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="MFA obrigatório")
        totp_token = payload.get("totp")
        if not totp_token or not verify_totp(user.mfa_secret, totp_token):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="MFA inválido")
        mfa_verified = True
    
    return CurrentUser(user=user, mfa_verified=mfa_verified)

async def require_role(*allowed_roles: UserRole):
    async def role_checker(current_user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if current_user.role not in allowed_roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sem permissão")
        return current_user
    return role_checker

require_root = require_role(UserRole.ROOT)
require_gestor = require_role(UserRole.ROOT, UserRole.GESTOR)
EOF