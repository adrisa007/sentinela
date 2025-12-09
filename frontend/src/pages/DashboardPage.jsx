import { useQuery } from '@tanstack/react-query'
import { Activity, Database, Server, Zap } from 'lucide-react'
import { fetchHealth } from '@services/api'

function DashboardPage() {
  const { data: health, isLoading } = useQuery({
    queryKey: ['health'],
    queryFn: fetchHealth,
    refetchInterval: 5000, // Atualiza a cada 5 segundos
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <h1 className="text-4xl font-bold">Dashboard</h1>

      {/* Status Cards */}
      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatusCard
          icon={<Activity className="w-8 h-8" />}
          label="Status Geral"
          value={health?.status || 'unknown'}
          status={health?.status === 'ok' ? 'success' : 'error'}
        />
        <StatusCard
          icon={<Database className="w-8 h-8" />}
          label="Database"
          value={health?.database || 'unknown'}
          status={health?.database === 'connected' ? 'success' : 'error'}
        />
        <StatusCard
          icon={<Server className="w-8 h-8" />}
          label="Serviço"
          value={health?.service || 'sentinela'}
          status="success"
        />
        <StatusCard
          icon={<Zap className="w-8 h-8" />}
          label="Versão"
          value={health?.version || '1.0.0'}
          status="info"
        />
      </div>

      {/* Health Check Details */}
      <div className="card">
        <h2 className="text-2xl font-bold mb-4">Health Check Details</h2>
        <pre className="bg-gray-100 p-4 rounded-lg overflow-auto">
          {JSON.stringify(health, null, 2)}
        </pre>
      </div>
    </div>
  )
}

function StatusCard({ icon, label, value, status }) {
  const statusColors = {
    success: 'text-green-600 bg-green-50',
    error: 'text-red-600 bg-red-50',
    info: 'text-blue-600 bg-blue-50',
  }

  return (
    <div className="card">
      <div className={`${statusColors[status]} p-3 rounded-lg inline-block mb-3`}>
        {icon}
      </div>
      <div className="text-sm text-gray-600 mb-1">{label}</div>
      <div className="text-2xl font-bold">{value}</div>
    </div>
  )
}

export default DashboardPage
