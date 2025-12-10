import { createContext, useContext, useState, useEffect } from 'react'

/**
 * Context de Autenticação - adrisa007/sentinela (ID: 1112237272)
 */

const AuthContext = createContext({})

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Verificar se há usuário no localStorage
    checkAuth()
  }, [])

  const checkAuth = () => {
    try {
      const token = localStorage.getItem('token')
      const storedUser = localStorage.getItem('user')
      
      console.log('[AuthContext] Verificando auth:', { token: !!token, user: !!storedUser })
      
      if (token && storedUser) {
        const userData = JSON.parse(storedUser)
        console.log('[AuthContext] Usuário encontrado:', userData)
        setUser(userData)
      } else {
        console.log('[AuthContext] Nenhum usuário encontrado')
        setUser(null)
      }
    } catch (error) {
      console.error('[AuthContext] Erro ao carregar usuário:', error)
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      setUser(null)
    } finally {
      setLoading(false)
    }
  }

  const login = (userData, token) => {
    console.log('[AuthContext] Login:', { userData, token })
    
    // Salvar no localStorage
    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(userData))
    
    // Atualizar estado
    setUser(userData)
    
    console.log('[AuthContext] Login completo, user:', userData)
  }

  const logout = () => {
    console.log('[AuthContext] Logout')
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    setUser(null)
  }

  const value = {
    user,
    loading,
    login,
    logout,
    isAuthenticated: !!user
  }

  console.log('[AuthContext] Context value:', value)

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

export default AuthContext
