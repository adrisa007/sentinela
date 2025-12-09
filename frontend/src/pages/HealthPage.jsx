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
