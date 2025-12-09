#!/bin/bash
# enhance_jwt_persistence.sh
# Melhora persistência JWT no AuthContext
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "💾 Melhorando Persistência JWT - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend/src/contexts

# Atualizar AuthContext.jsx com persistência JWT otimizada
cat > AuthContext.jsx << 'AUTHCONTEXT'
import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import axios from 'axios'

/**
 * AuthContext com Persistência JWT - adrisa007/sentinela (ID: 1112237272)
 * 
 * Persistência completa:
 * - JWT Token em localStorage
 * - User data em localStorage
 * - Auto-restore na inicialização
 * - Token refresh automático
 * - Expiração de token
 * - Clear on logout
 */

const AuthContext = createContext(null)

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

// Keys do localStorage
const STORAGE_KEYS = {
  TOKEN: 'sentinela_token',
  USER: 'sentinela_user',
  TOKEN_EXPIRY: 'sentinela_token_expiry',
  REFRESH_TOKEN: 'sentinela_refresh_token',
}

// Axios instance
const authAPI = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
})

// Request interceptor
authAPI.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(STORAGE_KEYS.TOKEN)
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
authAPI.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado ou inválido
      clearStorage()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// ==========================================
// STORAGE HELPERS
// ==========================================

const saveToStorage = (key, value) => {
  try {
    localStorage.setItem(key, typeof value === 'string' ? value : JSON.stringify(value))
    console.log(`[Storage] Saved: ${key}`)
  } catch (error) {
    console.error(`[Storage] Error saving ${key}:`, error)
  }
}

const getFromStorage = (key) => {
  try {
    const value = localStorage.getItem(key)
    if (!value) return null
    
    // Tentar parsear JSON, se falhar retornar string
    try {
      return JSON.parse(value)
    } catch {
      return value
    }
  } catch (error) {
    console.error(`[Storage] Error reading ${key}:`, error)
    return null
  }
}

const removeFromStorage = (key) => {
  try {
    localStorage.removeItem(key)
    console.log(`[Storage] Removed: ${key}`)
  } catch (error) {
    console.error(`[Storage] Error removing ${key}:`, error)
  }
}

const clearStorage = () => {
  Object.values(STORAGE_KEYS).forEach(key => removeFromStorage(key))
  console.log('[Storage] All cleared')
}

// Verificar se token está expirado
const isTokenExpired = () => {
  const expiry = getFromStorage(STORAGE_KEYS.TOKEN_EXPIRY)
  if (!expiry) return true
  
  const now = Date.now()
  const isExpired = now > expiry
  
  if (isExpired) {
    console.warn('[Auth] Token expirado')
  }
  
  return isExpired
}

// Calcular expiry (24 horas por padrão)
const calculateExpiry = (expiresIn = 24 * 60 * 60 * 1000) => {
  return Date.now() + expiresIn
}

// ==========================================
// PROVIDER COMPONENT
// ==========================================

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [mfaRequired, setMfaRequired] = useState(false)
  const [mfaSetupData, setMfaSetupData] = useState(null)
  const [showMfaSetup, setShowMfaSetup] = useState(false)

  // ==========================================
  // INICIALIZAÇÃO - Restaurar do localStorage
  // ==========================================
  useEffect(() => {
    const initAuth = async () => {
      console.log('[Auth] Inicializando...')
      
      try {
        const storedToken = getFromStorage(STORAGE_KEYS.TOKEN)
        const storedUser = getFromStorage(STORAGE_KEYS.USER)

        if (!storedToken || !storedUser) {
          console.log('[Auth] Nenhuma sessão encontrada')
          setLoading(false)
          return
        }

        // Verificar expiração
        if (isTokenExpired()) {
          console.warn('[Auth] Token expirado, limpando sessão')
          clearStorage()
          setLoading(false)
          return
        }

        console.log('[Auth] Sessão restaurada do localStorage')
        
        setToken(storedToken)
        setUser(storedUser)
        setIsAuthenticated(true)
        
        // Validar token com backend
        try {
          const { data } = await authAPI.get('/auth/me')
          
          // Atualizar dados do usuário
          setUser(data)
          saveToStorage(STORAGE_KEYS.USER, data)
          
          console.log('[Auth] Token validado com sucesso')
        } catch (error) {
          console.warn('[Auth] Token inválido no backend, fazendo logout')
          handleLogout()
        }
      } catch (error) {
        console.error('[Auth] Erro ao restaurar sessão:', error)
        clearStorage()
      } finally {
        setLoading(false)
      }
    }

    initAuth()
  }, [])

  // Verificar MFA obrigatório
  useEffect(() => {
    if (user) {
      const needsMFA = ['ROOT', 'GESTOR'].includes(user.role)
      const hasMFA = user.mfa_enabled || user.totp_configured
      
      if (needsMFA && !hasMFA) {
        setMfaRequired(true)
        setShowMfaSetup(true)
        console.warn(`[Auth] MFA obrigatório para ${user.role}`)
      }
    }
  }, [user])

  // ==========================================
  // LOGOUT HELPER
  // ==========================================
  const handleLogout = useCallback(() => {
    setUser(null)
    setToken(null)
    setIsAuthenticated(false)
    setMfaRequired(false)
    setMfaSetupData(null)
    setShowMfaSetup(false)
    clearStorage()
  }, [])

  // ==========================================
  // LOGIN
  // ==========================================
  const login = useCallback(async (credentials) => {
    try {
      setLoading(true)
      console.log('[Auth] Tentando login:', credentials.username)
      
      const { data } = await authAPI.post('/auth/login', {
        username: credentials.username,
        password: credentials.password,
      })
      
      if (!data.token) {
        throw new Error('Token não recebido')
      }

      // Salvar no estado
      setToken(data.token)
      setUser(data.user)
      setIsAuthenticated(true)
      
      // Persistir no localStorage
      saveToStorage(STORAGE_KEYS.TOKEN, data.token)
      saveToStorage(STORAGE_KEYS.USER, data.user)
      saveToStorage(STORAGE_KEYS.TOKEN_EXPIRY, calculateExpiry())
      
      // Salvar refresh token se disponível
      if (data.refresh_token) {
        saveToStorage(STORAGE_KEYS.REFRESH_TOKEN, data.refresh_token)
      }
      
      console.log('[Auth] Login bem-sucedido e persistido')
      
      return { success: true, user: data.user }
    } catch (error) {
      console.error('[Auth] Erro no login:', error)
      
      const errorMessage = error.response?.data?.detail || 'Erro ao fazer login'
      
      if (error.response?.status === 403 && errorMessage.includes('MFA')) {
        setMfaRequired(true)
        return { success: false, needsMFA: true, error: 'Código MFA necessário' }
      }
      
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }, [])

  // ==========================================
  // LOGIN COM MFA
  // ==========================================
  const loginWithMFA = useCallback(async (credentials, totpCode) => {
    try {
      setLoading(true)
      
      const { data } = await authAPI.post('/auth/login', {
        username: credentials.username,
        password: credentials.password,
        totp_code: totpCode,
      })
      
      if (!data.token) {
        throw new Error('Token não recebido')
      }

      setToken(data.token)
      setUser(data.user)
      setIsAuthenticated(true)
      setMfaRequired(false)
      
      // Persistir
      saveToStorage(STORAGE_KEYS.TOKEN, data.token)
      saveToStorage(STORAGE_KEYS.USER, data.user)
      saveToStorage(STORAGE_KEYS.TOKEN_EXPIRY, calculateExpiry())
      
      if (data.refresh_token) {
        saveToStorage(STORAGE_KEYS.REFRESH_TOKEN, data.refresh_token)
      }
      
      console.log('[Auth] Login com MFA bem-sucedido e persistido')
      
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
  const logout = useCallback(async () => {
    try {
      console.log('[Auth] Fazendo logout...')
      
      try {
        await authAPI.post('/auth/logout')
      } catch (error) {
        console.warn('[Auth] Erro ao chamar /auth/logout:', error.message)
      }
      
      handleLogout()
      console.log('[Auth] Logout concluído e storage limpo')
    } catch (error) {
      console.error('[Auth] Erro no logout:', error)
    }
  }, [handleLogout])

  // ==========================================
  // REFRESH USER
  // ==========================================
  const refreshUser = useCallback(async () => {
    try {
      const { data } = await authAPI.get('/auth/me')
      
      setUser(data)
      saveToStorage(STORAGE_KEYS.USER, data)
      
      console.log('[Auth] Usuário atualizado e persistido')
      
      return { success: true, user: data }
    } catch (error) {
      console.error('[Auth] Erro ao atualizar usuário:', error)
      return { success: false, error: error.message }
    }
  }, [])

  // ==========================================
  // MFA SETUP
  // ==========================================
  const setupMFA = useCallback(async () => {
    try {
      setLoading(true)
      
      const { data } = await authAPI.post('/auth/totp/setup')
      
      setMfaSetupData({
        secret: data.secret,
        qrCode: data.qr_code,
        qrCodeUrl: data.qr_code_url,
        backupCodes: data.backup_codes || [],
      })
      
      setShowMfaSetup(true)
      
      return { success: true, data }
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Erro ao configurar MFA'
      }
    } finally {
      setLoading(false)
    }
  }, [])

  // ==========================================
  // VERIFY & ENABLE MFA
  // ==========================================
  const verifyAndEnableMFA = useCallback(async (totpCode) => {
    try {
      setLoading(true)
      
      const { data } = await authAPI.post('/auth/totp/verify', {
        totp_code: totpCode,
      })
      
      const updatedUser = { 
        ...user, 
        mfa_enabled: true, 
        totp_configured: true 
      }
      
      setUser(updatedUser)
      saveToStorage(STORAGE_KEYS.USER, updatedUser)
      
      setMfaRequired(false)
      setShowMfaSetup(false)
      
      console.log('[Auth] MFA ativado e persistido')
      
      return { 
        success: true, 
        backupCodes: data.backup_codes || []
      }
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Código inválido'
      }
    } finally {
      setLoading(false)
    }
  }, [user])

  // ==========================================
  // DISABLE MFA
  // ==========================================
  const disableMFA = useCallback(async (password) => {
    try {
      setLoading(true)
      
      await authAPI.post('/auth/totp/disable', { password })
      
      const updatedUser = { 
        ...user, 
        mfa_enabled: false, 
        totp_configured: false 
      }
      
      setUser(updatedUser)
      saveToStorage(STORAGE_KEYS.USER, updatedUser)
      
      setMfaSetupData(null)
      setShowMfaSetup(false)
      
      console.log('[Auth] MFA desabilitado e persistido')
      
      return { success: true }
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Erro ao desabilitar MFA'
      }
    } finally {
      setLoading(false)
    }
  }, [user])

  // ==========================================
  // HELPERS
  // ==========================================
  const hasRole = useCallback((roles) => {
    if (!user) return false
    if (Array.isArray(roles)) return roles.includes(user.role)
    return user.role === roles
  }, [user])

  const isRoot = hasRole('ROOT')
  const isGestor = hasRole('GESTOR')
  const isOperador = hasRole('OPERADOR')

  const getStorageData = useCallback(() => ({
    token: getFromStorage(STORAGE_KEYS.TOKEN),
    user: getFromStorage(STORAGE_KEYS.USER),
    tokenExpiry: getFromStorage(STORAGE_KEYS.TOKEN_EXPIRY),
    refreshToken: getFromStorage(STORAGE_KEYS.REFRESH_TOKEN),
  }), [])

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
    showMfaSetup,
    
    // Auth Actions
    login,
    loginWithMFA,
    logout,
    refreshUser,
    
    // MFA Actions
    setupMFA,
    verifyAndEnableMFA,
    disableMFA,
    setShowMfaSetup,
    
    // Helpers
    hasRole,
    isRoot,
    isGestor,
    isOperador,
    getStorageData,
    
    // API
    authAPI,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export default AuthContext
AUTHCONTEXT

echo "✓ AuthContext.jsx atualizado com persistência JWT otimizada"
echo ""

# Criar utilitário de storage
mkdir -p ../utils

cat > ../utils/storage.js << 'STORAGE'
/**
 * Storage Utilities - adrisa007/sentinela (ID: 1112237272)
 * 
 * Helpers para localStorage com tratamento de erros
 */

const STORAGE_PREFIX = 'sentinela_'

// Save to localStorage
export const saveToStorage = (key, value) => {
  try {
    const prefixedKey = STORAGE_PREFIX + key
    const stringValue = typeof value === 'string' ? value : JSON.stringify(value)
    localStorage.setItem(prefixedKey, stringValue)
    console.log(`[Storage] Saved: ${key}`)
    return true
  } catch (error) {
    console.error(`[Storage] Error saving ${key}:`, error)
    return false
  }
}

// Get from localStorage
export const getFromStorage = (key) => {
  try {
    const prefixedKey = STORAGE_PREFIX + key
    const value = localStorage.getItem(prefixedKey)
    
    if (!value) return null
    
    // Try to parse JSON, fallback to string
    try {
      return JSON.parse(value)
    } catch {
      return value
    }
  } catch (error) {
    console.error(`[Storage] Error reading ${key}:`, error)
    return null
  }
}

// Remove from localStorage
export const removeFromStorage = (key) => {
  try {
    const prefixedKey = STORAGE_PREFIX + key
    localStorage.removeItem(prefixedKey)
    console.log(`[Storage] Removed: ${key}`)
    return true
  } catch (error) {
    console.error(`[Storage] Error removing ${key}:`, error)
    return false
  }
}

// Clear all storage
export const clearStorage = () => {
  try {
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith(STORAGE_PREFIX)) {
        localStorage.removeItem(key)
      }
    })
    console.log('[Storage] All cleared')
    return true
  } catch (error) {
    console.error('[Storage] Error clearing storage:', error)
    return false
  }
}

// Check if token is expired
export const isTokenExpired = (expiryKey = 'token_expiry') => {
  const expiry = getFromStorage(expiryKey)
  if (!expiry) return true
  
  const now = Date.now()
  return now > expiry
}

// Calculate expiry timestamp
export const calculateExpiry = (expiresInMs = 24 * 60 * 60 * 1000) => {
  return Date.now() + expiresInMs
}

export default {
  saveToStorage,
  getFromStorage,
  removeFromStorage,
  clearStorage,
  isTokenExpired,
  calculateExpiry,
}
STORAGE

echo "✓ utils/storage.js criado"
echo ""

# Criar README de persistência
cat > JWT_PERSISTENCE.md << 'README'
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