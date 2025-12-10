import { useState, useEffect } from 'react'
import { getCertidoesVencendo, renovarCertidao } from '@services/certidoesService'

/**
 * Componente de Alertas de Certidões - adrisa007/sentinela (ID: 1112237272)
 * 
 * Exibe alertas de certidões vencendo em:
 * - 7 dias (CRÍTICO)
 * - 30 dias (ALERTA)
 * - 60 dias (ATENÇÃO)
 */

function CertidoesAlerts({ compact = false }) {
  const [certidoes, setCertidoes] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [renovando, setRenovando] = useState(null)

  useEffect(() => {
    loadCertidoes()
  }, [])

  const loadCertidoes = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await getCertidoesVencendo(60) // Próximos 60 dias
      setCertidoes(data)
    } catch (err) {
      setError('Erro ao carregar certidões')
      console.error(err)
      // Mock data para desenvolvimento
      setCertidoes([
        {
          id: 1,
          entidade: 'Prefeitura Municipal',
          tipo: 'CERTIDÃO NEGATIVA DE DÉBITOS FEDERAIS',
          numero: 'CND-2024-001',
          data_emissao: '2024-06-01',
          data_validade: '2024-12-15',
          status: 'VENCENDO',
          dias_restantes: 5,
        },
        {
          id: 2,
          entidade: 'Secretaria de Saúde',
          tipo: 'CERTIDÃO NEGATIVA TRABALHISTA',
          numero: 'CNT-2024-015',
          data_emissao: '2024-05-15',
          data_validade: '2024-12-20',
          status: 'ALERTA',
          dias_restantes: 10,
        },
        {
          id: 3,
          entidade: 'Câmara de Vereadores',
          tipo: 'CERTIDÃO NEGATIVA MUNICIPAL',
          numero: 'CNM-2024-022',
          data_emissao: '2024-04-01',
          data_validade: '2024-12-25',
          status: 'ATENÇÃO',
          dias_restantes: 15,
        },
        {
          id: 4,
          entidade: 'Secretaria de Obras',
          tipo: 'CERTIDÃO REGULARIDADE FGTS',
          numero: 'CRF-2024-033',
          data_emissao: '2024-08-01',
          data_validade: '2025-02-01',
          status: 'ATENÇÃO',
          dias_restantes: 52,
        },
      ])
    } finally {
      setLoading(false)
    }
  }

  const handleRenovar = async (certidaoId) => {
    try {
      setRenovando(certidaoId)
      // Calcular nova data de validade (6 meses após hoje)
      const novaData = new Date()
      novaData.setMonth(novaData.getMonth() + 6)
      
      await renovarCertidao(certidaoId, novaData.toISOString().split('T')[0])
      await loadCertidoes() // Recarregar lista
      alert('Certidão renovada com sucesso!')
    } catch (err) {
      alert('Erro ao renovar certidão: ' + err.message)
    } finally {
      setRenovando(null)
    }
  }

  const getSeverityColor = (diasRestantes) => {
    if (diasRestantes <= 7) return 'danger' // Crítico
    if (diasRestantes <= 30) return 'warning' // Alerta
    return 'info' // Atenção
  }

  const getSeverityIcon = (diasRestantes) => {
    if (diasRestantes <= 7) return '🔴'
    if (diasRestantes <= 30) return '🟠'
    return '🟡'
  }

  const getSeverityText = (diasRestantes) => {
    if (diasRestantes <= 7) return 'CRÍTICO'
    if (diasRestantes <= 30) return 'ALERTA'
    return 'ATENÇÃO'
  }

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('pt-BR')
  }

  if (loading) {
    return (
      <div className="card card-body">
        <div className="flex items-center justify-center py-8">
          <div className="spinner w-8 h-8 border-primary-600"></div>
          <span className="ml-3 text-gray-600">Carregando certidões...</span>
        </div>
      </div>
    )
  }

  const certidoesCriticas = certidoes.filter(c => c.dias_restantes <= 7)
  const certidoesAlerta = certidoes.filter(c => c.dias_restantes > 7 && c.dias_restantes <= 30)
  const certidoesAtencao = certidoes.filter(c => c.dias_restantes > 30)

  if (compact) {
    // Versão compacta para dashboard
    return (
      <div className="card">
        <div className="card-body">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-bold text-gray-900">
              📜 Certidões Vencendo
            </h3>
            <span className="badge badge-danger text-sm">
              {certidoesCriticas.length} Críticas
            </span>
          </div>

          {certidoes.length === 0 ? (
            <div className="text-center py-8">
              <span className="text-4xl mb-2 block">✅</span>
              <p className="text-gray-600">Todas as certidões em dia!</p>
            </div>
          ) : (
            <div className="space-y-3">
              {certidoes.slice(0, 3).map((certidao) => (
                <div
                  key={certidao.id}
                  className={`p-3 rounded-lg border-l-4 ${
                    certidao.dias_restantes <= 7
                      ? 'bg-danger-50 border-danger-500'
                      : certidao.dias_restantes <= 30
                      ? 'bg-warning-50 border-warning-500'
                      : 'bg-info-50 border-info-500'
                  }`}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">
                        {getSeverityIcon(certidao.dias_restantes)} {certidao.entidade}
                      </p>
                      <p className="text-xs text-gray-600 mt-1">
                        {certidao.tipo}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        Vence: {formatDate(certidao.data_validade)} ({certidao.dias_restantes} dias)
                      </p>
                    </div>
                    <button
                      onClick={() => handleRenovar(certidao.id)}
                      disabled={renovando === certidao.id}
                      className="ml-3 text-xs btn-primary px-2 py-1"
                    >
                      {renovando === certidao.id ? '...' : '🔄'}
                    </button>
                  </div>
                </div>
              ))}

              {certidoes.length > 3 && (
                <button className="w-full text-center text-sm text-primary-600 hover:text-primary-700 font-medium py-2">
                  Ver todas ({certidoes.length})
                </button>
              )}
            </div>
          )}
        </div>
      </div>
    )
  }

  // Versão completa
  return (
    <div className="space-y-6">
      {/* Resumo */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="card card-body bg-danger-50 border-danger-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-danger-700">Críticas (≤ 7 dias)</p>
              <p className="text-3xl font-bold text-danger-600 mt-2">
                {certidoesCriticas.length}
              </p>
            </div>
            <span className="text-4xl">🔴</span>
          </div>
        </div>

        <div className="card card-body bg-warning-50 border-warning-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-warning-700">Alerta (≤ 30 dias)</p>
              <p className="text-3xl font-bold text-warning-600 mt-2">
                {certidoesAlerta.length}
              </p>
            </div>
            <span className="text-4xl">🟠</span>
          </div>
        </div>

        <div className="card card-body bg-info-50 border-info-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-info-700">Atenção (≤ 60 dias)</p>
              <p className="text-3xl font-bold text-info-600 mt-2">
                {certidoesAtencao.length}
              </p>
            </div>
            <span className="text-4xl">🟡</span>
          </div>
        </div>
      </div>

      {/* Lista Completa */}
      <div className="card">
        <div className="card-body">
          <h3 className="text-xl font-bold text-gray-900 mb-4">
            📜 Todas as Certidões Vencendo
          </h3>

          {certidoes.length === 0 ? (
            <div className="text-center py-12">
              <span className="text-6xl mb-4 block">✅</span>
              <h4 className="text-xl font-bold text-gray-900 mb-2">
                Excelente!
              </h4>
              <p className="text-gray-600">
                Todas as certidões estão em dia nos próximos 60 dias.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Prioridade
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Entidade
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Tipo de Certidão
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Número
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Validade
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Dias Restantes
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {certidoes.map((certidao) => (
                    <tr key={certidao.id} className="hover:bg-gray-50">
                      <td className="px-4 py-4">
                        <span className={`badge bg-${getSeverityColor(certidao.dias_restantes)}-100 text-${getSeverityColor(certidao.dias_restantes)}-800 border border-${getSeverityColor(certidao.dias_restantes)}-200`}>
                          {getSeverityIcon(certidao.dias_restantes)} {getSeverityText(certidao.dias_restantes)}
                        </span>
                      </td>
                      <td className="px-4 py-4 text-sm font-medium text-gray-900">
                        {certidao.entidade}
                      </td>
                      <td className="px-4 py-4 text-sm text-gray-600">
                        {certidao.tipo}
                      </td>
                      <td className="px-4 py-4 text-sm text-gray-900 font-mono">
                        {certidao.numero}
                      </td>
                      <td className="px-4 py-4 text-sm text-gray-900">
                        {formatDate(certidao.data_validade)}
                      </td>
                      <td className="px-4 py-4">
                        <span className={`text-sm font-bold ${
                          certidao.dias_restantes <= 7
                            ? 'text-danger-600'
                            : certidao.dias_restantes <= 30
                            ? 'text-warning-600'
                            : 'text-info-600'
                        }`}>
                          {certidao.dias_restantes} dias
                        </span>
                      </td>
                      <td className="px-4 py-4">
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handleRenovar(certidao.id)}
                            disabled={renovando === certidao.id}
                            className="text-primary-600 hover:text-primary-900 font-medium text-sm"
                            title="Renovar certidão"
                          >
                            {renovando === certidao.id ? '⏳' : '🔄 Renovar'}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default CertidoesAlerts
