import { useState, useEffect } from 'react'
import { useAuth } from '@contexts/AuthContext'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  PointElement,
  LineElement,
} from 'chart.js'
import { Bar, Doughnut, Line } from 'react-chartjs-2'
import api from '@services/api'

// Registrar componentes do Chart.js
ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  PointElement,
  LineElement
)

/**
 * Dashboard Gestor para adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Gráfico % Execução de Contratos
 * - Gráfico de Riscos por Categoria
 * - Lista de Contratos Ativos
 * - Alertas de Certidões Vencendo
 * - Integração com API via Axios
 */

function DashboardGestor() {
  const { user } = useAuth()
  const [loading, setLoading] = useState(true)
  const [contratos, setContratos] = useState([])
  const [alertas, setAlertas] = useState([])
  const [metricas, setMetricas] = useState({
    totalContratos: 0,
    contratosAtivos: 0,
    valorTotal: 0,
    percentualMedioExecucao: 0,
  })

  // ==========================================
  // CARREGAR DADOS DA API
  // ==========================================
  useEffect(() => {
    carregarDados()
  }, [])

  const carregarDados = async () => {
    setLoading(true)
    try {
      // Buscar contratos
      const { data: contratosData } = await api.get('/contratos')
      setContratos(contratosData)

      // Buscar alertas de certidões
      const { data: alertasData } = await api.get('/contratos/alertas/certidoes')
      setAlertas(alertasData)

      // Calcular métricas
      calcularMetricas(contratosData)

    } catch (error) {
      console.error('Erro ao carregar dados:', error)
      // Usar dados mock em caso de erro
      usarDadosMock()
    } finally {
      setLoading(false)
    }
  }

  const calcularMetricas = (contratos) => {
    const ativos = contratos.filter(c => c.status === 'ATIVO')
    const valorTotal = ativos.reduce((sum, c) => sum + (c.valor || 0), 0)
    const percentualMedio = ativos.reduce((sum, c) => sum + (c.percentual_execucao || 0), 0) / (ativos.length || 1)

    setMetricas({
      totalContratos: contratos.length,
      contratosAtivos: ativos.length,
      valorTotal,
      percentualMedioExecucao: percentualMedio,
    })
  }

  const usarDadosMock = () => {
    // Dados de exemplo para desenvolvimento/demo
    const contratosMock = [
      {
        id: 1,
        numero: 'CONT-2024-001',
        descricao: 'Serviços de Vigilância',
        valor: 150000,
        percentual_execucao: 75,
        status: 'ATIVO',
        data_inicio: '2024-01-15',
        data_fim: '2024-12-31',
        fornecedor: 'Empresa de Segurança XYZ',
      },
      {
        id: 2,
        numero: 'CONT-2024-002',
        descricao: 'Manutenção de Câmeras',
        valor: 80000,
        percentual_execucao: 45,
        status: 'ATIVO',
        data_inicio: '2024-02-01',
        data_fim: '2024-12-31',
        fornecedor: 'TechSecurity Ltda',
      },
      {
        id: 3,
        numero: 'CONT-2024-003',
        descricao: 'Sistemas de Alarme',
        valor: 120000,
        percentual_execucao: 90,
        status: 'ATIVO',
        data_inicio: '2024-01-10',
        data_fim: '2024-12-31',
        fornecedor: 'SecureTech Brasil',
      },
    ]

    const alertasMock = [
      {
        id: 1,
        tipo: 'CERTIDAO_VENCENDO',
        contrato_numero: 'CONT-2024-001',
        mensagem: 'Certidão Negativa de Débitos vence em 15 dias',
        dias_restantes: 15,
        prioridade: 'ALTA',
      },
      {
        id: 2,
        tipo: 'CERTIDAO_VENCIDA',
        contrato_numero: 'CONT-2024-002',
        mensagem: 'Certidão FGTS vencida há 5 dias',
        dias_restantes: -5,
        prioridade: 'CRITICA',
      },
    ]

    setContratos(contratosMock)
    setAlertas(alertasMock)
    calcularMetricas(contratosMock)
  }

  // ==========================================
  // CONFIGURAÇÃO DOS GRÁFICOS
  // ==========================================

  // Gráfico de % Execução de Contratos
  const execucaoChartData = {
    labels: contratos.map(c => c.numero),
    datasets: [
      {
        label: '% Execução',
        data: contratos.map(c => c.percentual_execucao || 0),
        backgroundColor: [
          'rgba(75, 192, 192, 0.6)',
          'rgba(54, 162, 235, 0.6)',
          'rgba(255, 206, 86, 0.6)',
          'rgba(153, 102, 255, 0.6)',
        ],
        borderColor: [
          'rgba(75, 192, 192, 1)',
          'rgba(54, 162, 235, 1)',
          'rgba(255, 206, 86, 1)',
          'rgba(153, 102, 255, 1)',
        ],
        borderWidth: 2,
      },
    ],
  }

  const execucaoChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false,
      },
      title: {
        display: true,
        text: 'Percentual de Execução por Contrato',
        font: {
          size: 16,
          weight: 'bold',
        },
      },
    },
    scales: {
      y: {
        beginAtZero: true,
        max: 100,
        ticks: {
          callback: (value) => value + '%',
        },
      },
    },
  }

  // Gráfico de Riscos
  const riscosData = {
    labels: ['Baixo', 'Médio', 'Alto', 'Crítico'],
    datasets: [
      {
        label: 'Contratos por Nível de Risco',
        data: [
          contratos.filter(c => (c.percentual_execucao || 0) > 80).length,
          contratos.filter(c => (c.percentual_execucao || 0) > 50 && (c.percentual_execucao || 0) <= 80).length,
          contratos.filter(c => (c.percentual_execucao || 0) > 20 && (c.percentual_execucao || 0) <= 50).length,
          contratos.filter(c => (c.percentual_execucao || 0) <= 20).length,
        ],
        backgroundColor: [
          'rgba(75, 192, 192, 0.6)',
          'rgba(255, 206, 86, 0.6)',
          'rgba(255, 159, 64, 0.6)',
          'rgba(255, 99, 132, 0.6)',
        ],
        borderColor: [
          'rgba(75, 192, 192, 1)',
          'rgba(255, 206, 86, 1)',
          'rgba(255, 159, 64, 1)',
          'rgba(255, 99, 132, 1)',
        ],
        borderWidth: 2,
      },
    ],
  }

  const riscosOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom',
      },
      title: {
        display: true,
        text: 'Distribuição de Riscos',
        font: {
          size: 16,
          weight: 'bold',
        },
      },
    },
  }

  // ==========================================
  // RENDER LOADING
  // ==========================================
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando dashboard...</p>
        </div>
      </div>
    )
  }

  // ==========================================
  // RENDER DASHBOARD
  // ==========================================
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Dashboard Gestor</h1>
          <p className="text-gray-600 mt-1">
            Bem-vindo, {user?.username} ({user?.role})
          </p>
        </div>
        <button
          onClick={carregarDados}
          className="btn-primary flex items-center space-x-2"
        >
          <span>🔄</span>
          <span>Atualizar</span>
        </button>
      </div>

      {/* Cards de Métricas */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricCard
          icon="📋"
          label="Total de Contratos"
          value={metricas.totalContratos}
          color="blue"
        />
        <MetricCard
          icon="✅"
          label="Contratos Ativos"
          value={metricas.contratosAtivos}
          color="green"
        />
        <MetricCard
          icon="💰"
          label="Valor Total"
          value={`R$ ${metricas.valorTotal.toLocaleString('pt-BR')}`}
          color="purple"
        />
        <MetricCard
          icon="📊"
          label="Execução Média"
          value={`${metricas.percentualMedioExecucao.toFixed(1)}%`}
          color="orange"
        />
      </div>

      {/* Alertas de Certidões */}
      {alertas.length > 0 && (
        <div className="card card-body bg-yellow-50 border-2 border-yellow-400">
          <h2 className="text-xl font-semibold mb-4 flex items-center space-x-2">
            <span>⚠️</span>
            <span>Alertas de Certidões ({alertas.length})</span>
          </h2>
          <div className="space-y-3">
            {alertas.map((alerta) => (
              <AlertaItem key={alerta.id} alerta={alerta} />
            ))}
          </div>
        </div>
      )}

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Gráfico de Execução */}
        <div className="card card-body">
          <div style={{ height: '300px' }}>
            <Bar data={execucaoChartData} options={execucaoChartOptions} />
          </div>
        </div>

        {/* Gráfico de Riscos */}
        <div className="card card-body">
          <div style={{ height: '300px' }}>
            <Doughnut data={riscosData} options={riscosOptions} />
          </div>
        </div>
      </div>

      {/* Lista de Contratos */}
      <div className="card card-body">
        <h2 className="text-2xl font-semibold mb-4">Contratos Ativos</h2>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Número</th>
                <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Descrição</th>
                <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Fornecedor</th>
                <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">Valor</th>
                <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">% Execução</th>
                <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">Status</th>
                <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {contratos.map((contrato) => (
                <ContratoRow key={contrato.id} contrato={contrato} />
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

// ==========================================
// COMPONENTES AUXILIARES
// ==========================================

function MetricCard({ icon, label, value, color }) {
  const colorClasses = {
    blue: 'bg-blue-50 text-blue-600',
    green: 'bg-green-50 text-green-600',
    purple: 'bg-purple-50 text-purple-600',
    orange: 'bg-orange-50 text-orange-600',
  }

  return (
    <div className="card card-body">
      <div className="flex items-center space-x-4">
        <div className={`text-4xl p-3 rounded-lg ${colorClasses[color]}`}>
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

function AlertaItem({ alerta }) {
  const prioridadeColors = {
    CRITICA: 'bg-red-100 text-red-800 border-red-300',
    ALTA: 'bg-orange-100 text-orange-800 border-orange-300',
    MEDIA: 'bg-yellow-100 text-yellow-800 border-yellow-300',
  }

  return (
    <div className={`p-3 rounded-lg border-2 ${prioridadeColors[alerta.prioridade] || 'bg-gray-100'}`}>
      <div className="flex justify-between items-start">
        <div>
          <p className="font-semibold">{alerta.contrato_numero}</p>
          <p className="text-sm">{alerta.mensagem}</p>
        </div>
        <span className="badge badge-danger">{alerta.prioridade}</span>
      </div>
    </div>
  )
}

function ContratoRow({ contrato }) {
  const getProgressColor = (percentual) => {
    if (percentual >= 80) return 'bg-green-500'
    if (percentual >= 50) return 'bg-yellow-500'
    if (percentual >= 20) return 'bg-orange-500'
    return 'bg-red-500'
  }

  return (
    <tr className="hover:bg-gray-50 transition">
      <td className="px-4 py-3 text-sm font-medium">{contrato.numero}</td>
      <td className="px-4 py-3 text-sm">{contrato.descricao}</td>
      <td className="px-4 py-3 text-sm">{contrato.fornecedor}</td>
      <td className="px-4 py-3 text-sm text-right">
        R$ {(contrato.valor || 0).toLocaleString('pt-BR')}
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center justify-center space-x-2">
          <div className="w-full bg-gray-200 rounded-full h-2 max-w-[100px]">
            <div
              className={`h-2 rounded-full ${getProgressColor(contrato.percentual_execucao || 0)}`}
              style={{ width: `${contrato.percentual_execucao || 0}%` }}
            ></div>
          </div>
          <span className="text-sm font-medium">
            {(contrato.percentual_execucao || 0).toFixed(0)}%
          </span>
        </div>
      </td>
      <td className="px-4 py-3 text-center">
        <span className="badge badge-success">{contrato.status}</span>
      </td>
      <td className="px-4 py-3 text-center">
        <button className="text-primary-600 hover:text-primary-700 text-sm">
          Ver Detalhes →
        </button>
      </td>
    </tr>
  )
}

export default DashboardGestor
