"""
Testes para o endpoint raiz / do Sentinela
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


class TestRootEndpoint:
    """Testes para o endpoint GET /"""
    
    @pytest.fixture
    def client(self):
        """Cliente de teste"""
        return TestClient(app)
    
    def test_root_returns_200(self, client):
        """Testa se GET / retorna status 200"""
        response = client.get("/")
        assert response.status_code == 200
    
    def test_root_returns_message(self, client):
        """Testa se GET / retorna a mensagem correta"""
        response = client.get("/")
        data = response.json()
        
        assert "message" in data
        assert "Sentinela Python rodando no Railway" in data["message"]
        assert "Vigilância total, risco zero" in data["message"]
    
    def test_root_returns_url(self, client):
        """Testa se GET / retorna a URL"""
        response = client.get("/")
        data = response.json()
        
        assert "url" in data
        assert "railway.app" in data["url"]
    
    def test_root_returns_service_info(self, client):
        """Testa se GET / retorna informações do serviço"""
        response = client.get("/")
        data = response.json()
        
        assert data["service"] == "sentinela"
        assert data["status"] == "online"
    
    def test_root_returns_endpoints_list(self, client):
        """Testa se GET / retorna lista de endpoints"""
        response = client.get("/")
        data = response.json()
        
        assert "endpoints" in data
        assert "docs" in data["endpoints"]
        assert "health" in data["endpoints"]
        assert data["endpoints"]["docs"] == "/docs"
        assert data["endpoints"]["health"] == "/health"
    
    def test_root_content_type_json(self, client):
        """Testa se GET / retorna JSON"""
        response = client.get("/")
        assert "application/json" in response.headers["content-type"]
    
    def test_root_structure(self, client):
        """Testa estrutura completa da resposta"""
        response = client.get("/")
        data = response.json()
        
        required_fields = ["message", "url", "service", "status", "endpoints"]
        for field in required_fields:
            assert field in data, f"Campo {field} não encontrado"
    
    def test_root_endpoints_structure(self, client):
        """Testa estrutura do objeto endpoints"""
        response = client.get("/")
        data = response.json()
        
        required_endpoints = ["docs", "redoc", "health", "health_live", "health_ready"]
        for endpoint in required_endpoints:
            assert endpoint in data["endpoints"], f"Endpoint {endpoint} não encontrado"
