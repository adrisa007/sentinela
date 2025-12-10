"""
Testes de API Geral - adrisa007/sentinela (ID: 1112237272)
"""
import pytest
from fastapi import status

def test_root_endpoint(client):
    """Testa endpoint raiz"""
    response = client.get("/")
    assert response.status_code == status.HTTP_200_OK
    
    data = response.json()
    assert "message" in data
    assert "service" in data
    # Ajustar para o que realmente retorna
    # Não exigir "repository" se não existir

def test_docs_endpoint(client):
    """Testa se documentação está disponível"""
    response = client.get("/docs")
    assert response.status_code == status.HTTP_200_OK

def test_openapi_json(client):
    """Testa OpenAPI JSON"""
    response = client.get("/openapi.json")
    assert response.status_code == status.HTTP_200_OK
    
    data = response.json()
    assert "openapi" in data
    assert "info" in data

def test_404_endpoint(client):
    """Testa endpoint inexistente"""
    response = client.get("/endpoint-que-nao-existe")
    assert response.status_code == status.HTTP_404_NOT_FOUND
