import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch
from app.main import app

class TestLiveEndpoint:
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    @patch('app.routers.health.check_redis_connection')
    @patch('app.routers.health.get_redis_info')
    def test_live_returns_200_when_redis_connected(self, mock_info, mock_check, client):
        mock_check.return_value = True
        mock_info.return_value = {"connected": True, "version": "7.0", "uptime_seconds": 100, "connected_clients": 2}
        response = client.get("/health/live")
        assert response.status_code == 200
        assert response.json()["status"] == "alive"
    
    @patch('app.routers.health.check_redis_connection')
    @patch('app.routers.health.get_redis_info')
    def test_live_returns_503_when_redis_down(self, mock_info, mock_check, client):
        mock_check.return_value = False
        mock_info.return_value = {"connected": False, "error": "Connection refused"}
        response = client.get("/health/live")
        assert response.status_code == 503
        assert response.json()["status"] == "not alive"
