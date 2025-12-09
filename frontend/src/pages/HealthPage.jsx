import { useQuery } from '@tanstack/react-query'
import { fetchHealth, fetchHealthLive, fetchHealthReady } from '@services/api'
import { CheckCircle, XCircle, AlertCircle } from 'lucide-react'

function HealthPage() {
  const { data: health } = useQuery({
    queryKey: ['health'],
    queryFn: fetchHealth,
    refetchInterval: 5000,
  })

  const { data: live } = useQuery({
    queryKey: ['health-live'],
    queryFn: fetchHealthLive,
    refetchInterval: 5000,
  })

  const { data: ready } = useQuery({
    queryKey: ['health-ready'],
    queryFn: fetchHealthReady,
    refetchInterval: 5000,
  })

  return (
    <div className="space-y-8">
      <h1 className="text-4xl font-bold">Health Checks</h1>

      <div className="grid md:grid-cols-3 gap-6">
        <HealthCheckCard
          title="General Health"
          data={health}
          endpoint="/health"
        />
        <HealthCheckCard
          title="Liveness (Redis)"
          data={live}
          endpoint="/health/live"
        />
        <HealthCheckCard
          title="Readiness (Database)"
          data={ready}
          endpoint="/health/ready"
        />
      </div>
    </div>
  )
}

function HealthCheckCard({ title, data, endpoint }) {
  const isHealthy = data?.status === 'ok' || data?.status === 'ready' || data?.status === 'alive'
  
  return (
    <div className="card">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-semibold">{title}</h3>
        {isHealthy ? (
          <CheckCircle className="w-6 h-6 text-green-600" />
        ) : data ? (
          <XCircle className="w-6 h-6 text-red-600" />
        ) : (
          <AlertCircle className="w-6 h-6 text-yellow-600" />
        )}
      </div>
      <div className="text-sm text-gray-600 mb-2">{endpoint}</div>
      <pre className="bg-gray-100 p-3 rounded text-xs overflow-auto max-h-40">
        {JSON.stringify(data, null, 2)}
      </pre>
    </div>
  )
}

export default HealthPage
