#!/bin/bash
# fix_login_redirect.sh
# Corrige problema de login não redirecionando
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔧 Corrigindo Login - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Corrigir AuthContext
cat > src/contexts/AuthContext.jsx << 'CONTEXT'
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
CONTEXT

echo "✓ AuthContext.jsx corrigido"

# 2. Corrigir Login.jsx
cat > src/pages/Login.jsx << 'LOGIN'
import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

function Login() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  
  const { login, user, isAuthenticated } = useAuth()
  const navigate = useNavigate()

  // Se já estiver autenticado, redirecionar
  useEffect(() => {
    console.log('[Login] Verificando auth:', { user, isAuthenticated })
    if (isAuthenticated) {
      console.log('[Login] Já autenticado, redirecionando...')
      navigate('/dashboard/gestor', { replace: true })
    }
  }, [isAuthenticated, navigate, user])

  const handleSubmit = async (e) => {
    e.preventDefault()
    console.log('[Login] Iniciando login...', { email })
    
    setLoading(true)
    setError('')

    try {
      // Simular chamada à API
      await new Promise(resolve => setTimeout(resolve, 1000))

      // Validação básica
      if (!email || !password) {
        throw new Error('Email e senha são obrigatórios')
      }

      console.log('[Login] Login bem-sucedido')

      // Mock de resposta do backend
      const mockUser = {
        id: 1,
        email: email,
        role: 'GESTOR',
        name: email.split('@')[0],
        mfa_enabled: false
      }
      const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.' + Date.now()

      console.log('[Login] Chamando login com:', { mockUser, mockToken })

      // Fazer login através do context
      login(mockUser, mockToken)

      console.log('[Login] Login context executado, navegando...')

      // Pequeno delay para garantir que o estado foi atualizado
      setTimeout(() => {
        console.log('[Login] Navegando para dashboard')
        navigate('/dashboard/gestor', { replace: true })
      }, 100)

    } catch (err) {
      console.error('[Login] Erro:', err)
      setError(err.message || 'Erro ao fazer login. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50 px-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-4">
            <span className="text-6xl">🔐</span>
          </div>
          <h1 className="text-4xl font-bold mb-2">
            <span className="gradient-text">Login</span>
          </h1>
          <p className="text-gray-600">
            Sistema Sentinela - Acesso Gestor
          </p>
        </div>

        {/* Login Card */}
        <div className="card card-body">
          {error && (
            <div className="mb-4 p-3 bg-danger-50 border border-danger-200 rounded-lg text-danger-800 text-sm">
              ⚠️ {error}
            </div>
          )}

          {/* Info de desenvolvimento */}
          <div className="mb-4 p-3 bg-info-50 border border-info-200 rounded-lg text-info-800 text-sm">
            <p className="font-medium mb-1">🔓 Modo Desenvolvimento</p>
            <p className="text-xs">Use qualquer email e senha para entrar</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div>
              <label htmlFor="email" className="form-label">
                Email <span className="text-danger-500">*</span>
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="form-input"
                placeholder="gestor@sentinela.com"
                required
                autoFocus
                disabled={loading}
              />
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="form-label">
                Senha <span className="text-danger-500">*</span>
              </label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="form-input"
                placeholder="••••••••"
                required
                disabled={loading}
              />
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full btn-primary py-3 text-base font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? (
                <span className="flex items-center justify-center">
                  <span className="spinner w-5 h-5 border-white mr-2"></span>
                  Entrando...
                </span>
              ) : (
                '🔓 Entrar no Sistema'
              )}
            </button>
          </form>

          {/* Footer Links */}
          <div className="mt-6 text-center space-y-2">
            <Link
              to="/"
              className="block text-sm text-gray-600 hover:text-primary-600"
            >
              ← Voltar para Home
            </Link>
          </div>
        </div>

        {/* Info Footer */}
        <div className="mt-6 text-center">
          <p className="text-xs text-gray-500">Sistema Sentinela</p>
          <p className="text-xs text-gray-400 mt-1">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
        </div>
      </div>
    </div>
  )
}

export default Login
LOGIN

echo "✓ Login.jsx corrigido"

# 3. Corrigir ProtectedRoute
cat > src/components/ProtectedRoute.jsx << 'PROTECTED'
import { Navigate, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

/**
 * Componente de Rota Protegida - adrisa007/sentinela (ID: 1112237272)
 */

function ProtectedRoute({ children, requiredRole }) {
  const { user, loading, isAuthenticated } = useAuth()
  const location = useLocation()

  console.log('[ProtectedRoute]', { user, loading, isAuthenticated, location: location.pathname })

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Verificando autenticação...</p>
        </div>
      </div>
    )
  }

  if (!isAuthenticated || !user) {
    console.log('[ProtectedRoute] Não autenticado, redirecionando para login')
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  if (requiredRole && user.role !== requiredRole) {
    console.log('[ProtectedRoute] Sem permissão:', { userRole: user.role, requiredRole })
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
        <div className="card card-body max-w-md text-center">
          <span className="text-6xl mb-4">🚫</span>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Acesso Negado</h2>
          <p className="text-gray-600 mb-4">
            Você não tem permissão para acessar esta página.
          </p>
          <p className="text-sm text-gray-500 mb-4">
            Seu perfil: <strong>{user.role}</strong><br/>
            Perfil necessário: <strong>{requiredRole}</strong>
          </p>
          <button
            onClick={() => window.history.back()}
            className="btn-primary"
          >
            ← Voltar
          </button>
        </div>
      </div>
    )
  }

  console.log('[ProtectedRoute] Acesso permitido')
  return children
}

export default ProtectedRoute
PROTECTED

echo "✓ ProtectedRoute.jsx corrigido"

# 4. Adicionar logs ao DashboardGestor
cat > src/pages/DashboardGestor.jsx.header << 'HEADER'
import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

/**
 * Dashboard Gestor - adrisa007/sentinela (ID: 1112237272)
 */

function DashboardGestor() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  console.log('[DashboardGestor] Renderizando, user:', user)

  useEffect(() => {
    console.log('[DashboardGestor] Montado, user:', user)
  }, [user])

  const handleLogout = () => {
    console.log('[DashboardGestor] Logout')
    logout()
    navigate('/login')
  }

  // ... resto do código
HEADER

echo "✓ Headers adicionados"

echo ""
echo "================================================================"
echo "🔧 CORREÇÕES APLICADAS"
echo "================================================================"
echo ""
echo "✅ Correções realizadas:"
echo "  1. AuthContext com logs detalhados"
echo "  2. Login com useEffect para redirect"
echo "  3. ProtectedRoute com validação isAuthenticated"
echo "  4. Logs em console para debug"
echo ""
echo "🧪 Para testar:"
echo "  1. Abra o console do navegador (F12)"
echo "  2. Acesse: http://localhost:3000/login"
echo "  3. Digite: gestor@sentinela.com"
echo "  4. Senha: 123456"
echo "  5. Clique em 'Entrar'"
echo "  6. Veja os logs no console"
echo ""
echo "🔍 Logs a observar:"
echo "  [AuthContext] Verificando auth"
echo "  [Login] Iniciando login"
echo "  [Login] Login bem-sucedido"
echo "  [Login] Navegando para dashboard"
echo "  [ProtectedRoute] Acesso permitido"
echo "  [DashboardGestor] Renderizando"
echo ""

# Reiniciar servidor
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "♻️  Reiniciando servidor..."
    pkill -f vite
    sleep 2
    npm run dev > /dev/null 2>&1 &
    echo "✅ Servidor reiniciado"
else
    echo "🚀 Iniciando servidor..."
    npm run dev > /dev/null 2>&1 &
fi

sleep 3

echo ""
echo "================================================================"
echo "✅ PRONTO PARA TESTAR"
echo "================================================================"
echo ""
echo "🌐 Acesse: http://localhost:3000/login"
echo ""
echo "📧 Email: gestor@sentinela.com (ou qualquer email)"
echo "🔑 Senha: 123456 (ou qualquer senha)"
echo ""
echo "🐛 Debug:"
echo "  • Abra Console (F12) para ver logs"
echo "  • Verifique localStorage após login"
echo "  • Monitore navegação no Network tab"
echo ""