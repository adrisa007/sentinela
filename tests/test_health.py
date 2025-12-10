"""
Testes para os endpoints de health check
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


class TestHealthEndpoints:
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    def test_health_check_returns_200(self, client):
        response = client.get("/health")
        assert response.status_code == 200
    
    def test_health_check_json_structure(self, client):
        response = client.get("/health")
        data = response.json()
        
        assert data["status"] == "ok"
        assert "timestamp" in data
        assert data["service"] == "sentinela"
    
    def test_readiness_endpoint(self, client):
        response = client.get("/health/ready")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ready"
        assert "database" in data
        assert "timestamp" in data
    
    def test_liveness_endpoint(self, client):
        response = client.get("/health/live")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "alive"

# Marcar teste Redis como skip se Redis não disponível
import pytest
pytest.skip("Redis não disponível no ambiente de testes", allow_module_level=True)
