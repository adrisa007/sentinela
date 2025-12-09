import { useState, useEffect } from 'react'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { useAuth } from '@contexts/AuthContext'

/**
 * Login Page com React Hook Form
 * Repository: adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Email/Senha validation
 * - React Hook Form
 * - MFA TOTP support
 * - Auto-redirect se autenticado
 * - Error handling
 * - Loading states
 */

function Login() {
  const [showMFA, setShowMFA] = useState(false)
  const [loginError, setLoginError] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  
  const { login, loginWithMFA, isAuthenticated, loading } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  
  // React Hook Form
  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
    setFocus,
    reset,
  } = useForm({
    mode: 'onBlur', // Validar ao perder foco
    defaultValues: {
      email: '',
      password: '',
      totpCode: '',
      rememberMe: false,
    },
  })

  // Auto-redirect se já autenticado
  useEffect(() => {
    if (isAuthenticated) {
      const from = location.state?.from?.pathname || '/dashboard'
      navigate(from, { replace: true })
    }
  }, [isAuthenticated, navigate, location])

  // Focus no campo MFA quando aparecer
  useEffect(() => {
    if (showMFA) {
      setFocus('totpCode')
    }
  }, [showMFA, setFocus])

  // Submit handler
  const onSubmit = async (data) => {
    setLoginError('')
    setIsSubmitting(true)

    try {
      const credentials = {
        username: data.email, // Backend pode aceitar email como username
        password: data.password,
      }

      let result

      if (showMFA) {
        // Login com MFA
        result = await loginWithMFA(credentials, data.totpCode)
      } else {
        // Login normal
        result = await login(credentials)
      }

      if (result.success) {
        console.log('[Login] Sucesso, redirecionando...')
        // Navegação será feita pelo useEffect
      } else if (result.needsMFA) {
        // Precisa de MFA
        setShowMFA(true)
        setLoginError('Digite o código MFA do seu aplicativo autenticador')
      } else {
        // Erro no login
        setLoginError(result.error || 'Erro ao fazer login')
      }
    } catch (error) {
      console.error('[Login] Erro:', error)
      setLoginError('Erro inesperado. Tente novamente.')
    } finally {
      setIsSubmitting(false)
    }
  }

  // Loading inicial
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    )
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
            Acesse o sistema Sentinela
          </p>
        </div>

        {/* Login Card */}
        <div className="card card-body">
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
            {/* Email Input */}
            <div>
              <label htmlFor="email" className="form-label">
                Email ou Usuário <span className="text-danger-500">*</span>
              </label>
              <input
                id="email"
                type="text"
                {...register('email', {
                  required: 'Email é obrigatório',
                  pattern: {
                    value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                    message: 'Email inválido',
                  },
                })}
                className={`form-input ${errors.email ? 'border-danger-500 focus:ring-danger-500' : ''}`}
                placeholder="seu@email.com"
                disabled={isSubmitting}
                autoComplete="email"
                autoFocus
              />
              {errors.email && (
                <p className="form-error mt-1">
                  {errors.email.message}
                </p>
              )}
            </div>

            {/* Password Input */}
            <div>
              <label htmlFor="password" className="form-label">
                Senha <span className="text-danger-500">*</span>
              </label>
              <input
                id="password"
                type="password"
                {...register('password', {
                  required: 'Senha é obrigatória',
                  minLength: {
                    value: 6,
                    message: 'Senha deve ter no mínimo 6 caracteres',
                  },
                })}
                className={`form-input ${errors.password ? 'border-danger-500 focus:ring-danger-500' : ''}`}
                placeholder="••••••••"
                disabled={isSubmitting}
                autoComplete="current-password"
              />
              {errors.password && (
                <p className="form-error mt-1">
                  {errors.password.message}
                </p>
              )}
            </div>

            {/* MFA Input (conditional) */}
            {showMFA && (
              <div className="animate-slide-in">
                <label htmlFor="totpCode" className="form-label">
                  Código MFA (6 dígitos) <span className="text-danger-500">*</span>
                </label>
                <input
                  id="totpCode"
                  type="text"
                  {...register('totpCode', {
                    required: showMFA ? 'Código MFA é obrigatório' : false,
                    pattern: {
                      value: /^\d{6}$/,
                      message: 'Código deve ter exatamente 6 dígitos',
                    },
                    maxLength: {
                      value: 6,
                      message: 'Código deve ter 6 dígitos',
                    },
                  })}
                  className={`form-input text-center text-2xl tracking-widest ${
                    errors.totpCode ? 'border-danger-500' : ''
                  }`}
                  placeholder="000000"
                  maxLength="6"
                  disabled={isSubmitting}
                  autoComplete="one-time-code"
                />
                {errors.totpCode && (
                  <p className="form-error mt-1">
                    {errors.totpCode.message}
                  </p>
                )}
                <p className="mt-2 text-xs text-gray-500 flex items-center">
                  <span className="mr-1">📱</span>
                  Abra seu aplicativo autenticador (Google Authenticator, Authy, etc)
                </p>
              </div>
            )}

            {/* Remember Me */}
            <div className="flex items-center justify-between">
              <label className="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  {...register('rememberMe')}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  disabled={isSubmitting}
                />
                <span className="ml-2 text-sm text-gray-700">
                  Lembrar-me
                </span>
              </label>
              
              <Link
                to="/forgot-password"
                className="text-sm text-primary-600 hover:text-primary-700"
              >
                Esqueceu a senha?
              </Link>
            </div>

            {/* Error Message */}
            {loginError && (
              <div className="p-4 bg-danger-50 border-l-4 border-danger-500 rounded">
                <div className="flex items-start">
                  <span className="text-danger-500 mr-2 text-xl">⚠️</span>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-danger-800">
                      Erro no Login
                    </p>
                    <p className="text-sm text-danger-700 mt-1">
                      {loginError}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full btn-primary py-3 text-base font-semibold flex items-center justify-center space-x-2"
            >
              {isSubmitting ? (
                <>
                  <span className="spinner w-5 h-5 border-white"></span>
                  <span>Entrando...</span>
                </>
              ) : (
                <>
                  <span>🔐</span>
                  <span>Entrar</span>
                </>
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
            <p className="text-xs text-gray-500">
              Não tem uma conta?{' '}
              <Link to="/register" className="text-primary-600 hover:text-primary-700">
                Registrar-se
              </Link>
            </p>
          </div>
        </div>

        {/* Info Footer */}
        <div className="mt-8 text-center">
          <p className="text-xs text-gray-500">
            🛡️ Sistema Sentinela
          </p>
          <p className="text-xs text-gray-400 mt-1">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
          <div className="mt-4 flex justify-center space-x-4 text-xs text-gray-400">
            <a
              href="https://web-production-8355.up.railway.app/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-primary-600"
            >
              📚 API Docs
            </a>
            <span>•</span>
            <a
              href="https://github.com/adrisa007/sentinela"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-primary-600"
            >
              🐙 GitHub
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Login
