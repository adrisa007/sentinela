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
