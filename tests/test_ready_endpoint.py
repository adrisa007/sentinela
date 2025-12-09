"""
Testes para /health/ready endpoint com mocks corretos
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from app.main import app


class TestReadyEndpoint:
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    @patch('app.database.check_database_connection')
    def test_ready_endpoint_with_db_connected(self, mock_db, client):
        """Testa /ready quando DB está conectado"""
        mock_db.return_value = True
        
        response = client.get("/health/ready")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ready"
        assert data["database"] == "connected"
    
    @patch('app.database.check_database_connection')
    def test_ready_endpoint_with_db_disconnected(self, mock_db, client):
        """Testa /ready quando DB está desconectado"""
        mock_db.return_value = False
        
        response = client.get("/health/ready")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not ready"
        assert data["database"] == "disconnected"
    
    @patch('app.database.check_database_connection')
    def test_ready_endpoint_with_db_error(self, mock_db, client):
        """Testa /ready quando DB tem erro"""
        mock_db.side_effect = Exception("DB connection error")
        
        response = client.get("/health/ready")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not ready"
        assert "error" in data
    
    def test_ready_endpoint_response_structure(self, client):
        """Testa estrutura da resposta"""
        response = client.get("/health/ready")
        data = response.json()
        
        assert "status" in data
