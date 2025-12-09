#!/bin/bash
# create_pages_folder.sh
# Cria pasta src/pages com páginas React completas
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "📄 Criando src/pages - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend/src

# Criar pasta pages
mkdir -p pages

cd pages

echo "📁 Criando páginas..."

# 1. HomePage.jsx
cat > HomePage.jsx << 'HOMEPAGE'
import { Link } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'

/**
 * HomePage - adrisa007/sentinela (ID: 1112237272)
 */

function HomePage() {
  const { isAuthenticated, user } = useAuth()

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="container mx-auto px-4 py-16">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-6 animate-bounce-slow">
            <span className="text-6xl">🛡️</span>
          </div>
          
          <h1 className="text-6xl font-bold mb-4">
            <span className="gradient-text">Sentinela</span>
          </h1>
          
          <p className="text-2xl text-gray-600 mb-2">
            Vigilância total, risco zero.
          </p>
          
          <p className="text-sm text-gray-500">
            Sistema de Monitoramento e Segurança
          </p>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-16">
          <StatCard icon="⚛️" label="React" value="18.2" />
          <StatCard icon="⚡" label="Vite" value="5.1" />
          <StatCard icon="🎨" label="Tailwind" value="3.4" />
          <StatCard icon="🧪" label="Testes" value="80%" />
        </div>

        {/* Features */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
          <FeatureCard
            icon="🔐"
            title="Autenticação Segura"
            description="Login com JWT, MFA TOTP e gestão de sessões"
          />
          <FeatureCard
            icon="📊"
            title="Dashboard Completo"
            description="Métricas em tempo real com gráficos Chart.js"
          />
          <FeatureCard
            icon="🐘"
            title="Neon Database"
            description="PostgreSQL serverless de alta performance"
          />
        </div>

        {/* CTA */}
        <div className="text-center">
          {isAuthenticated ? (
            <div>
              <p className="text-lg mb-4">
                Bem-vindo, <strong>{user?.username}</strong>!
              </p>
              <Link to="/dashboard" className="btn-primary text-lg">
                📊 Acessar Dashboard
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              <Link to="/login" className="btn-primary text-lg inline-block">
                🔐 Fazer Login
              </Link>
              <div className="flex justify-center space-x-4 text-sm">
                <Link to="/health" className="text-primary-600 hover:text-primary-700">
                  💚 Health Check
                </Link>
                <span>•</span>
                <a
                  href="https://web-production-8355.up.railway.app/docs"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary-600 hover:text-primary-700"
                >
                  📚 API Docs
                </a>
              </div>
            </div>
          )}
        </div>

        {/* Footer Info */}
        <div className="mt-16 text-center text-sm text-gray-500">
          <p>adrisa007/sentinela | Repository ID: 1112237272</p>
          <p className="mt-2">
            Backend: <a
              href="https://web-production-8355.up.railway.app"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary-600 hover:text-primary-700"
            >
              https://web-production-8355.up.railway.app
            </a>
          </p>
        </div>
      </div>
    </div>
  )
}

function StatCard({ icon, label, value }) {
  return (
    <div className="card card-body text-center hover:scale-105 transition-transform">
      <div className="text-4xl mb-2">{icon}</div>
      <div className="text-3xl font-bold text-primary-600">{value}</div>
      <div className="text-sm text-gray-600">{label}</div>
    </div>
  )
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="card card-body text-center">
      <div className="text-5xl mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  )
}

export default HomePage
HOMEPAGE

# 2. LoginPage.jsx
cat > LoginPage.jsx << 'LOGINPAGE'
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
LOGINPAGE

# 3. DashboardPage.jsx
cat > DashboardPage.jsx << 'DASHPAGE'
import { useAuth } from '@contexts/AuthContext'
import { Link } from 'react-router-dom'

/**
 * DashboardPage - adrisa007/sentinela (ID: 1112237272)
 */

function DashboardPage() {
  const { user, mfaRequired, setShowMfaSetup } = useAuth()

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-4xl font-bold mb-2">📊 Dashboard</h1>
        <p className="text-gray-600">
          Bem-vindo, <strong>{user?.username}</strong> ({user?.role})
        </p>
      </div>

      {/* MFA Alert */}
      {mfaRequired && (
        <div className="card mb-8 bg-warning-50 border-2 border-warning-400">
          <div className="card-body">
            <div className="flex items-center space-x-4">
              <span className="text-5xl">⚠️</span>
              <div className="flex-1">
                <h3 className="text-xl font-bold text-warning-800 mb-2">
                  MFA Obrigatório
                </h3>
                <p className="text-warning-700 mb-4">
                  Seu perfil <strong>{user?.role}</strong> requer configuração de autenticação de dois fatores (MFA).
                </p>
                <button
                  onClick={() => setShowMfaSetup(true)}
                  className="btn-primary"
                >
                  🔐 Configurar MFA Agora
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <MetricCard
          icon="📋"
          label="Total Contratos"
          value="12"
          color="blue"
        />
        <MetricCard
          icon="✅"
          label="Ativos"
          value="8"
          color="green"
        />
        <MetricCard
          icon="💰"
          label="Valor Total"
          value="R$ 2.5M"
          color="purple"
        />
        <MetricCard
          icon="📊"
          label="Cobertura"
          value="80%"
          color="orange"
        />
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <ActionCard
          icon="🏢"
          title="Fornecedores"
          description="Gerenciar fornecedores e consultar PNCP"
          link="/fornecedores"
        />
        <ActionCard
          icon="📄"
          title="Contratos"
          description="Visualizar e gerenciar contratos"
          link="/contratos"
        />
        <ActionCard
          icon="💚"
          title="Health Check"
          description="Verificar status do sistema"
          link="/health"
        />
      </div>
    </div>
  )
}

function MetricCard({ icon, label, value, color }) {
  const colors = {
    blue: 'bg-blue-50 text-blue-600',
    green: 'bg-green-50 text-green-600',
    purple: 'bg-purple-50 text-purple-600',
    orange: 'bg-orange-50 text-orange-600',
  }

  return (
    <div className="card card-body">
      <div className="flex items-center space-x-4">
        <div className={`text-4xl p-3 rounded-lg ${colors[color]}`}>
          {icon}
        </div>
        <div>
          <p className="text-sm text-gray-600">{label}</p>
          <p className="text-2xl font-bold">{value}</p>
        </div>
      </div>
    </div>
  )
}

function ActionCard({ icon, title, description, link }) {
  return (
    <Link to={link} className="card card-body hover:shadow-lg transition-shadow">
      <div className="text-5xl mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </Link>
  )
}

export default DashboardPage
DASHPAGE

# 4. HealthPage.jsx
cat > HealthPage.jsx << 'HEALTHPAGE'
import { useState, useEffect } from 'react'
import axios from 'axios'

/**
 * HealthPage - adrisa007/sentinela (ID: 1112237272)
 */

const API_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

function HealthPage() {
  const [health, setHealth] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchHealth()
  }, [])

  const fetchHealth = async () => {
    setLoading(true)
    setError(null)
    try {
      const { data } = await axios.get(`${API_URL}/health`)
      setHealth(data)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8 flex justify-between items-center">
        <div>
          <h1 className="text-4xl font-bold mb-2">💚 Health Check</h1>
          <p className="text-gray-600">Status do sistema</p>
        </div>
        <button onClick={fetchHealth} className="btn-primary">
          🔄 Atualizar
        </button>
      </div>

      {loading && (
        <div className="flex justify-center py-12">
          <div className="spinner w-12 h-12 border-primary-600"></div>
        </div>
      )}

      {error && (
        <div className="card bg-danger-50 border-2 border-danger-400">
          <div className="card-body">
            <p className="text-danger-600">❌ Erro: {error}</p>
          </div>
        </div>
      )}

      {health && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <StatusCard
              label="Status"
              value={health.status}
              icon={health.status === 'ok' ? '✅' : '❌'}
              isGood={health.status === 'ok'}
            />
            <StatusCard
              label="Database"
              value={health.database}
              icon={health.database === 'connected' ? '🐘' : '❌'}
              isGood={health.database === 'connected'}
            />
            <StatusCard
              label="Serviço"
              value={health.service}
              icon="🚀"
              isGood={true}
            />
          </div>

          <div className="card card-body">
            <h2 className="text-2xl font-bold mb-4">Detalhes Completos</h2>
            <pre className="bg-gray-100 p-4 rounded-lg overflow-auto text-sm">
              {JSON.stringify(health, null, 2)}
            </pre>
          </div>
        </div>
      )}
    </div>
  )
}

function StatusCard({ label, value, icon, isGood }) {
  return (
    <div className={`card card-body ${isGood ? 'bg-success-50' : 'bg-danger-50'}`}>
      <div className="text-4xl mb-2">{icon}</div>
      <p className="text-sm text-gray-600 mb-1">{label}</p>
      <p className="text-2xl font-bold">{value}</p>
    </div>
  )
}

export default HealthPage
HEALTHPAGE

# 5. NotFoundPage.jsx
cat > NotFoundPage.jsx << 'NOTFOUND'
import { Link } from 'react-router-dom'

/**
 * NotFoundPage - adrisa007/sentinela (ID: 1112237272)
 */

function NotFoundPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="text-center">
        <div className="text-9xl mb-6 animate-bounce">⚠️</div>
        <h1 className="text-6xl font-bold mb-4">404</h1>
        <p className="text-2xl text-gray-600 mb-8">Página não encontrada</p>
        <Link to="/" className="btn-primary text-lg">
          🏠 Voltar para Home
        </Link>
        <p className="mt-8 text-sm text-gray-500">
          adrisa007/sentinela | Repository ID: 1112237272
        </p>
      </div>
    </div>
  )
}

export default NotFoundPage
NOTFOUND

# 6. index.js
cat > index.js << 'INDEX'
/**
 * Pages Index - adrisa007/sentinela (ID: 1112237272)
 */

export { default as HomePage } from './HomePage'
export { default as LoginPage } from './LoginPage'
export { default as DashboardPage } from './DashboardPage'
export { default as HealthPage } from './HealthPage'
export { default as NotFoundPage } from './NotFoundPage'
INDEX

# 7. README.md
cat > README.md << 'README'
# Pages - adrisa007/sentinela (ID: 1112237272)

Páginas da aplicação React.

## 📄 Páginas Disponíveis

### HomePage (`/`)
Página inicial com apresentação do sistema.

**Features:**
- Hero section
- Stats cards
- Features grid
- CTA dinâmico (login ou dashboard)

### LoginPage (`/login`)
Página de autenticação.

**Features:**
- Login com usuário/senha
- Campo MFA condicional
- Validação de formulário
- Error handling
- Auto-redirect se autenticado

### DashboardPage (`/dashboard`)
Dashboard principal do sistema.

**Features:**
- Métricas em cards
- Alerta de MFA obrigatório
- Quick actions
- Informações do usuário

### HealthPage (`/health`)
Verificação de status do sistema.

**Features:**
- Health check do backend
- Status cards (API, DB, Service)
- JSON detalhado
- Botão atualizar

### NotFoundPage (`*`)
Página 404.

**Features:**
- Design amigável
- Link para home
- Animações

## 🎯 Uso

### Importação Individual
```jsx
import HomePage from '@pages/HomePage'