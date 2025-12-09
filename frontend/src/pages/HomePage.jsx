import { Link } from 'react-router-dom'
import { Shield, Activity, Database, Zap } from 'lucide-react'

function HomePage() {
  return (
    <div className="space-y-16">
      {/* Hero Section */}
      <section className="text-center py-20">
        <Shield className="w-20 h-20 mx-auto mb-6 text-primary-600" />
        <h1 className="text-5xl font-bold mb-4 bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent">
          Sentinela
        </h1>
        <p className="text-2xl text-gray-600 mb-8">
          Vigilância total, risco zero.
        </p>
        <div className="flex justify-center space-x-4">
          <Link to="/dashboard" className="btn-primary">
            Acessar Dashboard
          </Link>
          <a 
            href="https://web-production-8355.up.railway.app/docs" 
            target="_blank" 
            rel="noopener noreferrer"
            className="btn-secondary"
          >
            Ver Documentação
          </a>
        </div>
      </section>

      {/* Features */}
      <section className="grid md:grid-cols-3 gap-8">
        <FeatureCard
          icon={<Activity className="w-12 h-12" />}
          title="Monitoramento em Tempo Real"
          description="Acompanhe o status do sistema com health checks completos"
        />
        <FeatureCard
          icon={<Database className="w-12 h-12" />}
          title="Neon Database"
          description="PostgreSQL serverless com alta performance"
        />
        <FeatureCard
          icon={<Zap className="w-12 h-12" />}
          title="API FastAPI"
          description="Backend moderno e rápido com Python 3.12"
        />
      </section>

      {/* Stats */}
      <section className="card text-center">
        <h2 className="text-3xl font-bold mb-8">Sistema Online</h2>
        <div className="grid md:grid-cols-4 gap-6">
          <StatCard label="Uptime" value="99.9%" />
          <StatCard label="Response Time" value="<100ms" />
          <StatCard label="Testes" value="137/171" />
          <StatCard label="Cobertura" value="80%" />
        </div>
      </section>
    </div>
  )
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="card hover:shadow-xl transition-shadow">
      <div className="text-primary-600 mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  )
}

function StatCard({ label, value }) {
  return (
    <div>
      <div className="text-4xl font-bold text-primary-600 mb-2">{value}</div>
      <div className="text-gray-600">{label}</div>
    </div>
  )
}

export default HomePage
