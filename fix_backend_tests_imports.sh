cd /workspaces/sentinela/backend

# 1. Adicionar path ao PYTHONPATH
export PYTHONPATH=/workspaces/sentinela/backend:$PYTHONPATH

# 2. Criar conftest.py corrigido
cat > tests/conftest.py << 'EOF'
import sys
from pathlib import Path

# Adicionar backend ao path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.core.database import Base, get_db

SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///:memory:"

@pytest.fixture
def db_engine():
    engine = create_engine(
        SQLALCHEMY_TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def db_session(db_engine):
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=db_engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()

@pytest.fixture
def client(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
EOF

# 3. Criar pytest.ini
cat > pytest.ini << 'EOF'
[pytest]
testpaths = tests
pythonpath = .
addopts = -v --tb=short
EOF

# 4. Testar
pytest tests/ -v