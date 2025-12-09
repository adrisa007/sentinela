# Contexts - adrisa007/sentinela (ID: 1112237272)

React Contexts para gerenciamento de estado global.

## 📦 Contexts Disponíveis

### 1. AuthContext
Gerencia autenticação, login, logout e sessão.

```jsx
import { useAuth } from '@contexts/AuthContext'

function MyComponent() {
  const { user, isAuthenticated, login, logout } = useAuth()
  
  return (
    <div>
      {isAuthenticated ? (
        <div>
          <p>Olá, {user?.username}</p>
          <button onClick={logout}>Sair</button>
        </div>
      ) : (
        <button onClick={() => login({ username, password })}>
          Login
        </button>
      )}
    </div>
  )
}
