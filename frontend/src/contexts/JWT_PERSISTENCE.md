# JWT Persistence - adrisa007/sentinela (ID: 1112237272)

Persistência completa de JWT no localStorage.

## 💾 Dados Persistidos

### localStorage Keys

```javascript
const STORAGE_KEYS = {
  TOKEN: 'sentinela_token',              // JWT token
  USER: 'sentinela_user',                // User data (JSON)
  TOKEN_EXPIRY: 'sentinela_token_expiry', // Timestamp de expiração
  REFRESH_TOKEN: 'sentinela_refresh_token' // Refresh token
}
