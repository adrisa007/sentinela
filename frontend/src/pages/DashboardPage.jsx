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
