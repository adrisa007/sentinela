#!/bin/bash
# create_login_page.sh
# Cria Login Page completo para adrisa007/sentinela (ID: 1112237272)

echo "🔐 Criando Login Page - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd frontend

# 1. Instalar react-hook-form
echo "📦 Instalando react-hook-form..."
npm install react-hook-form

# 2. Criar src/pages/Login.jsx
echo "📝 Criando src/pages/Login.jsx..."

cat > src/pages/Login.jsx << 'LOGINPAGE'
import { useState, useEffect } from 'react'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { useAuth } from '@contexts/AuthContext'

/**
 * Login Page para adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Email/Senha validation com React Hook Form
 * - MFA (TOTP) conditional input
 * - Auto-redirect para /dashboard se já autenticado
 * - Error handling
 * - Loading states
 * - Remember me (opcional)
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
  } = useForm({
    mode: 'onBlur',
    defaultValues: {
      email: '',
      password: '',
      totpCode: '',
      rememberMe: false,
    },
  })

  // Redirecionar se já autenticado
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

  // Handle form submit
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
        // Sucesso - navegação será feita pelo useEffect
        console.log('Login bem-sucedido!')
      } else if (result.needsMFA) {
        // Precisa de MFA
        setShowMFA(true)
        setLoginError('Digite o código MFA do seu aplicativo autenticador')
      } else {
        // Erro no login
        setLoginError(result.error || 'Erro ao fazer login')
      }
    } catch (error) {
      console.error('Erro no login:', error)
      setLoginError('Erro inesperado. Tente novamente.')
    } finally {
      setIsSubmitting(false)
    }
  }

  // Se ainda está carregando a autenticação inicial
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="spinner w-12 h-12 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50 px-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-primary-100 rounded-full mb-4">
            <span className="text-5xl">🛡️</span>
          </div>
          <h1 className="text-4xl font-bold gradient-text mb-2">
            Sentinela
          </h1>
          <p className="text-gray-600">
            Vigilância total, risco zero
          </p>
        </div>

        {/* Login Card */}
        <div className="card card-body">
          <h2 className="text-2xl font-semibold mb-6 text-center">
            Login
          </h2>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {/* Email Input */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                Email ou Usuário
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
                className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                  errors.email ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="seu@email.com"
                disabled={isSubmitting}
                autoComplete="email"
                autoFocus
              />
              {errors.email && (
                <p className="mt-1 text-sm text-red-600">
                  {errors.email.message}
                </p>
              )}
            </div>

            {/* Password Input */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                Senha
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
                className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                  errors.password ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="••••••••"
                disabled={isSubmitting}
                autoComplete="current-password"
              />
              {errors.password && (
                <p className="mt-1 text-sm text-red-600">
                  {errors.password.message}
                </p>
              )}
            </div>

            {/* MFA Input (conditional) */}
            {showMFA && (
              <div className="animate-slide-in">
                <label htmlFor="totpCode" className="block text-sm font-medium text-gray-700 mb-1">
                  Código MFA (6 dígitos)
                </label>
                <input
                  id="totpCode"
                  type="text"
                  {...register('totpCode', {
                    required: showMFA ? 'Código MFA é obrigatório' : false,
                    pattern: {
                      value: /^\d{6}$/,
                      message: 'Código deve ter 6 dígitos',
                    },
                  })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition text-center text-2xl tracking-widest ${
                    errors.totpCode ? 'border-red-500' : 'border-gray-300'
                  }`}
                  placeholder="000000"
                  maxLength="6"
                  disabled={isSubmitting}
                  autoComplete="one-time-code"
                />
                {errors.totpCode && (
                  <p className="mt-1 text-sm text-red-600">
                    {errors.totpCode.message}
                  </p>
                )}
                <p className="mt-2 text-xs text-gray-500">
                  📱 Abra seu aplicativo autenticador (Google Authenticator, Authy, etc)
                </p>
              </div>
            )}

            {/* Remember Me */}
            <div className="flex items-center">
              <input
                id="rememberMe"
                type="checkbox"
                {...register('rememberMe')}
                className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                disabled={isSubmitting}
              />
              <label htmlFor="rememberMe" className="ml-2 block text-sm text-gray-700">
                Lembrar-me
              </label>
            </div>

            {/* Error Message */}
            {loginError && (
              <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
                <div className="flex items-start">
                  <span className="text-red-600 mr-2">⚠️</span>
                  <p className="text-sm text-red-600">{loginError}</p>
                </div>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full btn-primary flex items-center justify-center py-3 text-base font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isSubmitting ? (
                <>
                  <span className="spinner w-5 h-5 mr-2 border-white"></span>
                  Entrando...
                </>
              ) : (
                <>
                  🔐 Entrar
                </>
              )}
            </button>
          </form>

          {/* Forgot Password Link */}
          <div className="mt-6 text-center">
            <Link
              to="/forgot-password"
              className="text-sm text-primary-600 hover:text-primary-700 transition"
            >
              Esqueceu sua senha?
            </Link>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center">
          <p className="text-sm text-gray-500">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
          <div className="mt-4 flex justify-center space-x-4 text-xs text-gray-400">
            <Link to="/privacy" className="hover:text-gray-600 transition">
              Privacidade
            </Link>
            <span>•</span>
            <Link to="/terms" className="hover:text-gray-600 transition">
              Termos de Uso
            </Link>
            <span>•</span>
            <a
              href="https://web-production-8355.up.railway.app/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-gray-600 transition"
            >
              API Docs
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Login
LOGINPAGE

echo "✓ Login.jsx criado"

# 3. Atualizar App.jsx para incluir rota de login
echo "📱 Atualizando src/App.jsx..."

cat > src/App.jsx << 'APPJSX'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'
import Layout from '@components/Layout'
import HomePage from '@pages/HomePage'
import DashboardPage from '@pages/DashboardPage'
import HealthPage from '@pages/HealthPage'
import Login from '@pages/Login'
import NotFoundPage from '@pages/NotFoundPage'

// Protected Route Component
function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth()

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="spinner w-12 h-12 border-primary-600"></div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  return children
}

function App() {
  return (
    <Routes>
      {/* Public Routes */}
      <Route path="/" element={<Layout><HomePage /></Layout>} />
      <Route path="/login" element={<Login />} />
      <Route path="/health" element={<Layout><HealthPage /></Layout>} />

      {/* Protected Routes */}
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <Layout>
              <DashboardPage />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* 404 */}
      <Route path="*" element={<Layout><NotFoundPage /></Layout>} />
    </Routes>
  )
}

export default App
APPJSX

echo "✓ App.jsx atualizado"

# 4. Atualizar Layout para mostrar botão Login/Logout
echo "🏗️  Atualizando src/components/Layout.jsx..."

cat > src/components/Layout.jsx << 'LAYOUTJSX'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'

function Layout({ children }) {
  const { isAuthenticated, user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <div className="min-h-screen">
      <header className="bg-white shadow">
        <nav className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            {/* Logo */}
            <Link to="/" className="flex items-center space-x-2">
              <span className="text-3xl">🛡️</span>
              <span className="text-2xl font-bold text-primary-600">Sentinela</span>
            </Link>

            {/* Navigation */}
            <div className="flex items-center space-x-6">
              <Link to="/" className="hover:text-primary-600 transition">
                🏠 Home
              </Link>
              {isAuthenticated && (
                <Link to="/dashboard" className="hover:text-primary-600 transition">
                  📊 Dashboard
                </Link>
              )}
              <Link to="/health" className="hover:text-primary-600 transition">
                💚 Health
              </Link>

              {/* Auth Section */}
              {isAuthenticated ? (
                <div className="flex items-center space-x-4">
                  <span className="text-sm text-gray-600">
                    👤 {user?.username || user?.email}
                    {user?.role && (
                      <span className="ml-2 badge badge-success">
                        {user.role}
                      </span>
                    )}
                  </span>
                  <button
                    onClick={handleLogout}
                    className="btn-ghost text-sm"
                  >
                    🚪 Sair
                  </button>
                </div>
              ) : (
                <Link to="/login" className="btn-primary">
                  🔐 Login
                </Link>
              )}
            </div>
          </div>
        </nav>
      </header>

      <main className="container mx-auto px-4 py-8">
        {children}
      </main>

      <footer className="bg-gray-900 text-white py-8 mt-16">
        <div className="container mx-auto text-center">
          <p className="text-lg font-semibold">🛡️ Sentinela</p>
          <p className="text-gray-400 mt-2">Vigilância total, risco zero.</p>
          <p className="text-gray-500 text-sm mt-4">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
          <div className="mt-4 flex justify-center space-x-4 text-sm">
            <a
              href="https://web-production-8355.up.railway.app/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition"
            >
              📚 API Docs
            </a>
            <span className="text-gray-600">•</span>
            <a
              href="https://github.com/adrisa007/sentinela"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition"
            >
              🐙 GitHub
            </a>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default Layout
LAYOUTJSX

echo "✓ Layout.jsx atualizado"

# 5. Criar README para Login
cat > src/pages/LOGIN_README.md << 'LOGINREADME'
# Login Page - adrisa007/sentinela (ID: 1112237272)

## Features

✅ **React Hook Form** com validação
✅ **Email/Senha** com validation patterns
✅ **MFA (TOTP)** conditional input (aparece se necessário)
✅ **Auto-redirect** para /dashboard se já autenticado
✅ **Loading states** durante submit
✅ **Error handling** com mensagens claras
✅ **Remember me** (opcional)
✅ **Responsive** design
✅ **Integração** completa com AuthContext

## Validações

### Email
- Obrigatório
- Formato de email válido
- Pattern: `/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i`

### Senha
- Obrigatório
- Mínimo 6 caracteres

### MFA (TOTP)
- Obrigatório quando `showMFA` = true
- Exatamente 6 dígitos numéricos
- Pattern: `/^\d{6}$/`

## Fluxo

1. Usuário preenche email e senha
2. Submit → `login(credentials)`
3. Se backend retornar `needsMFA: true`:
   - Mostrar campo MFA
   - Usuário digita código de 6 dígitos
   - Submit → `loginWithMFA(credentials, totpCode)`
4. Se sucesso → Redirect para /dashboard
5. Se erro → Mostrar mensagem

## Auto-redirect

Usuários já autenticados são automaticamente redirecionados:

```javascript
useEffect(() => {
  if (isAuthenticated) {
    navigate('/dashboard', { replace: true })
  }
}, [isAuthenticated])