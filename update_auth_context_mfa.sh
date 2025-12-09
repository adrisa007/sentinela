#!/bin/bash
# update_auth_context_mfa.sh
# Atualiza AuthContext com MFA TOTP completo
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔐 Atualizando AuthContext com MFA TOTP - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend/src/contexts

# Atualizar AuthContext.jsx com MFA TOTP
cat > AuthContext.jsx << 'AUTHCONTEXT'
import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import axios from 'axios'

/**
 * AuthContext com MFA TOTP - adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Login/Logout
 * - JWT Token Management
 * - MFA TOTP (Setup, Verify, Disable)
 * - QR Code para Google Authenticator
 * - Backup Codes
 * - Session Persistence
 * - Role-based Access Control
 * 
 * Backend: https://web-production-8355.up.railway.app
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

// Axios instance
const authAPI = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
})

// Request interceptor
authAPI.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    console.log(`[Auth API] ${config.method?.toUpperCase()} ${config.url}`)
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
authAPI.interceptors.response.use(
  (response) => {
    console.log(`[Auth API] ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('[Auth API] Error:', error.response?.status, error.message)
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  
  // MFA State
  const [mfaRequired, setMfaRequired] = useState(false)
  const [mfaSetupData, setMfaSetupData] = useState(null)
  const [showMfaSetup, setShowMfaSetup] = useState(false)

  // ==========================================
  // INICIALIZAÇÃO
  // ==========================================
  useEffect(() => {
    const initAuth = async () => {
      try {
        const storedToken = localStorage.getItem('token')
        const storedUser = localStorage.getItem('user')

        if (storedToken && storedUser) {
          setToken(storedToken)
          const userData = JSON.parse(storedUser)
          setUser(userData)
          setIsAuthenticated(true)
          
          console.log('[Auth] Sessão restaurada')
          
          // Validar token
          try {
            const { data } = await authAPI.get('/auth/me')
            setUser(data)
            localStorage.setItem('user', JSON.stringify(data))
          } catch (error) {
            console.warn('[Auth] Token inválido')
            handleLogout()
          }
        }
      } catch (error) {
        console.error('[Auth] Erro ao restaurar sessão:', error)
      } finally {
        setLoading(false)
      }
    }

    initAuth()
  }, [])

  // Verificar se MFA é obrigatório
  useEffect(() => {
    if (user) {
      const needsMFA = ['ROOT', 'GESTOR'].includes(user.role)
      const hasMFA = user.mfa_enabled || user.totp_configured
      
      if (needsMFA && !hasMFA) {
        setMfaRequired(true)
        setShowMfaSetup(true)
        console.warn(`[Auth] MFA obrigatório para ${user.role}`)
      } else {
        setMfaRequired(false)
        setShowMfaSetup(false)
      }
    }
  }, [user])

  const handleLogout = () => {
    setUser(null)
    setToken(null)
    setIsAuthenticated(false)
    setMfaRequired(false)
    setMfaSetupData(null)
    setShowMfaSetup(false)
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

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

      setToken(data.token)
      setUser(data.user)
      setIsAuthenticated(true)
      
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      
      console.log('[Auth] Login bem-sucedido')
      
      return { success: true, user: data.user }
    } catch (error) {
      console.error('[Auth] Erro no login:', error)
      
      const errorMessage = error.response?.data?.detail || 'Erro ao fazer login'
      
      // Verificar se precisa MFA
      if (error.response?.status === 403 && errorMessage.includes('MFA')) {
        setMfaRequired(true)
        return {
          success: false,
          needsMFA: true,
          error: 'Código MFA necessário',
        }
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
      console.log('[Auth] Login com MFA')
      
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
      
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      
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
  const logout = useCallback(async () => {
    try {
      console.log('[Auth] Fazendo logout')
      
      try {
        await authAPI.post('/auth/logout')
      } catch (error) {
        console.warn('[Auth] Erro ao chamar /auth/logout:', error.message)
      }
      
      handleLogout()
      console.log('[Auth] Logout concluído')
    } catch (error) {
      console.error('[Auth] Erro no logout:', error)
    }
  }, [])

  // ==========================================
  // MFA TOTP - SETUP
  // ==========================================
  const setupMFA = useCallback(async () => {
    try {
      setLoading(true)
      console.log('[Auth] Iniciando setup MFA TOTP')
      
      const { data } = await authAPI.post('/auth/totp/setup')
      
      setMfaSetupData({
        secret: data.secret,
        qrCode: data.qr_code,
        qrCodeUrl: data.qr_code_url,
        backupCodes: data.backup_codes || [],
        issuer: data.issuer || 'Sentinela',
        username: data.username || user?.username,
      })
      
      setShowMfaSetup(true)
      
      console.log('[Auth] Setup MFA iniciado com sucesso')
      
      return { 
        success: true, 
        data: {
          secret: data.secret,
          qrCode: data.qr_code,
          qrCodeUrl: data.qr_code_url,
        }
      }
    } catch (error) {
      console.error('[Auth] Erro ao configurar MFA:', error)
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Erro ao configurar MFA'
      }
    } finally {
      setLoading(false)
    }
  }, [user])

  // ==========================================
  // MFA TOTP - VERIFY & ENABLE
  // ==========================================
  const verifyAndEnableMFA = useCallback(async (totpCode) => {
    try {
      setLoading(true)
      console.log('[Auth] Verificando código TOTP')
      
      const { data } = await authAPI.post('/auth/totp/verify', {
        totp_code: totpCode,
      })
      
      // Atualizar usuário com MFA ativado
      const updatedUser = { 
        ...user, 
        mfa_enabled: true, 
        totp_configured: true 
      }
      setUser(updatedUser)
      localStorage.setItem('user', JSON.stringify(updatedUser))
      
      setMfaRequired(false)
      setShowMfaSetup(false)
      
      console.log('[Auth] MFA TOTP ativado com sucesso')
      
      return { 
        success: true, 
        backupCodes: data.backup_codes || mfaSetupData?.backupCodes || []
      }
    } catch (error) {
      console.error('[Auth] Erro ao verificar TOTP:', error)
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Código TOTP inválido'
      }
    } finally {
      setLoading(false)
    }
  }, [user, mfaSetupData])

  // ==========================================
  // MFA TOTP - DISABLE
  // ==========================================
  const disableMFA = useCallback(async (password) => {
    try {
      setLoading(true)
      console.log('[Auth] Desabilitando MFA')
      
      await authAPI.post('/auth/totp/disable', {
        password: password,
      })
      
      const updatedUser = { 
        ...user, 
        mfa_enabled: false, 
        totp_configured: false 
      }
      setUser(updatedUser)
      localStorage.setItem('user', JSON.stringify(updatedUser))
      
      setMfaSetupData(null)
      setShowMfaSetup(false)
      
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
  // MFA TOTP - GET STATUS
  // ==========================================
  const getMFAStatus = useCallback(async () => {
    try {
      const { data } = await authAPI.get('/auth/totp/status')
      return { success: true, data }
    } catch (error) {
      console.error('[Auth] Erro ao obter status MFA:', error)
      return { success: false, error: error.message }
    }
  }, [])

  // ==========================================
  // REFRESH USER
  // ==========================================
  const refreshUser = useCallback(async () => {
    try {
      const { data } = await authAPI.get('/auth/me')
      setUser(data)
      localStorage.setItem('user', JSON.stringify(data))
      return { success: true, user: data }
    } catch (error) {
      console.error('[Auth] Erro ao atualizar usuário:', error)
      return { success: false, error: error.message }
    }
  }, [])

  // ==========================================
  // HELPERS
  // ==========================================
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
    showMfaSetup,
    
    // Auth Actions
    login,
    loginWithMFA,
    logout,
    refreshUser,
    
    // MFA TOTP Actions
    setupMFA,
    verifyAndEnableMFA,
    disableMFA,
    getMFAStatus,
    setShowMfaSetup,
    
    // Helpers
    hasRole,
    isRoot,
    isGestor,
    isOperador,
    
    // API
    authAPI,
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export default AuthContext
AUTHCONTEXT

echo "✓ AuthContext.jsx atualizado com MFA TOTP"
echo ""

# Criar componente de MFA Setup
cat > ../components/MFASetup.jsx << 'MFASETUP'
import { useState } from 'react'
import { useAuth } from '@contexts/AuthContext'

/**
 * MFA Setup Component - adrisa007/sentinela (ID: 1112237272)
 * 
 * Componente para configurar MFA TOTP com QR Code
 */

function MFASetup({ onComplete, onCancel }) {
  const [totpCode, setTotpCode] = useState('')
  const [error, setError] = useState('')
  const [backupCodes, setBackupCodes] = useState([])
  const [step, setStep] = useState('qrcode') // 'qrcode' | 'verify' | 'backup'
  
  const { mfaSetupData, verifyAndEnableMFA, loading } = useAuth()

  const handleVerify = async (e) => {
    e.preventDefault()
    setError('')

    if (totpCode.length !== 6) {
      setError('O código deve ter 6 dígitos')
      return
    }

    const result = await verifyAndEnableMFA(totpCode)

    if (result.success) {
      setBackupCodes(result.backupCodes || [])
      setStep('backup')
    } else {
      setError(result.error)
      setTotpCode('')
    }
  }

  const handleComplete = () => {
    if (onComplete) onComplete()
  }

  // Step 1: QR Code
  if (step === 'qrcode' && mfaSetupData) {
    return (
      <div className="card max-w-lg mx-auto">
        <div className="card-body space-y-6">
          <div className="text-center">
            <div className="text-5xl mb-4">🔐</div>
            <h2 className="text-2xl font-bold mb-2">Configurar MFA (2FA)</h2>
            <p className="text-gray-600">
              Escaneie o QR Code com seu aplicativo autenticador
            </p>
          </div>

          {/* QR Code */}
          <div className="bg-white p-6 rounded-lg border-2 border-gray-200 flex justify-center">
            {mfaSetupData.qrCode ? (
              <img 
                src={`data:image/png;base64,${mfaSetupData.qrCode}`}
                alt="QR Code MFA"
                className="w-64 h-64"
              />
            ) : (
              <div className="w-64 h-64 flex items-center justify-center bg-gray-100">
                <p className="text-gray-400">Carregando QR Code...</p>
              </div>
            )}
          </div>

          {/* Secret Manual */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <p className="text-sm text-gray-600 mb-2">
              Ou digite manualmente:
            </p>
            <code className="block p-2 bg-white border rounded text-center font-mono text-sm break-all">
              {mfaSetupData.secret}
            </code>
          </div>

          {/* Aplicativos Sugeridos */}
          <div className="text-sm text-gray-600">
            <p className="font-semibold mb-2">Aplicativos recomendados:</p>
            <ul className="list-disc list-inside space-y-1">
              <li>Google Authenticator</li>
              <li>Microsoft Authenticator</li>
              <li>Authy</li>
            </ul>
          </div>

          <button
            onClick={() => setStep('verify')}
            className="btn-primary w-full"
          >
            Continuar →
          </button>

          {onCancel && (
            <button
              onClick={onCancel}
              className="btn-ghost w-full"
            >
              Cancelar
            </button>
          )}
        </div>
      </div>
    )
  }

  // Step 2: Verify Code
  if (step === 'verify') {
    return (
      <div className="card max-w-md mx-auto">
        <div className="card-body space-y-6">
          <div className="text-center">
            <div className="text-5xl mb-4">🔢</div>
            <h2 className="text-2xl font-bold mb-2">Verificar Código</h2>
            <p className="text-gray-600">
              Digite o código de 6 dígitos do seu aplicativo
            </p>
          </div>

          <form onSubmit={handleVerify} className="space-y-4">
            <div>
              <label className="form-label">Código TOTP</label>
              <input
                type="text"
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, ''))}
                maxLength="6"
                className="form-input text-center text-2xl tracking-widest"
                placeholder="000000"
                required
                autoFocus
                disabled={loading}
              />
              {error && (
                <p className="form-error">{error}</p>
              )}
            </div>

            <div className="flex space-x-3">
              <button
                type="button"
                onClick={() => setStep('qrcode')}
                className="btn-ghost flex-1"
                disabled={loading}
              >
                ← Voltar
              </button>
              <button
                type="submit"
                className="btn-primary flex-1"
                disabled={loading || totpCode.length !== 6}
              >
                {loading ? 'Verificando...' : 'Verificar'}
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  // Step 3: Backup Codes
  if (step === 'backup' && backupCodes.length > 0) {
    return (
      <div className="card max-w-md mx-auto">
        <div className="card-body space-y-6">
          <div className="text-center">
            <div className="text-5xl mb-4">✅</div>
            <h2 className="text-2xl font-bold mb-2">MFA Configurado!</h2>
            <p className="text-gray-600">
              Guarde seus códigos de backup em local seguro
            </p>
          </div>

          <div className="bg-warning-50 border-2 border-warning-200 p-4 rounded-lg">
            <p className="text-sm text-warning-800 font-semibold mb-2">
              ⚠️ Importante:
            </p>
            <p className="text-sm text-warning-700">
              Estes códigos podem ser usados se você perder acesso ao seu aplicativo autenticador.
              Cada código só pode ser usado uma vez.
            </p>
          </div>

          <div className="bg-gray-50 p-4 rounded-lg space-y-2">
            {backupCodes.map((code, index) => (
              <div
                key={index}
                className="bg-white p-3 rounded border font-mono text-center"
              >
                {code}
              </div>
            ))}
          </div>

          <button
            onClick={handleComplete}
            className="btn-primary w-full"
          >
            Concluir
          </button>
        </div>
      </div>
    )
  }

  return null
}

export default MFASetup
MFASETUP

echo "✓ MFASetup.jsx criado"
echo ""

# Atualizar README com MFA
cat > AuthContext.README.md << 'README'
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