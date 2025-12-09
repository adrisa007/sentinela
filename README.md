# 🛡️ Sentinela - Sistema de Autenticação com JWT + MFA TOTP

[![Railway](https://img.shields.io/badge/Railway-Live-success?logo=railway)](https://web-production-8355.up.railway.app)
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Tests](https://img.shields.io/badge/Tests-80%25-yellow)](./reports/test_report.html)

Sistema robusto de autenticação com JWT (JSON Web Tokens) e MFA TOTP (Multi-Factor Authentication via Time-based One-Time Password), com controle de acesso baseado em roles.

**🌐 Produção:** https://web-production-8355.up.railway.app

## ✨ Características

- 🔐 **Autenticação JWT**: Tokens seguros e stateless
- 📱 **MFA TOTP**: Autenticação de dois fatores via Google Authenticator/Authy
- 👥 **Roles**: Sistema de permissões (ROOT, GESTOR, OPERADOR)
- 🔒 **MFA Obrigatório**: Para ROOT e GESTOR
- 📊 **API RESTful**: Documentação automática com Swagger
- 🗄️ **Neon PostgreSQL**: Banco de dados serverless
- ⚡ **Redis**: Cache e message broker
- 🔄 **Celery**: Tarefas assíncronas
- ✅ **Validação**: Schemas Pydantic robustos
- 🏥 **Health Checks**: Monitoramento de saúde

## 📋 Requisitos

- Python 3.12+
- Docker & Docker Compose (para desenvolvimento local)
- pip

