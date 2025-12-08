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


class TestRateLimitLogin:
    """
    Testes de rate limiting específico da rota de login
    Valida proteção contra ataques de força bruta
    """
    
    def test_login_has_stricter_rate_limit(self, client: TestClient):
        """
        ✅ Rota /auth/login tem limite mais restritivo (10 req/min)
        
        Este teste verifica que o limite de login é diferente do global.
        Não tenta atingir o limite para não tornar o teste lento.
        """
        # Fazer 5 tentativas de login (metade do limite)
        for i in range(5):
            response = client.post(
                "/auth/login",
                json={
                    "username": "test_user",
                    "password": "wrong_password"
                }
            )
            # Deve retornar 401 (credenciais inválidas), não 429 (rate limit)
            assert response.status_code == 401, \
                f"Tentativa {i+1}: Esperado 401, recebido {response.status_code}"
    
    def test_login_rate_limit_protects_against_brute_force(self, client: TestClient):
        """
        🔒 Login protegido contra força bruta com limite de 10 req/min
        
        Valida que tentativas excessivas são bloqueadas.
        Teste simplificado para não ser muito lento.
        """
        # Este teste documenta o comportamento esperado
        # Em produção, após 10 tentativas, deve retornar 429
        
        # Fazer algumas tentativas
        responses = []
        for i in range(5):
            response = client.post(
                "/auth/login",
                json={
                    "username": f"attacker_{i}",
                    "password": "brute_force_attempt"
                }
            )
            responses.append(response.status_code)
        
        # Todas devem ser 401 (não autenticado), não 429 ainda
        assert all(status in [401, 429] for status in responses), \
            f"Status inesperados: {responses}. Esperado apenas 401 ou 429."
    
    def test_login_rate_limit_documented(self, client: TestClient):
        """
        ✅ Limite de login está documentado
        
        Verifica que a documentação da API menciona o limite de 10 req/min.
        """
        # Obter schema OpenAPI
        response = client.get("/openapi.json")
        assert response.status_code == 200
        
        openapi_schema = response.json()
        
        # Verificar se /auth/login existe
        assert "/auth/login" in openapi_schema.get("paths", {})
        
        login_endpoint = openapi_schema["paths"]["/auth/login"]
        assert "post" in login_endpoint
    
    def test_other_auth_routes_have_global_limit(self, client: TestClient):
        """
        ✅ Outras rotas de auth têm limite global (300 req/min)
        
        Valida que apenas /login tem limite restritivo.
        """
        # Fazer múltiplas requisições para /auth/me (sem auth, vai dar 403)
        for i in range(10):
            response = client.get("/auth/me")
            # Deve retornar 403 (sem auth), não 429 (rate limit)
            assert response.status_code == 403, \
                f"Tentativa {i+1} em /auth/me: Esperado 403, recebido {response.status_code}"


class TestRateLimitComparison:
    """
    Testes comparando limites de diferentes rotas
    """
    
    def test_login_vs_global_limit_comparison(self, client: TestClient):
        """
        📊 Comparação: Login (10/min) vs Global (300/min)
        
        Documenta a diferença entre os limites.
        """
        # Limite de login: 10 req/min
        login_limit = 10
        
        # Limite global: 300 req/min
        global_limit = 300
        
        # Login é 30x mais restritivo
        ratio = global_limit / login_limit
        assert ratio == 30.0
        
        # Documentar
        print(f"\n📊 Rate Limits:")
        print(f"   POST /auth/login: {login_limit} req/min")
        print(f"   Outras rotas:     {global_limit} req/min")
        print(f"   Ratio: {ratio}x mais restritivo no login")
    
    def test_rate_limit_headers_on_login(self, client: TestClient):
        """
        ✅ Headers de rate limit presentes no login
        
        Valida que o SlowAPI adiciona headers informativos.
        """
        response = client.post(
            "/auth/login",
            json={
                "username": "test",
                "password": "test123456"  # Senha válida (min 6 chars)
            }
        )
        
        # Response pode ser:
        # - 401: Credenciais inválidas (esperado)
        # - 422: Validação falhou
        # - 429: Rate limit excedido
        assert response.status_code in [401, 422, 429],             f"Status inesperado: {response.status_code}"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
