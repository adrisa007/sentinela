"""
Dependências reutilizáveis do FastAPI.
Injeção de dependências para autenticação, sessão DB, etc.
"""

from typing import AsyncGenerator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

from app.core.config import settings
from app.core.security import decode_token


# Configuração do banco de dados (SQLModel + AsyncIO)
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=True,  # Log SQL queries (desabilitar em produção)
    future=True,
)

async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency para obter sessão do banco de dados.
    
    Yields:
        AsyncSession: Sessão assíncrona do SQLModel
    """
    async with async_session_maker() as session:
        try:
            yield session
        finally:
            await session.close()


# Esquema de segurança Bearer Token
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> dict:
    """
    Obtém o usuário autenticado a partir do token JWT.
    
    Args:
        credentials: Credenciais Bearer Token do header Authorization
        db: Sessão do banco de dados
        
    Returns:
        Dados do usuário autenticado
        
    Raises:
        HTTPException: Se token inválido ou usuário não encontrado
    """
    token = credentials.credentials
    payload = decode_token(token)
    
    if payload is None or payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido ou expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user_id: Optional[str] = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido: user_id não encontrado",
        )
    
    # TODO: Buscar usuário no banco de dados usando user_id
    # user = await get_user_by_id(db, user_id)
    # if not user:
    #     raise HTTPException(status_code=404, detail="Usuário não encontrado")
    
    # Retorno temporário (implementar busca no DB)
    return {
        "id": user_id,
        "email": payload.get("email"),
        "entidade_id": payload.get("entidade_id"),
    }


async def get_current_entidade(
    current_user: dict = Depends(get_current_user)
) -> Optional[str]:
    """
    Obtém a entidade (órgão público) do usuário autenticado.
    
    Args:
        current_user: Usuário autenticado
        
    Returns:
        ID da entidade do usuário
    """
    return current_user.get("entidade_id")


async def require_superuser(
    current_user: dict = Depends(get_current_user)
) -> dict:
    """
    Verifica se o usuário autenticado é superusuário.
    
    Args:
        current_user: Usuário autenticado
        
    Returns:
        Dados do usuário se for superusuário
        
    Raises:
        HTTPException: Se usuário não for superusuário
    """
    # TODO: Implementar verificação real no banco
    is_superuser = current_user.get("is_superuser", False)
    
    if not is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Permissões insuficientes. Apenas superusuários podem acessar este recurso."
        )
    
    return current_user
