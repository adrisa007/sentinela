import { useState, useEffect } from 'react'
import { formatCNPJorCPF } from '@utils/cnpjUtils'

/**
 * Modal de Detalhes do Fornecedor - adrisa007/sentinela (ID: 1112237272)
 * 
 * Exibe informações completas do fornecedor incluindo:
 * - Dados cadastrais
 * - Certidões (status e validade)
 * - Contratos ativos
 * - Histórico
 */

function FornecedorDetailsModal({ fornecedor, isOpen, onClose }) {
  const [activeTab, setActiveTab] = useState('dados')
  const [certidoes, setCertidoes] = useState([])

  useEffect(() => {
    if (isOpen && fornecedor) {
      loadCertidoes()
    }
  }, [isOpen, fornecedor])

  const loadCertidoes = () => {
    // Mock de certidões
    const mockCertidoes = [
      {
        id: 1,
        tipo: 'CERTIDÃO NEGATIVA DE DÉBITOS FEDERAIS',
        sigla: 'CND',
        numero: 'CND-2024-001234',
        emissao: '2024-06-01',
        validade: '2024-12-01',
        status: 'VÁLIDA',
        dias_restantes: 15,
        orgao: 'Receita Federal',
      },
      {
        id: 2,
        tipo: 'CERTIDÃO NEGATIVA TRABALHISTA',
        sigla: 'CNT',
        numero: 'CNT-2024-005678',
        emissao: '2024-07-15',
        validade: '2025-01-15',
        status: 'VÁLIDA',
        dias_restantes: 60,
        orgao: 'TST',
      },
      {
        id: 3,
        tipo: 'CERTIDÃO REGULARIDADE FGTS',
        sigla: 'CRF',
        numero: 'CRF-2024-009876',
        emissao: '2024-05-10',
        validade: '2024-11-10',
        status: 'VENCIDA',
        dias_restantes: -5,
        orgao: 'Caixa Econômica Federal',
      },
      {
        id: 4,
        tipo: 'CERTIDÃO NEGATIVA MUNICIPAL',
        sigla: 'CNM',
        numero: 'CNM-2024-111222',
        emissao: '2024-08-01',
        validade: '2025-02-01',
        status: 'VÁLIDA',
        dias_restantes: 75,
        orgao: 'Prefeitura Municipal',
      },
    ]
    setCertidoes(mockCertidoes)
  }

  if (!isOpen || !fornecedor) return null

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('pt-BR')
  }

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const getCertidaoStatusBadge = (status, diasRestantes) => {
    if (status === 'VENCIDA' || diasRestantes < 0) {
      return 'badge badge-danger'
    } else if (diasRestantes <= 30) {
      return 'badge badge-warning'
    } else {
      return 'badge badge-success'
    }
  }

  const getCertidaoStatusText = (status, diasRestantes) => {
    if (status === 'VENCIDA' || diasRestantes < 0) {
      return `🔴 VENCIDA há ${Math.abs(diasRestantes)} dias`
    } else if (diasRestantes <= 7) {
      return `🔴 Vence em ${diasRestantes} dias`
    } else if (diasRestantes <= 30) {
      return `🟠 Vence em ${diasRestantes} dias`
    } else {
      return `🟢 Válida (${diasRestantes} dias)`
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700 text-white p-6">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <h2 className="text-2xl font-bold mb-2">
                {fornecedor.razao_social}
              </h2>
              <div className="flex flex-wrap gap-3 text-sm">
                <span className="flex items-center">
                  📋 {formatCNPJorCPF(fornecedor.cnpj)}
                </span>
                <span className="flex items-center">
                  📍 {fornecedor.municipio}/{fornecedor.uf}
                </span>
                <span className={`px-2 py-1 rounded ${
                  fornecedor.status === 'ATIVO' 
                    ? 'bg-success-500 text-white' 
                    : 'bg-gray-300 text-gray-700'
                }`}>
                  {fornecedor.status}
                </span>
              </div>
            </div>
            <button
              onClick={onClose}
              className="text-white hover:bg-white hover:bg-opacity-20 rounded-lg p-2 transition"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div className="border-b border-gray-200 bg-gray-50">
          <div className="flex space-x-8 px-6">
            <button
              onClick={() => setActiveTab('dados')}
              className={`py-4 px-2 border-b-2 font-medium text-sm transition ${
                activeTab === 'dados'
                  ? 'border-primary-600 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              📋 Dados Cadastrais
            </button>
            <button
              onClick={() => setActiveTab('certidoes')}
              className={`py-4 px-2 border-b-2 font-medium text-sm transition ${
                activeTab === 'certidoes'
                  ? 'border-primary-600 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              📜 Certidões ({certidoes.length})
            </button>
            <button
              onClick={() => setActiveTab('contratos')}
              className={`py-4 px-2 border-b-2 font-medium text-sm transition ${
                activeTab === 'contratos'
                  ? 'border-primary-600 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              📄 Contratos ({fornecedor.contratos_ativos})
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[calc(90vh-220px)]">
          {/* Tab: Dados Cadastrais */}
          {activeTab === 'dados' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="text-sm font-medium text-gray-600">Razão Social</label>
                  <p className="text-lg font-semibold text-gray-900">{fornecedor.razao_social}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Nome Fantasia</label>
                  <p className="text-lg font-semibold text-gray-900">{fornecedor.nome_fantasia}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">CNPJ/CPF</label>
                  <p className="text-lg font-mono font-semibold text-gray-900">
                    {formatCNPJorCPF(fornecedor.cnpj)}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Tipo</label>
                  <p className="text-lg font-semibold text-gray-900">
                    {fornecedor.tipo === 'JURIDICA' ? '🏛️ Pessoa Jurídica' : '👤 Pessoa Física'}
                  </p>
                </div>
              </div>

              <hr className="border-gray-200" />

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="text-sm font-medium text-gray-600">Município/UF</label>
                  <p className="text-lg font-semibold text-gray-900">
                    {fornecedor.municipio}/{fornecedor.uf}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Telefone</label>
                  <p className="text-lg font-semibold text-gray-900">{fornecedor.telefone}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Email</label>
                  <p className="text-lg font-semibold text-gray-900">{fornecedor.email}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Status</label>
                  <p className="text-lg font-semibold text-gray-900">
                    {fornecedor.status === 'ATIVO' ? '✅ Ativo' : '⛔ Inativo'}
                  </p>
                </div>
              </div>

              <hr className="border-gray-200" />

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="card card-body bg-primary-50 border-primary-200">
                  <label className="text-sm font-medium text-primary-700">Contratos Ativos</label>
                  <p className="text-3xl font-bold text-primary-900">{fornecedor.contratos_ativos}</p>
                </div>
                <div className="card card-body bg-success-50 border-success-200">
                  <label className="text-sm font-medium text-success-700">Valor Total</label>
                  <p className="text-3xl font-bold text-success-900">
                    {formatCurrency(fornecedor.valor_total)}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Tab: Certidões */}
          {activeTab === 'certidoes' && (
            <div className="space-y-4">
              {/* Resumo de Certidões */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                <div className="card card-body bg-success-50 border-success-200">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-success-700">Válidas</p>
                      <p className="text-3xl font-bold text-success-900">
                        {certidoes.filter(c => c.status === 'VÁLIDA' && c.dias_restantes > 0).length}
                      </p>
                    </div>
                    <span className="text-4xl">✅</span>
                  </div>
                </div>
                <div className="card card-body bg-warning-50 border-warning-200">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-warning-700">Vencendo</p>
                      <p className="text-3xl font-bold text-warning-900">
                        {certidoes.filter(c => c.dias_restantes > 0 && c.dias_restantes <= 30).length}
                      </p>
                    </div>
                    <span className="text-4xl">⚠️</span>
                  </div>
                </div>
                <div className="card card-body bg-danger-50 border-danger-200">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-danger-700">Vencidas</p>
                      <p className="text-3xl font-bold text-danger-900">
                        {certidoes.filter(c => c.dias_restantes < 0).length}
                      </p>
                    </div>
                    <span className="text-4xl">🔴</span>
                  </div>
                </div>
              </div>

              {/* Lista de Certidões */}
              {certidoes.map((certidao) => (
                <div
                  key={certidao.id}
                  className={`card card-body border-l-4 ${
                    certidao.dias_restantes < 0
                      ? 'border-danger-500 bg-danger-50'
                      : certidao.dias_restantes <= 30
                      ? 'border-warning-500 bg-warning-50'
                      : 'border-success-500 bg-success-50'
                  }`}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <h4 className="text-lg font-bold text-gray-900">
                          {certidao.tipo}
                        </h4>
                        <span className={getCertidaoStatusBadge(certidao.status, certidao.dias_restantes)}>
                          {getCertidaoStatusText(certidao.status, certidao.dias_restantes)}
                        </span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                        <div>
                          <span className="text-gray-600">Número:</span>
                          <span className="ml-2 font-mono font-medium text-gray-900">
                            {certidao.numero}
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-600">Órgão:</span>
                          <span className="ml-2 font-medium text-gray-900">
                            {certidao.orgao}
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-600">Emissão:</span>
                          <span className="ml-2 font-medium text-gray-900">
                            {formatDate(certidao.emissao)}
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-600">Validade:</span>
                          <span className={`ml-2 font-medium ${
                            certidao.dias_restantes < 0 ? 'text-danger-600' : 'text-gray-900'
                          }`}>
                            {formatDate(certidao.validade)}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="flex space-x-2 ml-4">
                      <button
                        className="text-primary-600 hover:text-primary-900 text-sm font-medium"
                        title="Ver PDF"
                      >
                        📄
                      </button>
                      <button
                        className="text-success-600 hover:text-success-900 text-sm font-medium"
                        title="Renovar"
                      >
                        🔄
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Tab: Contratos */}
          {activeTab === 'contratos' && (
            <div className="space-y-4">
              <div className="text-center py-12">
                <span className="text-6xl mb-4 block">📄</span>
                <h3 className="text-xl font-bold text-gray-900 mb-2">
                  {fornecedor.contratos_ativos} Contratos Ativos
                </h3>
                <p className="text-gray-600 mb-4">
                  Valor total: {formatCurrency(fornecedor.valor_total)}
                </p>
                <button className="btn-primary">
                  Ver Todos os Contratos
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="border-t border-gray-200 bg-gray-50 px-6 py-4">
          <div className="flex justify-end space-x-3">
            <button
              onClick={onClose}
              className="btn-ghost"
            >
              Fechar
            </button>
            <button
              onClick={() => window.open(`/fornecedores/${fornecedor.id}/editar`, '_blank')}
              className="btn-primary"
            >
              ✏️ Editar Fornecedor
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default FornecedorDetailsModal
