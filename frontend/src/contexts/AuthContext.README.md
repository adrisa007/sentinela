# AuthContext com MFA TOTP - adrisa007/sentinela (ID: 1112237272)

Context completo de autenticação com suporte MFA TOTP.

## 🔐 Features

### Autenticação
- ✅ Login/Logout
- ✅ JWT Token Management
- ✅ Session Persistence
- ✅ Auto Token Validation
- ✅ Role-based Access Control

### MFA TOTP
- ✅ Setup MFA com QR Code
- ✅ Integração Google Authenticator
- ✅ Verify & Enable TOTP
- ✅ Disable MFA
- ✅ Backup Codes
- ✅ MFA obrigatório para ROOT/GESTOR

## 🔌 API Endpoints

### POST /auth/login
Login com ou sem MFA:
```javascript
// Login normal
await login({ username: 'admin', password: 'admin123' })

// Login com MFA
await loginWithMFA(
  { username: 'admin', password: 'admin123' },
  '123456' // código TOTP
)
