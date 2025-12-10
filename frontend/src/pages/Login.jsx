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
