"""
Configuração de fixtures e setup para testes com pytest.
"""

import pytest
import asyncio
from typing import AsyncGenerator, Generator
from httpx import AsyncClient
from sqlmodel import SQLModel, create_engine
from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

from app.main import app
from app.core.dependencies import get_db
from app.core.config import settings


# URL de teste (usa banco de dados separado ou in-memory)
TEST_DATABASE_URL = "postgresql+asyncpg://test:test@localhost:5432/sentinela_test"


@pytest.fixture(scope="session")
def event_loop() -> Generator:
    """
    Cria um event loop para toda a sessão de testes.
    """
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
async def test_engine():
    """
    Engine de banco de dados para testes.
    """
    engine = create_async_engine(
        TEST_DATABASE_URL,
        echo=True,
        future=True,
    )
    
    # Criar todas as tabelas
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
    
    yield engine
    
    # Limpar após os testes
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.drop_all)
    
    await engine.dispose()


@pytest.fixture
async def test_db(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """
    Sessão de banco de dados para testes.
    Cada teste recebe uma sessão limpa com rollback automático.
    """
    async_session_maker = async_sessionmaker(
        test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )
    
    async with async_session_maker() as session:
        yield session
        await session.rollback()


@pytest.fixture
async def client(test_db: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """
    Cliente HTTP assíncrono para testes de API.
    """
    # Override da dependência get_db para usar test_db
    async def override_get_db():
        yield test_db
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()


@pytest.fixture
async def test_user(test_db: AsyncSession):
    """
    Cria um usuário de teste.
    """
    from app.models.all_models import Usuario
    from app.core.security import get_password_hash
    
    user = Usuario(
        email="test@sentinela.com",
        nome_completo="Usuário Teste",
        senha_hash=get_password_hash("senha123"),
        is_active=True,
        is_superuser=False,
    )
    
    test_db.add(user)
    await test_db.commit()
    await test_db.refresh(user)
    
    return user


@pytest.fixture
async def test_superuser(test_db: AsyncSession):
    """
    Cria um superusuário de teste.
    """
    from app.models.all_models import Usuario
    from app.core.security import get_password_hash
    
    user = Usuario(
        email="admin@sentinela.com",
        nome_completo="Admin Teste",
        senha_hash=get_password_hash("admin123"),
        is_active=True,
        is_superuser=True,
    )
    
    test_db.add(user)
    await test_db.commit()
    await test_db.refresh(user)
    
    return user


@pytest.fixture
async def test_entidade(test_db: AsyncSession):
    """
    Cria uma entidade de teste.
    """
    from app.models.all_models import Entidade, TipoEntidade
    
    entidade = Entidade(
        cnpj="12345678901234",
        nome="Prefeitura de Teste",
        tipo_entidade=TipoEntidade.MUNICIPAL,
        uf="SP",
        municipio="São Paulo",
        esfera="municipal",
        ativo=True,
    )
    
    test_db.add(entidade)
    await test_db.commit()
    await test_db.refresh(entidade)
    
    return entidade


@pytest.fixture
async def test_fornecedor(test_db: AsyncSession):
    """
    Cria um fornecedor de teste.
    """
    from app.models.all_models import Fornecedor
    
    fornecedor = Fornecedor(
        cnpj="98765432109876",
        razao_social="Fornecedor Teste LTDA",
        nome_fantasia="Fornecedor Teste",
        situacao_receita="ATIVA",
        ativo=True,
    )
    
    test_db.add(fornecedor)
    await test_db.commit()
    await test_db.refresh(fornecedor)
    
    return fornecedor


@pytest.fixture
def auth_headers(test_user):
    """
    Headers de autenticação para requisições.
    """
    from app.core.security import create_access_token
    
    token = create_access_token(data={"sub": str(test_user.id), "email": test_user.email})
    return {"Authorization": f"Bearer {token}"}


# ==================== HELPERS ====================

def assert_status_code(response, expected_status: int):
    """Helper para assertar status code com mensagem detalhada"""
    assert response.status_code == expected_status, (
        f"Expected {expected_status}, got {response.status_code}. "
        f"Response: {response.text}"
    )
