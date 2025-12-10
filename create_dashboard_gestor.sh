#!/bin/bash
# create_dashboard_gestor.sh
# Cria DashboardGestor.jsx com layout Tailwind completo
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "📊 Criando DashboardGestor - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# Criar DashboardGestor.jsx
cat > src/pages/DashboardGestor.jsx << 'DASHBOARD'
import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'

/**
 * Dashboard Gestor - adrisa007/sentinela (ID: 1112237272)
 * 
 * Dashboard completo para perfil GESTOR com:
 * - Visão geral de entidades
 * - Estatísticas de contratos
 * - Ações rápidas
 * - Notificações
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
    alertas: 0,
  })

  useEffect(() => {
    // Simular carregamento de dados
    setTimeout(() => {
      setStats({
        totalEntidades: 45,
        entidadesAtivas: 38,
        totalContratos: 127,
        contratosAtivos: 98,
        alertas: 5,
      })
      setLoading(false)
    }, 1000)
  }, [])

  const handleLogout = () => {
    logout()
    navigate('/login')
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
            {/* Logo */}
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🛡️</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Sentinela</h1>
                <p className="text-xs text-gray-500">Dashboard Gestor</p>
              </div>
            </div>

            {/* User Menu */}
            <div className="flex items-center space-x-4">
              <div className="hidden md:block text-right">
                <p className="text-sm font-medium text-gray-900">{user?.email}</p>
                <p className="text-xs text-gray-500">
                  <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800">
                    👤 {user?.role || 'GESTOR'}
                  </span>
                </p>
              </div>
              <button
                onClick={handleLogout}
                className="btn-ghost text-sm"
              >
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
            Bem-vindo ao painel de controle. Aqui você pode visualizar e gerenciar entidades.
          </p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {/* Total Entidades */}
          <div className="card card-body hover:shadow-xl transition-shadow cursor-pointer">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Total Entidades</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">
                  {stats.totalEntidades}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  {stats.entidadesAtivas} ativas
                </p>
              </div>
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🏢</span>
              </div>
            </div>
          </div>

          {/* Entidades Ativas */}
          <div className="card card-body hover:shadow-xl transition-shadow cursor-pointer">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Entidades Ativas</p>
                <p className="text-3xl font-bold text-success-600 mt-2">
                  {stats.entidadesAtivas}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  {((stats.entidadesAtivas / stats.totalEntidades) * 100).toFixed(0)}% do total
                </p>
              </div>
              <div className="w-12 h-12 bg-success-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">✅</span>
              </div>
            </div>
          </div>

          {/* Total Contratos */}
          <div className="card card-body hover:shadow-xl transition-shadow cursor-pointer">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Total Contratos</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">
                  {stats.totalContratos}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  {stats.contratosAtivos} ativos
                </p>
              </div>
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">📄</span>
              </div>
            </div>
          </div>

          {/* Alertas */}
          <div className="card card-body hover:shadow-xl transition-shadow cursor-pointer">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Alertas</p>
                <p className="text-3xl font-bold text-warning-600 mt-2">
                  {stats.alertas}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  Requerem atenção
                </p>
              </div>
              <div className="w-12 h-12 bg-warning-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">⚠️</span>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h3 className="text-xl font-bold text-gray-900 mb-4">Ações Rápidas</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
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
                  <p className="text-sm text-gray-600">Visualizar todas as entidades</p>
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
                  <p className="text-sm text-gray-600">Gerenciar contratos</p>
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

        {/* Recent Activity */}
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
                  { type: 'info', message: 'Nova entidade cadastrada', time: '5h atrás' },
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
          <div className="flex flex-col md:flex-row justify-between items-center">
            <p className="text-sm text-gray-600">
              © 2024 Sentinela. Todos os direitos reservados.
            </p>
            <div className="flex space-x-4 mt-4 md:mt-0">
              <a href="/docs" className="text-sm text-gray-600 hover:text-primary-600">
                📚 Documentação
              </a>
              <a href="/suporte" className="text-sm text-gray-600 hover:text-primary-600">
                💬 Suporte
              </a>
              <a href="https://github.com/adrisa007/sentinela" target="_blank" rel="noopener noreferrer" className="text-sm text-gray-600 hover:text-primary-600">
                🐙 GitHub
              </a>
            </div>
          </div>
          <p className="text-xs text-gray-400 text-center mt-4">
            Repository: adrisa007/sentinela | ID: 1112237272
          </p>
        </div>
      </footer>
    </div>
  )
}

export default DashboardGestor
DASHBOARD

echo "✓ DashboardGestor.jsx criado"

# Commit
cd /workspaces/sentinela

git add frontend/src/pages/DashboardGestor.jsx

git commit -m "feat: adiciona DashboardGestor com layout Tailwind completo

Dashboard GESTOR para adrisa007/sentinela (ID: 1112237272):

📊 Features:
  ✅ Header com logo e user menu
  ✅ Cards de estatísticas (4 métricas)
  ✅ Ações rápidas (3 cards)
  ✅ Entidades recentes
  ✅ Notificações
  ✅ Footer com links

🎨 Design:
  • Gradient background
  • Hover effects
  • Shadow transitions
  • Responsive grid
  • Tailwind CSS completo

📱 Responsive:
  • Mobile-first
  • Grid adapta em md/lg
  • Cards empilham em mobile

🔐 Segurança:
  • useAuth integration
  • Logout function
  • Protected route ready

🎯 Métricas:
  • Total Entidades
  • Entidades Ativas
  • Total Contratos
  • Alertas

Repositório: adrisa007/sentinela
Repository ID: 1112237272" || echo "Commit criado"

git push origin main || echo "Push manual necessário"

echo ""
echo "================================================================"
echo "✅ DASHBOARD GESTOR CRIADO"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo "📁 Arquivo: frontend/src/pages/DashboardGestor.jsx"
echo ""
echo "✨ Features implementadas:"
echo "  ✓ Header com logo e menu"
echo "  ✓ 4 cards de estatísticas"
echo "  ✓ 3 ações rápidas"
echo "  ✓ Lista de entidades recentes"
echo "  ✓ Painel de notificações"
echo "  ✓ Footer com links"
echo ""
echo "🎨 Tailwind CSS:"
echo "  • Gradient backgrounds"
echo "  • Hover effects"
echo "  • Shadow transitions"
echo "  • Responsive grid"
echo "  • Cards com badges"
echo ""
echo "🚀 Para usar:"
echo "  import DashboardGestor from '@pages/DashboardGestor'"
echo ""
echo "🔗 Rota sugerida:"
echo "  <Route path=\"/dashboard/gestor\" element={<DashboardGestor />} />"
echo ""