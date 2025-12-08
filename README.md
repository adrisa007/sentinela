# 🛡️ Sentinela - Sistema de Autenticação com JWT + MFA TOTP

Sistema robusto de autenticação com JWT (JSON Web Tokens) e MFA TOTP (Multi-Factor Authentication via Time-based One-Time Password), com controle de acesso baseado em roles.

## ✨ Características

- 🔐 **Autenticação JWT**: Tokens seguros e stateless
- 📱 **MFA TOTP**: Autenticação de dois fatores via Google Authenticator/Authy
- 👥 **Roles**: Sistema de permissões (ROOT, GESTOR, OPERADOR)
- 🔒 **MFA Obrigatório**: Para ROOT e GESTOR
- 📊 **API RESTful**: Documentação automática com Swagger
- 🗄️ **SQLite**: Banco de dados leve (fácil migrar para PostgreSQL/MySQL)
- ✅ **Validação**: Schemas Pydantic robustos

## 📋 Requisitos

- Python 3.8+
- pip

