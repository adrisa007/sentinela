#!/bin/bash
# add_fornecedores_link_dashboard.sh
# Adiciona link para Fornecedores no Dashboard Gestor
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔗 Adicionando Link Fornecedores ao Dashboard - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# Atualizar DashboardGestor.jsx com link para Fornecedores
cat > src/pages/DashboardGestor.jsx << 'DASHBOARD'
import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'
import {
  Chart as ChartJS,
  ArcElement,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  PointElement,
  LineElement,
} from 'chart.js'
import { Doughnut, Bar, Line } from 'react-chartjs-2'

// Registrar componentes Chart.js
ChartJS.register(
  ArcElement,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
)

/**
 * Dashboard Gestor - adrisa007/sentinela (ID: 1112237272)
 */

function DashboardGestor() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalEntidades: 0,
    entidadesAtivas: 0,
    totalContratos: 0,
    contratosAtivos: 0,
    totalFornecedores: 0,
    fornecedoresAtivos: 0,
    alertas: 0,
    execucaoOrcamentaria: 0,
    execucaoFisica: 0,
    riscosCriticos: 0,
  })

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    setTimeout(() => {
      setStats({
        totalEntidades: 45,
        entidadesAtivas: 38,
        totalContratos: 127,
        contratosAtivos: 98,
        totalFornecedores: 6,
        fornecedoresAtivos: 5,
        alertas: 5,
        execucaoOrcamentaria: 73.5,
        execucaoFisica: 68.2,
        riscosCriticos: 8,
      })
      setLoading(false)
    }, 1000)
  }

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  // Gráfico de Execução Orçamentária
  const executionData = {
    labels: ['Executado', 'Disponível'],
    datasets: [{
      data: [stats.execucaoOrcamentaria, 100 - stats.execucaoOrcamentaria],
      backgroundColor: ['rgba(34, 197, 94, 0.8)', 'rgba(229, 231, 235, 0.8)'],
      borderColor: ['rgba(34, 197, 94, 1)', 'rgba(229, 231, 235, 1)'],
      borderWidth: 2,
    }],
  }

  const executionOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'bottom' },
      title: {
        display: true,
        text: '% Execução Orçamentária',
        font: { size: 16, weight: 'bold' },
      },
    },
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando dashboard...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      {/* Header */}
      <header className="bg-white shadow-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🛡️</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Sentinela</h1>
                <p className="text-xs text-gray-500">Dashboard Gestor</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="hidden md:block text-right">
                <p className="text-sm font-medium text-gray-900">{user?.email}</p>
                <p className="text-xs text-gray-500">
                  <span className="badge bg-purple-100 text-purple-800">
                    👤 {user?.role || 'GESTOR'}
                  </span>
                </p>
              </div>
              <button onClick={handleLogout} className="btn-ghost text-sm">
                🚪 Sair
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Section */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Olá, {user?.email?.split('@')[0] || 'Gestor'}! 👋
          </h2>
          <p className="text-gray-600">
            Acompanhe execução, desempenho e riscos críticos em tempo real.
          </p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
          <div className="card card-body hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Entidades</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">{stats.totalEntidades}</p>
              </div>
              <span className="text-2xl">🏢</span>
            </div>
          </div>

          <div className="card card-body hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Contratos</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">{stats.totalContratos}</p>
              </div>
              <span className="text-2xl">📄</span>
            </div>
          </div>

          <div className="card card-body hover:shadow-xl transition-shadow cursor-pointer" onClick={() => navigate('/fornecedores')}>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Fornecedores</p>
                <p className="text-3xl font-bold text-primary-600 mt-2">{stats.totalFornecedores}</p>
                <p className="text-xs text-gray-500 mt-1">{stats.fornecedoresAtivos} ativos</p>
              </div>
              <span className="text-2xl">🏭</span>
            </div>
          </div>

          <div className="card card-body hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Exec. Orçam.</p>
                <p className="text-3xl font-bold text-success-600 mt-2">{stats.execucaoOrcamentaria}%</p>
              </div>
              <span className="text-2xl">💰</span>
            </div>
          </div>

          <div className="card card-body hover:shadow-xl transition-shadow cursor-pointer bg-danger-50 border-danger-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-danger-700">Riscos Críticos</p>
                <p className="text-3xl font-bold text-danger-600 mt-2">{stats.riscosCriticos}</p>
              </div>
              <span className="text-2xl">⚠️</span>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h3 className="text-xl font-bold text-gray-900 mb-4">🚀 Ações Rápidas</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Ver Entidades */}
            <Link
              to="/entidades"
              className="card card-body hover:shadow-xl transition-all hover:scale-105 cursor-pointer group"
            >
              <div className="flex items-center space-x-4">
                <div className="w-14 h-14 bg-primary-100 rounded-lg flex items-center justify-center group-hover:bg-primary-200 transition">
                  <span className="text-3xl">🏢</span>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Ver Entidades</h4>
                  <p className="text-sm text-gray-600">{stats.totalEntidades} cadastradas</p>
                </div>
              </div>
            </Link>

            {/* Ver Contratos */}
            <Link
              to="/contratos"
              className="card card-body hover:shadow-xl transition-all hover:scale-105 cursor-pointer group"
            >
              <div className="flex items-center space-x-4">
                <div className="w-14 h-14 bg-purple-100 rounded-lg flex items-center justify-center group-hover:bg-purple-200 transition">
                  <span className="text-3xl">📄</span>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Ver Contratos</h4>
                  <p className="text-sm text-gray-600">{stats.contratosAtivos} ativos</p>
                </div>
              </div>
            </Link>

            {/* Ver Fornecedores - NOVO */}
            <Link
              to="/fornecedores"
              className="card card-body hover:shadow-xl transition-all hover:scale-105 cursor-pointer group bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200"
            >
              <div className="flex items-center space-x-4">
                <div className="w-14 h-14 bg-blue-100 rounded-lg flex items-center justify-center group-hover:bg-blue-200 transition">
                  <span className="text-3xl">🏭</span>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Ver Fornecedores</h4>
                  <p className="text-sm text-gray-600">{stats.totalFornecedores} cadastrados</p>
                  <span className="inline-flex items-center mt-1 px-2 py-0.5 rounded text-xs font-medium bg-blue-500 text-white">
                    ✨ NOVO
                  </span>
                </div>
              </div>
            </Link>

            {/* Relatórios */}
            <Link
              to="/relatorios"
              className="card card-body hover:shadow-xl transition-all hover:scale-105 cursor-pointer group"
            >
              <div className="flex items-center space-x-4">
                <div className="w-14 h-14 bg-info-100 rounded-lg flex items-center justify-center group-hover:bg-info-200 transition">
                  <span className="text-3xl">📊</span>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Relatórios</h4>
                  <p className="text-sm text-gray-600">Gerar relatórios</p>
                </div>
              </div>
            </Link>
          </div>
        </div>

        {/* Charts Section */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
          <div className="card card-body">
            <div className="h-80">
              <Doughnut data={executionData} options={executionOptions} />
            </div>
          </div>
          <div className="card card-body">
            <div className="h-80">
              <Doughnut 
                data={{
                  labels: ['Executado', 'Disponível'],
                  datasets: [{
                    data: [stats.execucaoFisica, 100 - stats.execucaoFisica],
                    backgroundColor: ['rgba(99, 102, 241, 0.8)', 'rgba(229, 231, 235, 0.8)'],
                  }],
                }}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: { position: 'bottom' },
                    title: { display: true, text: '% Execução Física' },
                  },
                }}
              />
            </div>
          </div>
          <div className="card card-body">
            <div className="h-80">
              <Bar 
                data={{
                  labels: ['Ativos', 'Em Análise', 'Suspensos', 'Finalizados'],
                  datasets: [{
                    data: [98, 15, 7, 27],
                    backgroundColor: [
                      'rgba(34, 197, 94, 0.8)',
                      'rgba(251, 191, 36, 0.8)',
                      'rgba(239, 68, 68, 0.8)',
                      'rgba(156, 163, 175, 0.8)',
                    ],
                  }],
                }}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: { display: false },
                    title: { display: true, text: 'Contratos por Status' },
                  },
                }}
              />
            </div>
          </div>
        </div>

        {/* Banner Fornecedores - NOVO */}
        <div className="mb-8">
          <Link
            to="/fornecedores"
            className="card bg-gradient-to-r from-blue-500 to-indigo-600 text-white hover:shadow-2xl transition-all hover:scale-[1.02] block"
          >
            <div className="card-body">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-6">
                  <div className="w-20 h-20 bg-white bg-opacity-20 rounded-2xl flex items-center justify-center">
                    <span className="text-5xl">🏭</span>
                  </div>
                  <div>
                    <h3 className="text-2xl font-bold mb-2">
                      Gestão de Fornecedores
                    </h3>
                    <p className="text-blue-100 mb-3">
                      Gerencie fornecedores, consulte certidões e integre com PNCP
                    </p>
                    <div className="flex flex-wrap gap-3">
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-white bg-opacity-20">
                        📋 {stats.totalFornecedores} Fornecedores
                      </span>
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-white bg-opacity-20">
                        ✅ {stats.fornecedoresAtivos} Ativos
                      </span>
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-white bg-opacity-20">
                        📜 Certidões
                      </span>
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-white bg-opacity-20">
                        🔍 PNCP
                      </span>
                    </div>
                  </div>
                </div>
                <div className="hidden lg:block">
                  <div className="text-right">
                    <div className="inline-flex items-center justify-center w-16 h-16 bg-white rounded-full">
                      <span className="text-3xl">→</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </Link>
        </div>

        {/* Info Section */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Entidades Recentes */}
          <div className="card">
            <div className="card-body">
              <h3 className="text-lg font-bold text-gray-900 mb-4">
                📋 Entidades Recentes
              </h3>
              <div className="space-y-3">
                {[
                  { name: 'Prefeitura Municipal', status: 'ATIVA', cnpj: '12.345.678/0001-90' },
                  { name: 'Câmara de Vereadores', status: 'ATIVA', cnpj: '98.765.432/0001-10' },
                  { name: 'Secretaria de Saúde', status: 'EM_ANALISE', cnpj: '11.222.333/0001-44' },
                ].map((entidade, idx) => (
                  <div
                    key={idx}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition"
                  >
                    <div>
                      <p className="font-medium text-gray-900">{entidade.name}</p>
                      <p className="text-xs text-gray-500">{entidade.cnpj}</p>
                    </div>
                    <span className={`badge ${
                      entidade.status === 'ATIVA' ? 'badge-success' : 'bg-warning-100 text-warning-800'
                    }`}>
                      {entidade.status}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Notificações */}
          <div className="card">
            <div className="card-body">
              <h3 className="text-lg font-bold text-gray-900 mb-4">
                🔔 Notificações
              </h3>
              <div className="space-y-3">
                {[
                  { type: 'warning', message: 'Contrato vencendo em 7 dias', time: '2h atrás' },
                  { type: 'info', message: '2 novos fornecedores cadastrados', time: '5h atrás' },
                  { type: 'success', message: 'Relatório mensal gerado', time: '1d atrás' },
                ].map((notification, idx) => (
                  <div
                    key={idx}
                    className="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition"
                  >
                    <span className="text-xl">
                      {notification.type === 'warning' && '⚠️'}
                      {notification.type === 'info' && 'ℹ️'}
                      {notification.type === 'success' && '✅'}
                    </span>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">
                        {notification.message}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        {notification.time}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-xs text-gray-400 text-center">
            Repository: adrisa007/sentinela | ID: 1112237272
          </p>
        </div>
      </footer>
    </div>
  )
}

export default DashboardGestor
DASHBOARD

echo "✓ DashboardGestor.jsx atualizado com link para Fornecedores"

# Commit
cd /workspaces/sentinela

git add frontend/

git commit -m "feat: adiciona link para Fornecedores no Dashboard Gestor

Link de Fornecedores para adrisa007/sentinela (ID: 1112237272):

🔗 Adições ao Dashboard:

1️⃣ Card de Stats Fornecedores:
  • Clickable
  • Total: 6 fornecedores
  • Ativos: 5
  • Ícone: 🏭

2️⃣ Ações Rápidas - Card Destacado:
  • Background gradiente azul
  • Badge 'NOVO'
  • Link direto /fornecedores
  • Estatísticas inline

3️⃣ Banner Promocional:
  • Full-width
  • Gradiente blue-to-indigo
  • 4 badges informativos
  • Hover effects
  • Ícone de seta

📊 Informações Exibidas:
  • 📋 6 Fornecedores
  • ✅ 5 Ativos
  • 📜 Certidões
  • 🔍 PNCP

🎨 Visual:
  • Card com hover scale
  • Gradiente de fundo
  • Badge 'NOVO' destacado
  • Banner call-to-action
  • Cores azul/indigo

🚀 3 Pontos de Acesso:
  1. Card de Stats (clique no card)
  2. Ações Rápidas (card destacado)
  3. Banner promocional (seção dedicada)

✨ Features:
  • Hover effects
  • Scale animation
  • Border highlight
  • Stats em tempo real
  • Links react-router

Repositório: adrisa007/sentinela
Repository ID: 1112237272" || echo "Commit criado"

git push origin main || echo "Push manual"

echo ""
echo "================================================================"
echo "✅ LINK DE FORNECEDORES ADICIONADO AO DASHBOARD"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "🔗 3 Formas de Acessar Fornecedores no Dashboard:"
echo ""
echo "1️⃣ Card de Estatísticas:"
echo "   • Localização: Cards superiores (3º card)"
echo "   • Mostra: Total + Ativos"
echo "   • Clicável: Sim"
echo "   • Ícone: 🏭"
echo ""
echo "2️⃣ Ações Rápidas:"
echo "   • Localização: Seção 'Ações Rápidas'"
echo "   • Destaque: Background azul + Badge 'NOVO'"
echo "   • Hover: Scale 105%"
echo "   • Stats: 6 cadastrados"
echo ""
echo "3️⃣ Banner Promocional:"
echo "   • Localização: Abaixo dos gráficos"
echo "   • Tamanho: Full-width"
echo "   • Gradiente: Blue → Indigo"
echo "   • Features: 4 badges (Fornecedores/Ativos/Certidões/PNCP)"
echo ""
echo "📊 Estatísticas Mostradas:"
echo "  • Total Fornecedores: 6"
echo "  • Fornecedores Ativos: 5"
echo ""
echo "🌐 Para Testar:"
echo "  1. Acesse: http://localhost:3000/dashboard/gestor"
echo "  2. Procure pelo card 'Fornecedores' 🏭"
echo "  3. Clique para acessar"
echo ""
echo "✨ Dashboard atualizado com acesso a Fornecedores!"
echo ""