# Sentinela Backend

![Auditoria 100% automática](https://img.shields.io/badge/Auditoria-100%25%20autom%C3%A1tica-brightgreen)
![Logs JSON estruturados](https://img.shields.io/badge/Logs-JSON%20estruturados-blue)

**Todo real público rastreado – conforme Lei 14.133/2021**

## Tecnologias

- NestJS
- Prisma ORM
- PostgreSQL
- Winston Logger
- JWT Authentication

## Funcionalidades de Auditoria

O sistema conta com interceptador de auditoria global que:

- Intercepta todas as requisições POST, PATCH, PUT e DELETE
- Captura dados antes e depois de cada operação
- Grava automaticamente na tabela `auditoria_global`
- Registra: entidadeId, usuarioId, email, ação, tabela afetada, IP, User-Agent e timestamp

## Logger Estruturado

Logs JSON compatíveis com:
- Vercel Logs
- Grafana Loki

Informações incluídas em cada log:
- timestamp (ISO)
- level (INFO, ERROR, etc.)
- message
- projeto: "Sentinela"
- ambiente: NODE_ENV
- entidadeId, usuarioId, usuarioEmail
- IP e metadados adicionais
