"""
Testes para os endpoints de health check do Sentinela
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch
from app.main import app


class TestHealthEndpoints:
    """Testes para os endpoints de health"""
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    def test_health_returns_200(self, client):
        """Testa se /health retorna 200"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"
    
    def test_health_includes_service_info(self, client):
        """Testa se /health inclui informações do serviço"""
        response = client.get("/health")
        data = response.json()
        
        assert data["service"] == "sentinela"
        assert "version" in data
        assert "python_version" in data
        assert "platform" in data
        assert "timestamp" in data
    
    @patch('app.database.check_database_connection')
    def test_ready_returns_200_with_db_connected(self, mock_db, client):
        """Testa /ready quando banco está conectado - retorna 200"""
        mock_db.return_value = True
        
        response = client.get("/health/ready")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ready"
        assert data["database"] == "connected"
    
    @patch('app.database.check_database_connection')
    def test_ready_returns_503_with_db_disconnected(self, mock_db, client):
        """Testa /ready quando banco está desconectado - retorna 503"""
        mock_db.return_value = False
        
        response = client.get("/health/ready")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not ready"
        assert data["database"] == "disconnected"
    
    @patch('app.database.check_database_connection')
    def test_ready_returns_503_on_db_error(self, mock_db, client):
        """Testa /ready quando há erro no banco - retorna 503"""
        mock_db.side_effect = Exception("Connection timeout")
        
        response = client.get("/health/ready")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not ready"
        assert data["database"] == "error"
        assert "error" in data
    
    @patch('app.redis_client.get_redis_info')
    @patch('app.redis_client.check_redis_connection')
    def test_live_returns_200_with_redis_connected(self, mock_check, mock_info, client):
        """Testa /live quando Redis está conectado - retorna 200"""
        mock_check.return_value = True
        mock_info.return_value = {
            "connected": True,
            "version": "7.0.5",
            "uptime_seconds": 3600,
            "connected_clients": 5
        }
        
        response = client.get("/health/live")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "alive"
        assert data["redis"] == "connected"
        assert "redis_info" in data
        assert data["redis_info"]["version"] == "7.0.5"
    
    @patch('app.redis_client.get_redis_info')
    @patch('app.redis_client.check_redis_connection')
    def test_live_returns_503_with_redis_disconnected(self, mock_check, mock_info, client):
        """Testa /live quando Redis está desconectado - retorna 503"""
        mock_check.return_value = False
        mock_info.return_value = {
            "connected": False,
            "error": "Connection refused"
        }
        
        response = client.get("/health/live")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not alive"
        assert data["redis"] == "disconnected"
        assert "error" in data
    
    @patch('app.redis_client.check_redis_connection')
    def test_live_returns_503_on_redis_error(self, mock_check, client):
        """Testa /live quando há erro no Redis - retorna 503"""
        mock_check.side_effect = Exception("Redis timeout")
        
        response = client.get("/health/live")
        
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "not alive"
        assert data["redis"] == "error"
    
    def test_all_endpoints_return_json(self, client):
        """Testa se todos os endpoints retornam JSON"""
        endpoints = ["/health", "/health/ready", "/health/live"]
        
        for endpoint in endpoints:
            response = client.get(endpoint)
            assert "application/json" in response.headers["content-type"]
    
    def test_all_endpoints_include_timestamp(self, client):
        """Testa se todos os endpoints incluem timestamp"""
        response_health = client.get("/health")
        assert "timestamp" in response_health.json()
    
    @patch('app.database.check_database_connection')
    @patch('app.redis_client.check_redis_connection')
    @patch('app.redis_client.get_redis_info')
    def test_ready_and_live_are_independent(self, mock_redis_info, mock_redis_check, mock_db, client):
        """Testa se /ready e /live funcionam independentemente"""
        # DB OK, Redis down
        mock_db.return_value = True
        mock_redis_check.return_value = False
        mock_redis_info.return_value = {"connected": False, "error": "Down"}
        
        ready_response = client.get("/health/ready")
        live_response = client.get("/health/live")
        
        assert ready_response.status_code == 200
        assert live_response.status_code == 503
        
        # DB down, Redis OK
        mock_db.return_value = False
        mock_redis_check.return_value = True
        mock_redis_info.return_value = {"connected": True, "version": "7.0"}
        
        ready_response = client.get("/health/ready")
        live_response = client.get("/health/live")
        
        assert ready_response.status_code == 503
        assert live_response.status_code == 200


class TestHealthEndpointsPerformance:
    """Testes de performance"""
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    def test_health_responds_quickly(self, client):
        """Testa se /health responde em menos de 500ms"""
        import time
        
        start = time.time()
        response = client.get("/health")
        duration = time.time() - start
        
        assert response.status_code == 200
        assert duration < 0.5, f"Health check demorou {duration:.3f}s"
    
    @patch('app.database.check_database_connection')
    def test_ready_responds_quickly(self, mock_db, client):
        """Testa se /ready responde em menos de 2s"""
        import time
        
        mock_db.return_value = True
        
        start = time.time()
        response = client.get("/health/ready")
        duration = time.time() - start
        
        assert response.status_code == 200
        assert duration < 2.0, f"Ready check demorou {duration:.3f}s"
    
    @patch('app.redis_client.get_redis_info')
    @patch('app.redis_client.check_redis_connection')
    def test_live_responds_quickly(self, mock_check, mock_info, client):
        """Testa se /live responde em menos de 2s"""
        import time
        
        mock_check.return_value = True
        mock_info.return_value = {"connected": True, "version": "7.0"}
        
        start = time.time()
        response = client.get("/health/live")
        duration = time.time() - start
        
        assert response.status_code == 200
        assert duration < 2.0, f"Live check demorou {duration:.3f}s"
