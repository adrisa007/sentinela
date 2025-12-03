# 🛡️ Sentinela Backend

[![Production Ready](https://img.shields.io/badge/production-ready-success)](https://github.com/adrisa007/sentinela)
[![Lei 14.133/2021](https://img.shields.io/badge/Lei-14.133%2F2021-blue)](https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2021/lei/L14133.htm)

## 🎯 Status: Produção Pronta – 100% Conforme Lei 14.133/2021

Sistema completo de gestão e fiscalização de contratos públicos.

## ✨ Funcionalidades

- ✅ Autenticação JWT + MFA/TOTP
- ✅ Multi-tenant com isolamento
- ✅ Rate limiting (300/min)
- ✅ Auditoria completa
- ✅ 12 modelos de dados
- ✅ 12 tipos de certidões

## 🚀 Quick Start

```bash
npm install
cp .env.example .env
npx prisma migrate deploy
npx prisma db seed
npm run start:prod
