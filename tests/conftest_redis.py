import pytest

class MockRedis:
    def ping(self):
        return True

@pytest.fixture(autouse=True)
def mock_redis(monkeypatch):
    monkeypatch.setattr("app.redis_client.redis_client", MockRedis())
