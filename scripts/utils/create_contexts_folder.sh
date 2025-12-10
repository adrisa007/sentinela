#!/bin/bash
# create_contexts_folder.sh
# Cria pasta src/contexts com React Contexts
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "📦 Criando src/contexts - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend/src

# 1. Criar pasta contexts
echo "📁 Criando pasta contexts..."
mkdir -p contexts

cd contexts

# 2. Criar AuthContext.jsx
echo "🔐 Criando AuthContext.jsx..."

cat > AuthContext.jsx << 'AUTHCONTEXT'
import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import api from '@services/api'

/**
 * AuthContext - adrisa007/sentinela (ID: 1112237272)
 * 
 * Gerencia autenticação, login, logout, MFA e JWT tokens
 */

const AuthContext = createContext(null)

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)
  const [isAuthenticated, setIsAuthenticated] = useState(false)

  // Restaurar sessão do localStorage
  useEffect(() => {
    const initAuth = async () => {
      try {
        const storedToken = localStorage.getItem('token')
        const storedUser = localStorage.getItem('user')

        if (storedToken && storedUser) {
          setToken(storedToken)
          setUser(JSON.parse(storedUser))
          setIsAuthenticated(true)
          
          // Configurar token no axios
          api.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`
          
          console.log('[Auth] Sessão restaurada')
        }
      } catch (error) {
        console.error('[Auth] Erro ao restaurar sessão:', error)
      } finally {
        setLoading(false)
      }
    }

    initAuth()
  }, [])

  // Login
  const login = useCallback(async (credentials) => {
    try {
      setLoading(true)
      
      const { data } = await api.post('/auth/login', credentials)
      
      if (!data.token) {
        throw new Error('Token não recebido')
      }

      // Salvar token e user
      setToken(data.token)
      setUser(data.user)
      setIsAuthenticated(true)
      
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      
      // Configurar axios
      api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`
      
      console.log('[Auth] Login bem-sucedido:', data.user.username)
      
      return { success: true, user: data.user }
    } catch (error) {
      console.error('[Auth] Erro no login:', error)
      
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Erro ao fazer login'
      }
    } finally {
      setLoading(false)
    }
  }, [])

  // Logout
  const logout = useCallback(() => {
    try {
      // Limpar estado
      setUser(null)
      setToken(null)
      setIsAuthenticated(false)
      
      // Limpar localStorage
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      
      // Remover token do axios
      delete api.defaults.headers.common['Authorization']
      
      console.log('[Auth] Logout realizado')
    } catch (error) {
      console.error('[Auth] Erro no logout:', error)
    }
  }, [])

  // Refresh user data
  const refreshUser = useCallback(async () => {
    try {
      const { data } = await api.get('/auth/me')
      setUser(data)
      localStorage.setItem('user', JSON.stringify(data))
      return { success: true, user: data }
    } catch (error) {
      console.error('[Auth] Erro ao atualizar usuário:', error)
      return { success: false, error: error.message }
    }
  }, [])

  const value = {
    user,
    token,
    loading,
    isAuthenticated,
    login,
    logout,
    refreshUser,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export default AuthContext
AUTHCONTEXT

echo "✓ AuthContext.jsx criado"

# 3. Criar ThemeContext.jsx
echo "🎨 Criando ThemeContext.jsx..."

cat > ThemeContext.jsx << 'THEMECONTEXT'
import { createContext, useContext, useState, useEffect } from 'react'

/**
 * ThemeContext - adrisa007/sentinela (ID: 1112237272)
 * 
 * Gerencia tema claro/escuro
 */

const ThemeContext = createContext(null)

export const useTheme = () => {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider')
  }
  return context
}

export const ThemeProvider = ({ children }) => {
  const [theme, setTheme] = useState('light')

  useEffect(() => {
    // Carregar tema do localStorage
    const savedTheme = localStorage.getItem('theme') || 'light'
    setTheme(savedTheme)
    applyTheme(savedTheme)
  }, [])

  const applyTheme = (newTheme) => {
    if (newTheme === 'dark') {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light'
    setTheme(newTheme)
    localStorage.setItem('theme', newTheme)
    applyTheme(newTheme)
    console.log('[Theme] Alterado para:', newTheme)
  }

  const value = {
    theme,
    toggleTheme,
    isDark: theme === 'dark',
  }

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

export default ThemeContext
THEMECONTEXT

echo "✓ ThemeContext.jsx criado"

# 4. Criar NotificationContext.jsx
echo "📢 Criando NotificationContext.jsx..."

cat > NotificationContext.jsx << 'NOTIFCONTEXT'
import { createContext, useContext, useState, useCallback } from 'react'

/**
 * NotificationContext - adrisa007/sentinela (ID: 1112237272)
 * 
 * Sistema de notificações toast
 */

const NotificationContext = createContext(null)

export const useNotification = () => {
  const context = useContext(NotificationContext)
  if (!context) {
    throw new Error('useNotification must be used within NotificationProvider')
  }
  return context
}

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([])

  const addNotification = useCallback((message, type = 'info', duration = 3000) => {
    const id = Date.now()
    const notification = { id, message, type, duration }
    
    setNotifications((prev) => [...prev, notification])
    
    // Auto-remover após duração
    if (duration > 0) {
      setTimeout(() => {
        removeNotification(id)
      }, duration)
    }
    
    return id
  }, [])

  const removeNotification = useCallback((id) => {
    setNotifications((prev) => prev.filter((notif) => notif.id !== id))
  }, [])

  // Helpers
  const success = useCallback((message, duration) => {
    return addNotification(message, 'success', duration)
  }, [addNotification])

  const error = useCallback((message, duration) => {
    return addNotification(message, 'error', duration)
  }, [addNotification])

  const warning = useCallback((message, duration) => {
    return addNotification(message, 'warning', duration)
  }, [addNotification])

  const info = useCallback((message, duration) => {
    return addNotification(message, 'info', duration)
  }, [addNotification])

  const value = {
    notifications,
    addNotification,
    removeNotification,
    success,
    error,
    warning,
    info,
  }

  return (
    <NotificationContext.Provider value={value}>
      {children}
      <NotificationContainer />
    </NotificationContext.Provider>
  )
}

// Componente de notificações
function NotificationContainer() {
  const { notifications, removeNotification } = useNotification()

  const getTypeStyles = (type) => {
    switch (type) {
      case 'success':
        return 'bg-success-50 border-success-500 text-success-800'
      case 'error':
        return 'bg-danger-50 border-danger-500 text-danger-800'
      case 'warning':
        return 'bg-warning-50 border-warning-500 text-warning-800'
      default:
        return 'bg-info-50 border-info-500 text-info-800'
    }
  }

  if (notifications.length === 0) return null

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2">
      {notifications.map((notif) => (
        <div
          key={notif.id}
          className={`p-4 border-l-4 rounded-lg shadow-lg animate-slide-in ${getTypeStyles(notif.type)}`}
        >
          <div className="flex items-center justify-between">
            <p className="font-medium">{notif.message}</p>
            <button
              onClick={() => removeNotification(notif.id)}
              className="ml-4 text-lg hover:opacity-70"
            >
              ×
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}

export default NotificationContext
NOTIFCONTEXT

echo "✓ NotificationContext.jsx criado"

# 5. Criar index.js para exports
echo "📦 Criando index.js..."

cat > index.js << 'INDEX'
/**
 * Contexts Index - adrisa007/sentinela (ID: 1112237272)
 * 
 * Export all contexts for easy imports
 */

export { AuthProvider, useAuth } from './AuthContext'
export { ThemeProvider, useTheme } from './ThemeContext'
export { NotificationProvider, useNotification } from './NotificationContext'
INDEX

echo "✓ index.js criado"

# 6. Criar README.md
echo "📚 Criando README.md..."

cat > README.md << 'README'
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