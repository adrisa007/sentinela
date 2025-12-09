#!/bin/bash
# update_login_mfa_block.sh
# Atualiza Login.jsx com MFA obrigatório para ROOT/GESTOR
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔐 Atualizando Login.jsx com MFA Obrigatório - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend/src/pages

# Atualizar Login.jsx
cat > Login.jsx << 'LOGIN'
import { useState, useEffect } from 'react'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { useAuth } from '@contexts/AuthContext'

/**
 * Login Page com MFA TOTP Obrigatório
 * Repository: adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Email/Senha com React Hook Form
 * - MFA TOTP obrigatório para ROOT e GESTOR
 * - Bloqueio de login sem MFA configurado
 * - Auto-redirect para setup MFA
 * - Validação completa
 */

function Login() {
  const [showMFA, setShowMFA] = useState(false)
  const [requiresMFASetup, setRequiresMFASetup] = useState(false)
  const [loginError, setLoginError] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [userRole, setUserRole] = useState(null)
  
  const { login, loginWithMFA, isAuthenticated, loading, setupMFA } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  
  // React Hook Form
  const {
    register,
    handleSubmit,
    formState: { errors },
    setFocus,
    getValues,
  } = useForm({
    mode: 'onBlur',
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
        username: data.email,
        password: data.password,
      }

      let result

      if (showMFA) {
        // Login com MFA TOTP
        console.log('[Login] Tentando login com MFA TOTP')
        result = await loginWithMFA(credentials, data.totpCode)
      } else {
        // Login normal - primeiro passo
        console.log('[Login] Tentando login normal')
        result = await login(credentials)
      }

      if (result.success) {
        console.log('[Login] Login bem-sucedido')
        
        // Verificar se precisa configurar MFA
        const user = result.user
        setUserRole(user.role)
        
        if (['ROOT', 'GESTOR'].includes(user.role)) {
          if (!user.mfa_enabled && !user.totp_configured) {
            console.warn('[Login] MFA obrigatório para', user.role)
            setRequiresMFASetup(true)
            setLoginError(`MFA é obrigatório para ${user.role}. Configure agora.`)
            return
          }
        }
        
        // Sucesso completo - navegação será feita pelo useEffect
      } else if (result.needsMFA) {
        // Precisa de código MFA
        console.log('[Login] MFA necessário')
        setShowMFA(true)
        setUserRole(result.role || 'UNKNOWN')
        setLoginError('Digite o código MFA do seu aplicativo autenticador')
      } else if (result.error?.includes('MFA não configurado')) {
        // MFA não configurado para ROOT/GESTOR
        console.warn('[Login] MFA não configurado')
        setRequiresMFASetup(true)
        setUserRole(result.role || 'UNKNOWN')
        setLoginError('Você precisa configurar MFA para acessar o sistema. Clique abaixo.')
      } else {
        // Erro genérico
        setLoginError(result.error || 'Erro ao fazer login')
      }
    } catch (error) {
      console.error('[Login] Erro:', error)
      setLoginError('Erro inesperado. Tente novamente.')
    } finally {
      setIsSubmitting(false)
    }
  }

  // Redirecionar para setup MFA
  const handleSetupMFA = async () => {
    console.log('[Login] Redirecionando para setup MFA')
    
    try {
      // Fazer login novamente para obter token temporário
      const credentials = {
        username: getValues('email'),
        password: getValues('password'),
      }
      
      const result = await login(credentials)
      
      if (result.success || result.token) {
        // Redirecionar para página de setup MFA
        navigate('/mfa/setup', { 
          state: { 
            fromLogin: true,
            role: userRole 
          } 
        })
      } else {
        setLoginError('Erro ao preparar setup MFA. Tente fazer login novamente.')
      }
    } catch (error) {
      console.error('[Login] Erro ao preparar MFA setup:', error)
      setLoginError('Erro ao configurar MFA. Tente novamente.')
    }
  }

  // Loading inicial
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Verificando autenticação...</p>
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
            Sistema Sentinela - Acesso Seguro
          </p>
        </div>

        {/* Login Card */}
        <div className="card card-body">
          {/* MFA Setup Required Alert */}
          {requiresMFASetup && (
            <div className="mb-6 p-4 bg-warning-50 border-2 border-warning-400 rounded-lg">
              <div className="flex items-start space-x-3">
                <span className="text-3xl">🔒</span>
                <div className="flex-1">
                  <h3 className="font-bold text-warning-800 mb-2">
                    MFA Obrigatório para {userRole}
                  </h3>
                  <p className="text-sm text-warning-700 mb-3">
                    Por questões de segurança, usuários <strong>{userRole}</strong> devem 
                    configurar autenticação de dois fatores (MFA) antes de acessar o sistema.
                  </p>
                  <button
                    onClick={handleSetupMFA}
                    className="btn-primary w-full"
                  >
                    🔐 Configurar MFA Agora
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Role Badge */}
          {userRole && showMFA && (
            <div className="mb-4 p-3 bg-primary-50 border border-primary-200 rounded-lg">
              <p className="text-sm text-primary-800 text-center">
                Logando como: <span className="font-bold">{userRole}</span>
              </p>
            </div>
          )}

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
                className={`form-input ${errors.email ? 'border-danger-500' : ''}`}
                placeholder="admin@sentinela.com"
                disabled={isSubmitting || requiresMFASetup}
                autoComplete="email"
                autoFocus={!showMFA}
              />
              {errors.email && (
                <p className="form-error mt-1">{errors.email.message}</p>
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
                className={`form-input ${errors.password ? 'border-danger-500' : ''}`}
                placeholder="••••••••"
                disabled={isSubmitting || requiresMFASetup}
                autoComplete="current-password"
              />
              {errors.password && (
                <p className="form-error mt-1">{errors.password.message}</p>
              )}
            </div>

            {/* MFA TOTP Input (conditional) */}
            {showMFA && !requiresMFASetup && (
              <div className="animate-slide-in">
                <label htmlFor="totpCode" className="form-label">
                  Código MFA TOTP (6 dígitos) <span className="text-danger-500">*</span>
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
                    maxLength: 6,
                  })}
                  className={`form-input text-center text-3xl tracking-widest font-bold ${
                    errors.totpCode ? 'border-danger-500' : ''
                  }`}
                  placeholder="000000"
                  maxLength="6"
                  disabled={isSubmitting}
                  autoComplete="one-time-code"
                  autoFocus
                />
                {errors.totpCode && (
                  <p className="form-error mt-1">{errors.totpCode.message}</p>
                )}
                
                {/* MFA Info Box */}
                <div className="mt-3 p-3 bg-info-50 border border-info-200 rounded-lg">
                  <p className="text-xs text-info-800 mb-2 font-semibold">
                    📱 Onde encontrar o código?
                  </p>
                  <ul className="text-xs text-info-700 space-y-1">
                    <li>• Abra seu aplicativo autenticador</li>
                    <li>• Encontre "Sentinela" ou "{userRole}"</li>
                    <li>• Digite o código de 6 dígitos</li>
                  </ul>
                </div>
              </div>
            )}

            {/* Remember Me */}
            {!showMFA && !requiresMFASetup && (
              <div className="flex items-center justify-between">
                <label className="flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    {...register('rememberMe')}
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                    disabled={isSubmitting}
                  />
                  <span className="ml-2 text-sm text-gray-700">Lembrar-me</span>
                </label>
                
                <Link
                  to="/forgot-password"
                  className="text-sm text-primary-600 hover:text-primary-700"
                >
                  Esqueceu a senha?
                </Link>
              </div>
            )}

            {/* Error Message */}
            {loginError && !requiresMFASetup && (
              <div className="p-4 bg-danger-50 border-l-4 border-danger-500 rounded">
                <div className="flex items-start">
                  <span className="text-danger-500 mr-2 text-xl">⚠️</span>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-danger-800">Erro</p>
                    <p className="text-sm text-danger-700 mt-1">{loginError}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Submit Button */}
            {!requiresMFASetup && (
              <button
                type="submit"
                disabled={isSubmitting}
                className="w-full btn-primary py-3 text-base font-semibold"
              >
                {isSubmitting ? (
                  <span className="flex items-center justify-center space-x-2">
                    <span className="spinner w-5 h-5 border-white"></span>
                    <span>Verificando...</span>
                  </span>
                ) : showMFA ? (
                  <span className="flex items-center justify-center space-x-2">
                    <span>🔐</span>
                    <span>Verificar Código MFA</span>
                  </span>
                ) : (
                  <span className="flex items-center justify-center space-x-2">
                    <span>🔐</span>
                    <span>Entrar</span>
                  </span>
                )}
              </button>
            )}
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

        {/* Security Notice */}
        <div className="mt-6 p-4 bg-gray-50 rounded-lg text-center">
          <p className="text-xs text-gray-600 mb-2">
            🛡️ <strong>Segurança Reforçada</strong>
          </p>
          <p className="text-xs text-gray-500">
            Usuários ROOT e GESTOR requerem MFA obrigatório
          </p>
        </div>

        {/* Footer Info */}
        <div className="mt-6 text-center">
          <p className="text-xs text-gray-500">Sistema Sentinela</p>
          <p className="text-xs text-gray-400 mt-1">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
          <div className="mt-3 flex justify-center space-x-4 text-xs">
            <a
              href="https://web-production-8355.up.railway.app/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-primary-600"
            >
              📚 API Docs
            </a>
            <span className="text-gray-300">•</span>
            <a
              href="https://github.com/adrisa007/sentinela"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-primary-600"
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
LOGIN

echo "✓ Login.jsx atualizado com MFA obrigatório"
echo ""

# Atualizar README
cat > LOGIN_README.md << 'README'
# Login com MFA Obrigatório - adrisa007/sentinela (ID: 1112237272)

Login page com bloqueio MFA TOTP para ROOT e GESTOR.

## 🔐 Bloqueio MFA

### Usuários que Requerem MFA
- **ROOT** - Acesso total ao sistema
- **GESTOR** - Acesso administrativo

### Fluxo de Bloqueio

1. **Login Inicial**