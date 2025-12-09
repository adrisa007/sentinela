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
