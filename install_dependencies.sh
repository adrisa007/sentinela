#!/bin/bash

echo "📦 Instalando Dependências do Sentinela"
echo "========================================"

# Atualizar pip
echo "🔄 Atualizando pip..."
pip install --upgrade pip setuptools wheel

# Instalar dependências principais
echo "📚 Instalando dependências principais..."
pip install fastapi==0.104.1
pip install 'uvicorn[standard]==0.24.0'
pip install sqlalchemy==2.0.23

# Instalar segurança
echo "🔒 Instalando pacotes de segurança..."
pip install 'python-jose[cryptography]==3.3.0'
pip install 'passlib[bcrypt]==1.7.4'
pip install python-multipart==0.0.6

# Instalar validação
echo "✅ Instalando validação e configuração..."
pip install pydantic==2.5.0
pip install pydantic-settings==2.1.0
pip install 'pydantic[email]'  # Inclui email-validator
pip install python-dotenv==1.0.0

# Instalar MFA
echo "🔐 Instalando MFA TOTP..."
pip install pyotp==2.9.0
pip install 'qrcode[pil]==7.4.2'

# Instalar ferramentas de teste
echo "🧪 Instalando ferramentas de teste..."
pip install pytest==7.4.4
pip install pytest-asyncio==0.23.3
pip install pytest-cov==4.1.0
pip install httpx==0.25.2

echo ""
echo "========================================"
echo "✅ Instalação concluída!"
echo "========================================"
echo ""
echo "📋 Dependências instaladas:"
pip list | grep -E "fastapi|pydantic|email|sqlalchemy|uvicorn|pytest"

