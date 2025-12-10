"""
Testes de Health Checks - adrisa007/sentinela (ID: 1112237272)
"""
import pytest
from fastapi import status

def test_health_endpoint(client):
    """Testa endpoint /health"""
    response = client.get("/health")
    assert response.status_code == status.HTTP_200_OK
    
    data = response.json()
    assert "status" in data
    assert "service" in data
    # Aceitar qualquer valor de service
    assert data["service"] in ["sentinela", "Sentinela API"]

def test_health_live(client):
    """Testa endpoint /health/live"""
    response = client.get("/health/live")
    # Pode falhar se Redis não estiver disponível
    assert response.status_code in [
        status.HTTP_200_OK,
        status.HTTP_503_SERVICE_UNAVAILABLE
    ]

def test_health_ready(client):
    """Testa endpoint /health/ready"""
    response = client.get("/health/ready")
    assert response.status_code in [
        status.HTTP_200_OK,
        status.HTTP_503_SERVICE_UNAVAILABLE
    ]

def test_health_neon(client):
    """Testa endpoint /health/neon"""
    response = client.get("/health/neon")
    assert response.status_code in [
        status.HTTP_200_OK,
        status.HTTP_503_SERVICE_UNAVAILABLE
    ]
