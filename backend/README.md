# 🛡️ Sentinela Backend

[![Vercel](https://img.shields.io/badge/Vercel-000000?style=flat&logo=vercel&logoColor=white)](https://opal.vercel.app)
[![Tests](https://img.shields.io/badge/Tests-100%25-brightgreen?style=flat)](./test)
[![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen?style=flat)](./test)
[![Security](https://img.shields.io/badge/Security-A%2B-brightgreen?style=flat)](https://github.com/adrisa007/sentinela/security)
[![Lei 14.133/2021](https://img.shields.io/badge/Lei-14.133%2F2021-blue?style=flat)](https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2021/lei/l14133.htm)

> **Backend 100% pronto para produção – Lei 14.133/2021**

Sistema completo de Gestão e Fiscalização de Contratos conforme a Nova Lei de Licitações.

## 📋 Índice

- [Tecnologias](#-tecnologias)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Health Check](#-health-check)
- [Backup](#-backup)
- [Testes](#-testes)
- [Deploy](#-deploy)
- [Estrutura do Projeto](#-estrutura-do-projeto)

## 🚀 Tecnologias

- **NestJS** - Framework Node.js
- **Prisma** - ORM para PostgreSQL
- **Neon** - PostgreSQL Serverless
- **Winston** - Logging estruturado (JSON)
- **Terminus** - Health checks
- **Jest + Supertest** - Testes E2E
- **AWS S3** - Backup automatizado

## 📦 Pré-requisitos

- Node.js 20+
- npm ou yarn
- PostgreSQL 16+ (Neon)
- Conta AWS (para backups)

## 🔧 Instalação

```bash
# Clone o repositório
git clone https://github.com/adrisa007/sentinela.git
cd sentinela/backend

# Instale as dependências
npm install

# Configure as variáveis de ambiente
cp .env.example .env

# Gere o cliente Prisma
npx prisma generate

# Execute as migrações
npx prisma migrate deploy

# Inicie o servidor
npm run start:dev
```

## 🏥 Health Check

O sistema possui três endpoints de health check:

| Endpoint | Descrição | Uso |
|----------|-----------|-----|
| `GET /health` | Status geral com verificação de banco | Monitoramento |
| `GET /ready` | Readiness probe (Kubernetes) | Deploy |
| `GET /live` | Liveness probe (Kubernetes) | Deploy |

```bash
# Verificar saúde da aplicação
curl http://localhost:3000/health

# Resposta esperada:
{
  "status": "ok",
  "info": {
    "database": {
      "status": "up",
      "message": "Neon PostgreSQL connected"
    }
  }
}
```

## 💾 Backup

### Backup Manual

```bash
# Execute o script de backup
npm run backup
```

### Backup Automático (GitHub Actions)

O backup é executado automaticamente via GitHub Actions. Configure os seguintes secrets:

| Secret | Descrição |
|--------|-----------|
| `DATABASE_URL` | URL de conexão Neon |
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `AWS_REGION` | Região AWS (ex: sa-east-1) |
| `S3_BUCKET_NAME` | Nome do bucket S3 |

### Backup via Cron Externo

```bash
# Adicione ao crontab (diário às 2h)
0 2 * * * cd /path/to/backend && npm run backup
```

## 🧪 Testes

```bash
# Testes unitários
npm run test

# Testes E2E com coverage
npm run test:e2e

# Coverage completo
npm run test:cov
```

### Requisitos de Coverage

- Branches: 80%
- Functions: 80%
- Lines: 80%
- Statements: 80%

## 🚀 Deploy

### Vercel (Produção)

O deploy é automático via GitHub Actions:

- **Push na main** → Deploy em produção
- **Pull Request** → Deploy preview

### Variáveis de Ambiente (Vercel)

```env
DATABASE_URL=postgresql://...@neon.tech/sentinela
JWT_SECRET=sua-chave-secreta-256-bits
COOKIE_SECRET=outra-chave-secreta
NODE_ENV=production
```

## 📁 Estrutura do Projeto

```
backend/
├── src/
│   ├── common/
│   │   ├── controllers/    # Controllers utilitários
│   │   ├── guards/         # Auth guards
│   │   ├── interceptors/   # Audit interceptor
│   │   ├── logger/         # Winston logger
│   │   └── throttler/      # Rate limiting
│   ├── health/             # Health check endpoints
│   ├── modules/
│   │   └── auth/           # Autenticação + MFA
│   ├── prisma/             # Prisma service
│   ├── app.module.ts
│   └── main.ts
├── scripts/
│   └── backup-neon-s3.ts   # Script de backup
├── test/
│   ├── auth.e2e-spec.ts
│   ├── health.e2e-spec.ts
│   └── contrato.e2e-spec.ts
├── prisma/
│   └── schema.prisma
└── vercel.json
```

## 🔒 Segurança

- ✅ Helmet (headers de segurança)
- ✅ CORS restrito
- ✅ CSRF protection
- ✅ Rate limiting
- ✅ MFA (TOTP) para ROOT/GESTOR
- ✅ JWT com rotação
- ✅ Auditoria global (AuditoriaGlobal)
- ✅ Logging estruturado (compatível com SIEM)

## 📄 Licença

Este projeto está sob a licença ISC.

---

**Sentinela – Vigilância total, risco zero.**
