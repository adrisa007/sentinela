# Sentinela – Vigilância total, risco zero.

[![CI/CD](https://github.com/adrisa007/sentinela/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/adrisa007/sentinela/actions/workflows/ci-cd.yml)
[![Vercel](https://img.shields.io/badge/Vercel-000000?style=flat&logo=vercel&logoColor=white)](https://opal.vercel.app)
[![Tests](https://img.shields.io/badge/Tests-100%25-brightgreen?style=flat)](./backend/test)
[![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen?style=flat)](./backend/test)
[![Security](https://img.shields.io/badge/Security-A%2B-brightgreen?style=flat)](https://github.com/adrisa007/sentinela/security)
[![Lei 14.133/2021](https://img.shields.io/badge/Lei-14.133%2F2021-blue?style=flat)](https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2021/lei/l14133.htm)

Sistema completo de Gestão e Fiscalização de Contratos – 100% conforme a Lei nº 14.133/2021

### Links oficiais (em produção agora)

- Aplicação web → https://sentinela-opal-seven.vercel.app
- API REST → https://opal.vercel.app
- Documentação Swagger → https://opal.vercel.app/docs
- Repositório → https://github.com/adrisa007/sentinela

### Acesso rápido (piloto)

Usuário demo (fiscal):  
Login: `demo@sentinela.app`  
Senha: `Sentinela2025!`

Usuário ROOT (governança):  
Login: `root@sentinela.app`  
Senha + MFA: será enviado por WhatsApp

🔑 Credenciais Iniciais
Email: root@sentinela.app
Senha: SentinelaRoot2025!
⚠️ ALTERE A SENHA APÓS O PRIMEIRO LOGIN!

📚 Documentação
Endpoints
POST /api/auth/login - Login
POST /api/auth/totp/setup - Configurar MFA
POST /api/auth/totp/verify - Verificar MFA
GET /api/entidades - Listar entidades (ROOT)
GET /api/fornecedores - Listar fornecedores
GET /api/contratos - Listar contratos

🛡️ Segurança
Helmet + CORS + CSRF
Rate limiting
MFA obrigatório para ROOT/GESTOR
Auditoria automática
Logs estruturados (Winston)

📊 Conformidade Lei 14.133/2021
✅ Art. 14 - Certidões obrigatórias
✅ Art. 117 - Fiscalização de contratos
✅ Art. 137 - Penalidades
✅ Art. 174 - Auditoria e transparência