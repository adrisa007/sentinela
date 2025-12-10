cd /workspaces/sentinela

# 1. Ver estrutura real
echo "📁 Estrutura:"
ls -la
echo ""
ls -la app/ 2>/dev/null || echo "app/ não está aqui"
ls -la backend/app/ 2>/dev/null || echo "backend/app/ não está aqui"

# 2. Se app/ está na RAIZ (cenário mais provável):
if [ -d "app" ]; then
    echo "✅ app/ encontrado na raiz"
    
    # Criar/atualizar conftest nos testes de backend
    if [ -d "backend/tests" ]; then
        cat > backend/tests/conftest.py << 'EOF'
import sys
sys.path.insert(0, '/workspaces/sentinela')

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.core.database import Base, get_db

@pytest.fixture
def db_engine():
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def db_session(db_engine):
    Session = sessionmaker(bind=db_engine)
    session = Session()
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
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
EOF
        
        # Rodar testes
        cd backend
        PYTHONPATH=/workspaces/sentinela pytest tests/ -v
    fi
    
    # Se tests/ está na raiz
    if [ -d "tests" ] && [ ! -d "backend/tests" ]; then
        cat > tests/conftest.py << 'EOF'
import sys
sys.path.insert(0, '/workspaces/sentinela')

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.core.database import Base, get_db

@pytest.fixture
def db_engine():
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def db_session(db_engine):
    Session = sessionmaker(bind=db_engine)
    session = Session()
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
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
EOF
        
        # Rodar testes
        pytest tests/ -v
    fi
fi