# Login Page - adrisa007/sentinela (ID: 1112237272)

Página de login completa com React Hook Form e validação.

## 🔐 Features

### React Hook Form
- ✅ Validação completa
- ✅ Error handling
- ✅ onBlur validation
- ✅ Form state management
- ✅ Auto-focus

### Validações

#### Email
- **Obrigatório**: Sim
- **Pattern**: Email válido
- **Regex**: `/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i`
- **Mensagem**: "Email inválido"

#### Senha
- **Obrigatório**: Sim
- **Min Length**: 6 caracteres
- **Mensagem**: "Senha deve ter no mínimo 6 caracteres"

#### Código MFA (condicional)
- **Obrigatório**: Somente se showMFA = true
- **Pattern**: Exatamente 6 dígitos
- **Regex**: `/^\d{6}$/`
- **maxLength**: 6
- **Mensagem**: "Código deve ter exatamente 6 dígitos"

### MFA Flow
1. Usuário digita email e senha
2. Submit → `login(credentials)`
3. Se backend retornar `needsMFA: true`:
   - `setShowMFA(true)`
   - Campo TOTP aparece
   - Auto-focus no campo MFA
4. Usuário digita código de 6 dígitos
5. Submit → `loginWithMFA(credentials, totpCode)`
6. Se sucesso → Redirect para /dashboard

### Auto-Redirect
Usuários já autenticados são redirecionados automaticamente:
```javascript
useEffect(() => {
  if (isAuthenticated) {
    const from = location.state?.from?.pathname || '/dashboard'
    navigate(from, { replace: true })
  }
}, [isAuthenticated])
