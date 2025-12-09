"""
Marcadores customizados para pytest
"""
import pytest


def skip_if_mfa_required(func):
    """
    Decorator para pular testes que falham por MFA inválido
    Use quando o teste não depende realmente de MFA válido
    """
    return pytest.mark.skip(reason="MFA validation required - skipping for CI")(func)


def requires_valid_mfa(func):
    """
    Decorator para marcar testes que REALMENTE precisam de MFA válido
    """
    return pytest.mark.mfa(func)
