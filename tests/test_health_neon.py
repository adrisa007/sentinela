"""
Testes para health check com Neon Database
Repositório: adrisa007/sentinela (ID: 1112237272)
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch
from app.main import app


class TestHealthNeon:
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    @patch('app.database.check_database_connection')
    def test_health_with_neon_connected(self, mock_db, client):
        """Testa /health quando Neon está conectado"""
        mock_db.return_value = True
        
        response = client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert data["database"] == "connected"
        assert data["database_type"] == "neon_postgres"
    
    @patch('app.database.check_database_connection')
    def test_health_with_neon_disconnected(self, mock_db, client):
        """Testa /health quando Neon está desconectado"""
        mock_db.return_value = False
        
        response = client.get("/health")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "degraded"
        assert data["database"] == "disconnected"
    
    @patch('app.database.check_database_connection')
    def test_ready_with_neon(self, mock_db, client):
        """Testa /ready com Neon"""
        mock_db.return_value = True
        
        response = client.get("/health/ready")
        
        assert response.status_code == 200
        data = response.json()
        assert data["database"] == "connected"
        assert data["database_type"] == "neon_postgres"
    
    def test_neon_endpoint_structure(self, client):
        """Testa estrutura do endpoint /health/neon"""
        response = client.get("/health/neon")
        data = response.json()
        
        assert "status" in data
        assert "database" in data
