"""
Configuração global de testes - pytest fixtures
Repositório: adrisa007/sentinela (ID: 1112237272)
"""
import pytest
from unittest.mock import patch
from tests.helpers import mock_totp_validation, generate_valid_totp


@pytest.fixture
def mock_totp(monkeypatch):
    """Fixture que mocka validação TOTP para sempre retornar True"""
    mock_totp_validation(monkeypatch)
    return generate_valid_totp()


@pytest.fixture
def disable_mfa(monkeypatch):
    """Fixture que desabilita MFA completamente nos testes"""
    def always_true(*args, **kwargs):
        return True
    
    monkeypatch.setattr("app.core.dependencies.verify_totp", always_true)
    monkeypatch.setattr("pyotp.TOTP.verify", always_true)


@pytest.fixture(autouse=True)
def reset_database():
    """Fixture que reseta o estado do database entre testes"""
    # Aqui você pode adicionar lógica para limpar o DB
    yield
    # Cleanup após o teste


@pytest.fixture
def valid_totp_code():
    """Fixture que retorna um código TOTP válido"""
    return generate_valid_totp()
