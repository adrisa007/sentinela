"""
Testes para o endpoint raiz / do Sentinela
Repositório: adrisa007/sentinela (ID: 1112237272)
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


class TestRootEndpoint:
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    def test_root_returns_200(self, client):
        """Testa se GET / retorna status 200"""
        response = client.get("/")
        assert response.status_code == 200
    
    def test_root_message(self, client):
        """Testa mensagem do Railway"""
        response = client.get("/")
        data = response.json()
        
        assert "message" in data
        assert "Sentinela Python rodando no Railway" in data["message"]
        assert "Vigilância total, risco zero" in data["message"]
    
    def test_root_url(self, client):
        """Testa URL do Railway"""
        response = client.get("/")
        data = response.json()
        
        assert data["url"] == "https://web-production-8355.up.railway.app"
    
    def test_root_service_info(self, client):
        """Testa informações do serviço"""
        response = client.get("/")
        data = response.json()
        
        assert data["service"] == "sentinela"
        assert data["status"] == "online"
    
    def test_root_endpoints_list(self, client):
        """Testa lista de endpoints"""
        response = client.get("/")
        data = response.json()
        
        assert "endpoints" in data
        assert data["endpoints"]["docs"] == "/docs"
        assert data["endpoints"]["health"] == "/health"
        assert data["endpoints"]["health_live"] == "/health/live"
        assert data["endpoints"]["health_ready"] == "/health/ready"
