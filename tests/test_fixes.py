"""
Patches para testes específicos - adrisa007/sentinela (ID: 1112237272)
"""
import pytest

# Fixture global para mockar Redis
@pytest.fixture(autouse=True)
def mock_redis_for_tests(monkeypatch):
    """Mock Redis para todos os testes"""
    class MockRedis:
        def ping(self):
            return True
    
    try:
        monkeypatch.setattr("app.redis_client.redis_client", MockRedis())
    except:
        pass
