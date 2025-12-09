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
