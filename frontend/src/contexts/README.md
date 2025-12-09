# AuthContext - adrisa007/sentinela (ID: 1112237272)

## Features

- ✅ Login/Logout com JWT
- ✅ MFA (TOTP) obrigatório para ROOT e GESTOR
- ✅ Persistência de sessão (localStorage)
- ✅ Integração automática com axios
- ✅ Refresh de token
- ✅ Role-based access control

## Uso

```jsx
import { useAuth } from '@contexts/AuthContext'

function MyComponent() {
  const { 
    user, 
    isAuthenticated, 
    login, 
    logout,
    mfaRequired,
    setupMFA 
  } = useAuth()

  // Login
  const handleLogin = async () => {
    const result = await login({ username, password })
    if (result.needsMFA) {
      // Mostrar campo de MFA
    }
  }

  // Verificar role
  if (user?.role === 'ROOT') {
    // Acesso administrativo
  }

  return <div>{user?.username}</div>
}
