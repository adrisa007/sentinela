"""
Testes para o endpoint /ready com verificação de banco de dados
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch
from app.main import app


class TestReadyEndpoint:
    """Testes para o endpoint /ready"""
    
    @pytest.fixture
    def client(self):
        """Cliente de teste"""
        return TestClient(app)
    
    @patch('app.core.database.check_database_connection')
    def test_ready_endpoint_with_db_connected(self, mock_db_check, client):
        """
        Testa /ready quando banco está conectado - deve retornar 200
        """
        mock_db_check.return_value = True
        
        response = client.get("/health/ready")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ready"
        assert data["database"] == "connected"
        assert "timestamp" in data
    
    @patch('app.core.database.check_database_connection')
    def test_ready_endpoint_with_db_disconnected(self, mock_db_check, client):
        """
        Testa /ready quando banco está desconectado - deve retornar 503
        """
        mock_db_check.return_value = False
        
        response = client.get("/health/ready")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not ready"
        assert data["database"] == "disconnected"
    
    @patch('app.core.database.check_database_connection')
    def test_ready_endpoint_with_db_error(self, mock_db_check, client):
        """
        Testa /ready quando há erro no banco - deve retornar 503
        """
        mock_db_check.side_effect = Exception("Connection timeout")
        
        response = client.get("/health/ready")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not ready"
        assert data["database"] == "error"
        assert "error" in data
    
    def test_ready_endpoint_response_structure(self, client):
        """
        Testa estrutura da resposta do /ready
        """
        response = client.get("/health/ready")
        data = response.json()
        
        # Verifica campos obrigatórios
        assert "status" in data
        assert "database" in data
        assert "timestamp" in data
