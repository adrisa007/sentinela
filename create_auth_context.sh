#!/bin/bash
# create_auth_context.sh
# Cria AuthContext completo para adrisa007/sentinela (ID: 1112237272)

echo "🔐 Criando AuthContext - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd frontend

# 1. Criar src/contexts/AuthContext.jsx
echo "📁 Criando src/contexts/AuthContext.jsx..."

cat > src/contexts/AuthContext.jsx << 'AUTHCONTEXT'
import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import api from '@services/api'

/**
 * AuthContext para adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Login/Logout
 * - MFA (TOTP) Setup
 * - JWT Token Management
 * - Axios Integration
 * - Role-based Access (ROOT, GESTOR, OPERADOR)
 * - MFA Required for ROOT and GESTOR
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
  const [mfaRequired, setMfaRequired] = useState(false)
  const [mfaSetupData, setMfaSetupData] = useState(null)

  // ==========================================
  // INICIALIZAÇÃO - Restaurar sessão do localStorage
  // ==========================================
  useEffect(() => {
    const initAuth = async () => {
      try {
        const storedToken = localStorage.getItem('token')
        const storedUser = localStorage.getItem('user')

        if (storedToken && storedUser) {
          setToken(storedToken)
          setUser(JSON.parse(storedUser))
          
          // Configurar token no axios
          api.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`
          
          // Verificar se token ainda é válido
          try {
            const { data } = await api.get('/auth/me')
            setUser(data)
            localStorage.setItem('user', JSON.stringify(data))
          } catch (error) {
            // Token inválido, fazer logout
            console.warn('Token inválido, fazendo logout')
            handleLogout()
          }
        }
      } catch (error) {
        console.error('Erro ao restaurar sessão:', error)
      } finally {
        setLoading(false)
      }
    }

    initAuth()
  }, [])

  // ==========================================
  // VERIFICAR SE MFA É NECESSÁRIO
  // ==========================================
  useEffect(() => {
    if (user) {
      const needsMFA = ['ROOT', 'GESTOR'].includes(user.role)
      const hasMFA = user.mfa_enabled || user.totp_configured
      
      if (needsMFA && !hasMFA) {
        setMfaRequired(true)
        console.warn(`[Auth] MFA obrigatório para ${user.role}`)
      } else {
        setMfaRequired(false)
      }
    }
  }, [user])

  // ==========================================
  // LOGIN
  // ==========================================
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
      
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      
      // Configurar axios
      api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`
      
      console.log('[Auth] Login bem-sucedido:', data.user.username)
      
      return { success: true, user: data.user }
    } catch (error) {
      console.error('[Auth] Erro no login:', error)
      
      const errorMessage = error.response?.data?.detail || 'Erro ao fazer login'
      
      return { 
        success: false, 
        error: errorMessage,
        needsMFA: error.response?.status === 403 && errorMessage.includes('MFA')
      }
    } finally {
      setLoading(false)
    }
  }, [])

  // ==========================================
  // LOGIN COM MFA (TOTP)
  // ==========================================
  const loginWithMFA = useCallback(async (credentials, totpCode) => {
    try {
      setLoading(true)
      
      const { data } = await api.post('/auth/login', {
        ...credentials,
        totp_code: totpCode,
      })
      
      if (!data.token) {
        throw new Error('Token não recebido')
      }

      setToken(data.token)
      setUser(data.user)
      
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      
      api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`
      
      console.log('[Auth] Login com MFA bem-sucedido')
      
      return { success: true, user: data.user }
    } catch (error) {
      console.error('[Auth] Erro no login com MFA:', error)
      
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Código MFA inválido'
      }
    } finally {
      setLoading(false)
    }
  }, [])

  // ==========================================
  // LOGOUT
  // ==========================================
  const logout = useCallback(() => {
    try {
      // Limpar estado
      setUser(null)
      setToken(null)
      setMfaRequired(false)
      setMfaSetupData(null)
      
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

  // ==========================================
  // SETUP MFA - Gerar QR Code
  // ==========================================
  const setupMFA = useCallback(async () => {
    try {
      setLoading(true)
      
      const { data } = await api.post('/auth/mfa/setup')
      
      setMfaSetupData({
        secret: data.secret,
        qrCode: data.qr_code,
        backupCodes: data.backup_codes || [],
      })
      
      console.log('[Auth] MFA setup iniciado')
      
      return { success: true, data }
    } catch (error) {
      console.error('[Auth] Erro ao configurar MFA:', error)
      
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Erro ao configurar MFA'
      }
    } finally {
      setLoading(false)
    }
  }, [])

  // ==========================================
  // VERIFICAR E ATIVAR MFA
  // ==========================================
  const verifyAndEnableMFA = useCallback(async (totpCode) => {
    try {
      setLoading(true)
      
      const { data } = await api.post('/auth/mfa/verify', {
        totp_code: totpCode,
      })
      
      // Atualizar usuário com MFA ativado
      const updatedUser = { ...user, mfa_enabled: true, totp_configured: true }
      setUser(updatedUser)
      localStorage.setItem('user', JSON.stringify(updatedUser))
      
      setMfaRequired(false)
      setMfaSetupData(null)
      
      console.log('[Auth] MFA ativado com sucesso')
      
      return { success: true, backupCodes: data.backup_codes }
    } catch (error) {
      console.error('[Auth] Erro ao verificar MFA:', error)
      
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Código MFA inválido'
      }
    } finally {
      setLoading(false)
    }
  }, [user])

  // ==========================================
  // DESABILITAR MFA
  // ==========================================
  const disableMFA = useCallback(async (password) => {
    try {
      setLoading(true)
      
      await api.post('/auth/mfa/disable', { password })
      
      const updatedUser = { ...user, mfa_enabled: false, totp_configured: false }
      setUser(updatedUser)
      localStorage.setItem('user', JSON.stringify(updatedUser))
      
      console.log('[Auth] MFA desabilitado')
      
      return { success: true }
    } catch (error) {
      console.error('[Auth] Erro ao desabilitar MFA:', error)
      
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Erro ao desabilitar MFA'
      }
    } finally {
      setLoading(false)
    }
  }, [user])

  // ==========================================
  // REFRESH USER DATA
  // ==========================================
  const refreshUser = useCallback(async () => {
    try {
      const { data } = await api.get('/auth/me')
      setUser(data)
      localStorage.setItem('user', JSON.stringify(data))
      return { success: true, user: data }
    } catch (error) {
      console.error('[Auth] Erro ao atualizar dados do usuário:', error)
      return { success: false, error: error.message }
    }
  }, [])

  // ==========================================
  // HELPERS
  // ==========================================
  const isAuthenticated = !!user && !!token
  
  const hasRole = useCallback((roles) => {
    if (!user) return false
    if (Array.isArray(roles)) {
      return roles.includes(user.role)
    }
    return user.role === roles
  }, [user])
  
  const isRoot = hasRole('ROOT')
  const isGestor = hasRole('GESTOR')
  const isOperador = hasRole('OPERADOR')

  // ==========================================
  // CONTEXT VALUE
  // ==========================================
  const value = {
    // State
    user,
    token,
    loading,
    isAuthenticated,
    mfaRequired,
    mfaSetupData,
    
    // Actions
    login,
    loginWithMFA,
    logout,
    setupMFA,
    verifyAndEnableMFA,
    disableMFA,
    refreshUser,
    
    // Helpers
    hasRole,
    isRoot,
    isGestor,
    isOperador,
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export default AuthContext
AUTHCONTEXT

echo "✓ AuthContext.jsx criado"

# 2. Atualizar src/services/api.js para usar token do context
echo "🔌 Atualizando src/services/api.js..."

cat > src/services/api.js << 'APISERVICE'
import axios from 'axios'

/**
 * API Client para adrisa007/sentinela (ID: 1112237272)
 * Backend: https://web-production-8355.up.railway.app
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor - adiciona token automaticamente
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor - trata erros de autenticação
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token inválido ou expirado
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// ==========================================
// AUTH ENDPOINTS
// ==========================================

export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  logout: () => api.post('/auth/logout'),
  me: () => api.get('/auth/me'),
  setupMFA: () => api.post('/auth/mfa/setup'),
  verifyMFA: (totpCode) => api.post('/auth/mfa/verify', { totp_code: totpCode }),
  disableMFA: (password) => api.post('/auth/mfa/disable', { password }),
}

// ==========================================
// HEALTH ENDPOINTS
// ==========================================

export const fetchHealth = async () => {
  const { data } = await api.get('/health')
  return data
}

export const fetchHealthLive = async () => {
  const { data } = await api.get('/health/live')
  return data
}

export const fetchHealthReady = async () => {
  const { data } = await api.get('/health/ready')
  return data
}

export const fetchHealthNeon = async () => {
  const { data } = await api.get('/health/neon')
  return data
}

export const fetchRoot = async () => {
  const { data } = await api.get('/')
  return data
}

export default api
APISERVICE

echo "✓ api.js atualizado"

# 3. Atualizar src/main.jsx para incluir AuthProvider
echo "⚛️  Atualizando src/main.jsx..."

cat > src/main.jsx << 'MAINJSX'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { AuthProvider } from '@contexts/AuthContext'
import App from './App.jsx'
import './index.css'

console.log('🛡️ Sentinela Frontend')
console.log('Repository: adrisa007/sentinela (ID: 1112237272)')
console.log('API: https://web-production-8355.up.railway.app')

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <App />
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>,
)
MAINJSX

echo "✓ main.jsx atualizado"

# 4. Criar página de Login como exemplo
echo "🔐 Criando src/pages/LoginPage.jsx..."

cat > src/pages/LoginPage.jsx << 'LOGINPAGE'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'

function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [totpCode, setTotpCode] = useState('')
  const [needsMFA, setNeedsMFA] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  
  const { login, loginWithMFA } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      let result
      
      if (needsMFA) {
        result = await loginWithMFA({ username, password }, totpCode)
      } else {
        result = await login({ username, password })
      }

      if (result.success) {
        navigate('/dashboard')
      } else if (result.needsMFA) {
        setNeedsMFA(true)
        setError('Digite o código MFA do seu aplicativo autenticador')
      } else {
        setError(result.error)
      }
    } catch (err) {
      setError('Erro inesperado. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
      <div className="card w-full max-w-md">
        <div className="text-center mb-8">
          <div className="text-6xl mb-4">🛡️</div>
          <h1 className="text-3xl font-bold gradient-text">Sentinela</h1>
          <p className="text-gray-600 mt-2">Faça login para continuar</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-2">Usuário</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
              required
              disabled={loading}
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">Senha</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
              required
              disabled={loading}
            />
          </div>

          {needsMFA && (
            <div>
              <label className="block text-sm font-medium mb-2">
                Código MFA (6 dígitos)
              </label>
              <input
                type="text"
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
                placeholder="000000"
                maxLength="6"
                required
                disabled={loading}
              />
            </div>
          )}

          {error && (
            <div className="p-3 bg-red-50 text-red-600 rounded-lg text-sm">
              {error}
            </div>
          )}

          <button
            type="submit"
            className="w-full btn-primary"
            disabled={loading}
          >
            {loading ? 'Entrando...' : 'Entrar'}
          </button>
        </form>

        <p className="text-center text-sm text-gray-500 mt-6">
          adrisa007/sentinela (ID: 1112237272)
        </p>
      </div>
    </div>
  )
}

export default LoginPage
LOGINPAGE

echo "✓ LoginPage.jsx criado"

# 5. Criar componente de MFA Setup
echo "🔒 Criando src/components/MFASetup.jsx..."

cat > src/components/MFASetup.jsx << 'MFASETUP'
import { useState, useEffect } from 'react'
import { useAuth } from '@contexts/AuthContext'

function MFASetup({ onComplete }) {
  const [totpCode, setTotpCode] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [backupCodes, setBackupCodes] = useState([])
  
  const { setupMFA, verifyAndEnableMFA, mfaSetupData, user } = useAuth()

  useEffect(() => {
    if (!mfaSetupData) {
      handleSetupMFA()
    }
  }, [])

  const handleSetupMFA = async () => {
    setLoading(true)
    const result = await setupMFA()
    setLoading(false)
    
    if (!result.success) {
      setError(result.error)
    }
  }

  const handleVerify = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    const result = await verifyAndEnableMFA(totpCode)
    setLoading(false)

    if (result.success) {
      setBackupCodes(result.backupCodes || [])
      if (onComplete) onComplete()
    } else {
      setError(result.error)
    }
  }

  if (backupCodes.length > 0) {
    return (
      <div className="card max-w-md mx-auto">
        <h2 className="text-2xl font-bold mb-4">✅ MFA Configurado!</h2>
        <p className="mb-4">Guarde estes códigos de backup em local seguro:</p>
        <div className="bg-gray-100 p-4 rounded-lg space-y-2">
          {backupCodes.map((code, i) => (
            <div key={i} className="font-mono">{code}</div>
          ))}
        </div>
        <button onClick={onComplete} className="btn-primary w-full mt-4">
          Continuar
        </button>
      </div>
    )
  }

  return (
    <div className="card max-w-md mx-auto">
      <div className="text-center mb-6">
        <div className="text-5xl mb-4">🔐</div>
        <h2 className="text-2xl font-bold mb-2">Configurar MFA</h2>
        <p className="text-gray-600">
          MFA é obrigatório para usuários {user?.role}
        </p>
      </div>

      {mfaSetupData ? (
        <>
          <div className="mb-6">
            <p className="text-sm text-gray-600 mb-4">
              Escaneie o QR Code com seu aplicativo autenticador:
            </p>
            <div className="bg-white p-4 rounded-lg border-2 border-gray-200">
              <img 
                src={`data:image/png;base64,${mfaSetupData.qrCode}`} 
                alt="QR Code MFA"
                className="mx-auto"
              />
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Secret: <code className="bg-gray-100 px-2 py-1 rounded">{mfaSetupData.secret}</code>
            </p>
          </div>

          <form onSubmit={handleVerify}>
            <label className="block text-sm font-medium mb-2">
              Digite o código de 6 dígitos:
            </label>
            <input
              type="text"
              value={totpCode}
              onChange={(e) => setTotpCode(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg mb-4"
              placeholder="000000"
              maxLength="6"
              required
            />

            {error && (
              <div className="p-3 bg-red-50 text-red-600 rounded-lg text-sm mb-4">
                {error}
              </div>
            )}

            <button type="submit" className="btn-primary w-full" disabled={loading}>
              {loading ? 'Verificando...' : 'Verificar e Ativar MFA'}
            </button>
          </form>
        </>
      ) : (
        <div className="text-center py-8">
          <div className="spinner w-12 h-12 mx-auto mb-4"></div>
          <p>Gerando QR Code...</p>
        </div>
      )}
    </div>
  )
}

export default MFASetup
MFASETUP

echo "✓ MFASetup.jsx criado"

# 6. Criar README do AuthContext
cat > src/contexts/README.md << 'CONTEXTREADME'
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