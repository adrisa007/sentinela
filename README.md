# Sentinela – Vigilância total, risco zero.

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

# 🛡️ Sentinela

![Auditoria 100% automática](https://img.shields.io/badge/Auditoria-100%25%20Autom%C3%A1tica-green)
![Logs JSON estruturados](https://img.shields.io/badge/Logs-JSON%20Estruturados-blue)

**Todo recurso público rastreado – conforme Lei 14.133/2021**

## 📊 Auditoria e Compliance

O Sentinela implementa auditoria global automática em todas as operações de modificação de dados (CREATE, UPDATE, DELETE), garantindo rastreabilidade completa conforme exigido pela Lei 14.133/2021.

### Recursos de Auditoria:
- ✅ Interceptação automática de todas as requisições POST, PATCH, PUT e DELETE
- ✅ Captura de dados ANTES e DEPOIS de cada operação
- ✅ Registro de usuário, entidade, IP e user agent
- ✅ Logs estruturados em formato JSON (compatível com Vercel Logs e Grafana Loki)
- ✅ Rastreabilidade completa de todas as ações no sistema

### Logging Estruturado:
Todos os logs são gerados em formato JSON profissional, incluindo:
- Timestamp ISO
- Nível de log (INFO, ERROR, WARN, DEBUG)
- Contexto da aplicação
- Metadados de auditoria (entidadeId, usuarioId, IP, etc.)
- Compatibilidade com ferramentas de observabilidade modernas