import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.core.database import Base, get_db

@pytest.fixture(autouse=True)
def mock_totp(monkeypatch):
    """Auto-mock TOTP verification"""
    monkeypatch.setattr("app.core.auth.verify_totp", lambda *args, **kwargs: True)
    monkeypatch.setattr("app.core.dependencies.verify_totp", lambda *args, **kwargs: True)

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

# ==========================================
# MOCK REDIS (para testes sem Redis)
# ==========================================

@pytest.fixture(autouse=True)
def mock_redis_always(monkeypatch):
    """Mock Redis para todos os testes que precisam"""
    class MockRedisClient:
        def ping(self):
            return True
        
        def get(self, key):
            return None
        
        def set(self, key, value, ex=None):
            return True
    
    try:
        import app.redis_client
        monkeypatch.setattr(app.redis_client, "redis_client", MockRedisClient())
    except:
        pass
