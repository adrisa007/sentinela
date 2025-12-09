# Login Page - adrisa007/sentinela (ID: 1112237272)

## Features

✅ **React Hook Form** com validação
✅ **Email/Senha** com validation patterns
✅ **MFA (TOTP)** conditional input (aparece se necessário)
✅ **Auto-redirect** para /dashboard se já autenticado
✅ **Loading states** durante submit
✅ **Error handling** com mensagens claras
✅ **Remember me** (opcional)
✅ **Responsive** design
✅ **Integração** completa com AuthContext

## Validações

### Email
- Obrigatório
- Formato de email válido
- Pattern: `/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i`

### Senha
- Obrigatório
- Mínimo 6 caracteres

### MFA (TOTP)
- Obrigatório quando `showMFA` = true
- Exatamente 6 dígitos numéricos
- Pattern: `/^\d{6}$/`

## Fluxo

1. Usuário preenche email e senha
2. Submit → `login(credentials)`
3. Se backend retornar `needsMFA: true`:
   - Mostrar campo MFA
   - Usuário digita código de 6 dígitos
   - Submit → `loginWithMFA(credentials, totpCode)`
4. Se sucesso → Redirect para /dashboard
5. Se erro → Mostrar mensagem

## Auto-redirect

Usuários já autenticados são automaticamente redirecionados:

```javascript
useEffect(() => {
  if (isAuthenticated) {
    navigate('/dashboard', { replace: true })
  }
}, [isAuthenticated])
