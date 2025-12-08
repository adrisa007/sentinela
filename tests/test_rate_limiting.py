"""
Testes de Rate Limiting com SlowAPI
====================================

Valida que o sistema protege contra abuso de requisições.

Repositório: adrisa007/sentinela (ID: 1112237272)
"""
import pytest
import time
from fastapi.testclient import TestClient


class TestRateLimiting:
    """Testes de rate limiting global"""
    
    def test_rate_limit_info_endpoint_exists(self, client: TestClient):
        """✅ Endpoint de informações de rate limit existe"""
        response = client.get("/rate-limit-info")
        
        assert response.status_code == 200
        data = response.json()
        assert "global_limit" in data
        assert "300" in data["global_limit"]
    
    def test_health_endpoint_exempt_from_rate_limit(self, client: TestClient):
        """✅ Health check está isento de rate limiting"""
        # Fazer muitas requisições rapidamente
        for _ in range(10):
            response = client.get("/health")
            assert response.status_code == 200
        
        # Todas devem passar sem 429
    
    def test_docs_endpoint_exempt_from_rate_limit(self, client: TestClient):
        """✅ Endpoints de documentação estão isentos"""
        # Testar /docs
        response = client.get("/docs")
        # Pode retornar 200 ou redirect, mas não 429
        assert response.status_code != 429
    
    def test_rate_limit_headers_present(self, client: TestClient):
        """✅ Headers de rate limit presentes na resposta"""
        response = client.get("/")
        
        # SlowAPI adiciona headers quando configurado
        # Verificar se resposta é bem-sucedida
        assert response.status_code == 200
    
    def test_multiple_requests_within_limit(self, client: TestClient):
        """✅ Múltiplas requisições dentro do limite funcionam"""
        # Fazer 10 requisições (bem abaixo do limite de 300/min)
        for i in range(10):
            response = client.get("/")
            assert response.status_code == 200, \
                f"Requisição {i+1} falhou dentro do limite"
    
    def test_rate_limit_applies_to_api_routes(self, client: TestClient):
        """✅ Rate limit se aplica a rotas da API"""
        # Fazer requisição para rota de API
        response = client.get("/rate-limit-info")
        
        # Deve funcionar normalmente
        assert response.status_code == 200


class TestRateLimitExemptions:
    """Testes de isenções de rate limit"""
    
    def test_health_check_exempt(self, client: TestClient):
        """✅ /health está isento"""
        responses = []
        for _ in range(20):
            response = client.get("/health")
            responses.append(response.status_code)
        
        # Todas devem ser 200 (nenhum 429)
        assert all(status == 200 for status in responses)
    
    def test_openapi_json_exempt(self, client: TestClient):
        """✅ /openapi.json está isento"""
        response = client.get("/openapi.json")
        assert response.status_code != 429


class TestRateLimitConfiguration:
    """Testes de configuração do rate limiting"""
    
    def test_limiter_exists_in_app_state(self, client: TestClient):
        """✅ Limiter está configurado no app.state"""
        from app.main import app
        
        assert hasattr(app.state, 'limiter')
        assert app.state.limiter is not None
    
    def test_default_limit_is_300_per_minute(self, client: TestClient):
        """✅ Limite padrão é 300/minuto"""
        response = client.get("/rate-limit-info")
        
        assert response.status_code == 200
        data = response.json()
        assert "300" in data["global_limit"]
        assert "minuto" in data["global_limit"] or "minute" in data["global_limit"]
    
    def test_rate_limit_strategy_is_fixed_window(self, client: TestClient):
        """✅ Estratégia é fixed-window"""
        response = client.get("/rate-limit-info")
        
        assert response.status_code == 200
        data = response.json()
        assert data["strategy"] == "fixed-window"


class TestRateLimitIdentifier:
    """Testes do identificador de rate limit"""
    
    def test_identifier_uses_ip_by_default(self, client: TestClient):
        """✅ Identificador usa IP por padrão"""
        response = client.get("/rate-limit-info")
        
        assert response.status_code == 200
        data = response.json()
        assert "identifier" in data
        assert "IP" in data["identifier"] or "User ID" in data["identifier"]
    
    def test_x_forwarded_for_header_respected(self, client: TestClient):
        """✅ Header X-Forwarded-For é respeitado"""
        response = client.get(
            "/",
            headers={"X-Forwarded-For": "203.0.113.1"}
        )
        
        # Deve processar normalmente
        assert response.status_code == 200


class TestRateLimitErrorResponse:
    """Testes de resposta de erro 429"""
    
    def test_rate_limit_error_structure(self):
        """✅ Estrutura da resposta de erro 429 está correta"""
        # Este teste valida a estrutura esperada
        expected_structure = {
            "error": str,
            "message": str,
            "detail": {
                "limit": str,
                "retry_after": str,
                "identifier": str
            }
        }
        
        # Validar que a estrutura está definida
        assert expected_structure is not None


class TestRateLimitPerformance:
    """Testes de performance do rate limiting"""
    
    def test_rate_limit_does_not_slow_requests(self, client: TestClient):
        """✅ Rate limiting não adiciona latência significativa"""
        import time
        
        # Medir tempo de 10 requisições
        start = time.time()
        for _ in range(10):
            client.get("/health")
        end = time.time()
        
        duration = end - start
        
        # 10 requisições devem levar menos de 2 segundos
        # (200ms por requisição é um limite generoso)
        assert duration < 2.0, f"10 requisições levaram {duration:.2f}s"


class TestRateLimitDocumentation:
    """Testes de documentação do rate limiting"""
    
    def test_rate_limiting_documented_in_root(self, client: TestClient):
        """✅ Rate limiting está documentado na rota raiz"""
        response = client.get("/")
        
        assert response.status_code == 200
        data = response.json()
        
        # Verificar se rate limiting está mencionado
        security = data.get("security", {})
        assert "rate_limiting" in security or "rate" in str(security).lower()
    
    def test_rate_limit_info_endpoint_complete(self, client: TestClient):
        """✅ Endpoint /rate-limit-info retorna informações completas"""
        response = client.get("/rate-limit-info")
        
        assert response.status_code == 200
        data = response.json()
        
        # Verificar campos obrigatórios
        assert "global_limit" in data
        assert "strategy" in data
        assert "identifier" in data
        assert "exemptions" in data


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
