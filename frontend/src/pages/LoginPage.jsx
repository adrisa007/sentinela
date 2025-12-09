import { useState, useEffect } from 'react'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'

/**
 * LoginPage - adrisa007/sentinela (ID: 1112237272)
 */

function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [totpCode, setTotpCode] = useState('')
  const [showMFA, setShowMFA] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const { login, loginWithMFA, isAuthenticated } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()

  // Redirect se já autenticado
  useEffect(() => {
    if (isAuthenticated) {
      const from = location.state?.from?.pathname || '/dashboard'
      navigate(from, { replace: true })
    }
  }, [isAuthenticated, navigate, location])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      let result

      if (showMFA) {
        result = await loginWithMFA({ username, password }, totpCode)
      } else {
        result = await login({ username, password })
      }

      if (result.success) {
        // Navegação será feita pelo useEffect
      } else if (result.needsMFA) {
        setShowMFA(true)
        setError('Digite o código MFA do seu aplicativo')
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
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50 px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-primary-100 rounded-full mb-4">
            <span className="text-5xl">🔐</span>
          </div>
          <h1 className="text-4xl font-bold gradient-text mb-2">Login</h1>
          <p className="text-gray-600">Sentinela - adrisa007/sentinela</p>
        </div>

        <div className="card card-body">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="form-label">Usuário</label>
              <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="form-input"
                placeholder="seu_usuario"
                required
                disabled={loading}
                autoFocus
              />
            </div>

            <div>
              <label className="form-label">Senha</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="form-input"
                placeholder="••••••••"
                required
                disabled={loading}
              />
            </div>

            {showMFA && (
              <div className="animate-slide-in">
                <label className="form-label">Código MFA (6 dígitos)</label>
                <input
                  type="text"
                  value={totpCode}
                  onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, ''))}
                  className="form-input text-center text-2xl tracking-widest"
                  placeholder="000000"
                  maxLength="6"
                  required
                  disabled={loading}
                />
                <p className="text-xs text-gray-500 mt-1">
                  📱 Código do Google Authenticator
                </p>
              </div>
            )}

            {error && (
              <div className="p-3 bg-danger-50 border border-danger-200 rounded-lg text-danger-600 text-sm">
                {error}
              </div>
            )}

            <button
              type="submit"
              className="btn-primary w-full"
              disabled={loading}
            >
              {loading ? 'Entrando...' : '🔐 Entrar'}
            </button>
          </form>

          <div className="mt-6 text-center text-sm">
            <Link to="/" className="text-primary-600 hover:text-primary-700">
              ← Voltar para Home
            </Link>
          </div>
        </div>

        <p className="text-center text-xs text-gray-500 mt-6">
          Repository ID: 1112237272
        </p>
      </div>
    </div>
  )
}

export default LoginPage
