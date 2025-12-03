# Backend

## Variáveis de Ambiente

Badge: Variáveis seguras ✅

Nunca commite `.env` – use `.env.example` como referência e configure as variáveis no painel da Vercel (Project Settings → Environment Variables).

| Variável | Descrição | Exemplo/Default |
|---------|-----------|-----------------|
| `NODE_ENV` | Ambiente de execução | `production` |
| `DATABASE_URL` | URL do Postgres com SSL | `postgresql://user:pass@host:5432/db?sslmode=require` |
| `JWT_SECRET` | Chave do JWT (>= 32 chars) | `sua_chave_secreta_de_512_bits_aqui` |
| `JWT_EXPIRES_IN` | Expiração do JWT | `8h` |
| `JWT_REFRESH_EXPIRES_IN` | Expiração do refresh token | `30d` |
| `COOKIE_SECRET` | Chave para cookies/CSRF | `sua_chave_cookie_256_bits_aqui` |
| `ENCRYPTION_KEY` | Chave AES-256-GCM em hex (64 chars) | `sua_chave_aes_256_gcm_64_hex_aqui` |
| `FRONTEND_URL` | URL pública do frontend | `https://sentinela-opal-seven.vercel.app` |
| `API_URL` | URL pública da API | `https://opal.vercel.app` |
| `THROTTLE_TTL` | Janela de rate limit (ms) | `60000` |
| `THROTTLE_LIMIT` | Limite padrão por janela | `300` |
| `THROTTLE_LIMIT_LOGIN` | Limite para login | `10` |
| `VERCEL_BLOB_TOKEN` | Token do Vercel Blob | `seu_token_blob_aqui` |
| `SENTRY_DSN` | DSN do Sentry | `https://sua_dsn@sentry.io/123456` |

### Uso com NestJS
- O `ConfigModule` é carregado globalmente com validação Joi.
- Consulte `src/config/configuration.ts` para grupos de configuração.
- Validação em `src/config/validation.schema.ts` com mensagens claras.
