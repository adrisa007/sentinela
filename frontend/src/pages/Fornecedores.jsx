import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'
import { getFornecedores, deleteFornecedor, getFornecedorPNCP } from '@services/fornecedoresService'
import { formatCNPJorCPF, unformatCNPJ, isValidCNPJorCPF } from '@utils/cnpjUtils'
import AddFornecedorModal from '@components/AddFornecedorModal'
import EditFornecedorModal from '@components/EditFornecedorModal'
import FornecedorDetailsModal from '@components/FornecedorDetailsModal'

/**
 * Página de Fornecedores com Filtro CNPJ - adrisa007/sentinela (ID: 1112237272)
 * 
 * Lista paginada de fornecedores com:
 * - Filtro CNPJ com máscara e validação
 * - Busca por nome
 * - Filtros de status e tipo
 * - Paginação
 */

function Fornecedores() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  // Estados
  const [fornecedores, setFornecedores] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  // Paginação
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(10)
  const [totalItems, setTotalItems] = useState(0)

  // Filtros
  const [searchTerm, setSearchTerm] = useState('')
  const [cnpjFilter, setCnpjFilter] = useState('')
  const [cnpjValid, setCnpjValid] = useState(true)
  const [statusFilter, setStatusFilter] = useState('all')
  const [tipoFilter, setTipoFilter] = useState('all')

  // Modals
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [showPNCPModal, setShowPNCPModal] = useState(false)
  const [showDetailsModal, setShowDetailsModal] = useState(false)
  const [showAddModal, setShowAddModal] = useState(false)
  const [showEditModal, setShowEditModal] = useState(false)
  const [selectedFornecedor, setSelectedFornecedor] = useState(null)
  const [pncpData, setPncpData] = useState(null)
  const [pncpLoading, setPncpLoading] = useState(false)

  useEffect(() => {
    loadFornecedores()
  }, [currentPage, searchTerm, cnpjFilter, statusFilter, tipoFilter])

  const loadFornecedores = async () => {
    try {
      setLoading(true)
      setError(null)

      // Mock data para desenvolvimento
      const mockData = {
        items: [
          {
            id: 1,
            cnpj: '12.345.678/0001-90',
            razao_social: 'Empresa Alpha Construções LTDA',
            nome_fantasia: 'Alpha Construções',
            tipo: 'JURIDICA',
            status: 'ATIVO',
            municipio: 'São Paulo',
            uf: 'SP',
            telefone: '(11) 3456-7890',
            email: 'contato@alpha.com.br',
            contratos_ativos: 5,
            valor_total: 1500000.00,
          },
          {
            id: 2,
            cnpj: '98.765.432/0001-10',
            razao_social: 'Beta Serviços e Obras LTDA',
            nome_fantasia: 'Beta Serviços',
            tipo: 'JURIDICA',
            status: 'ATIVO',
            municipio: 'Rio de Janeiro',
            uf: 'RJ',
            telefone: '(21) 2345-6789',
            email: 'contato@beta.com.br',
            contratos_ativos: 3,
            valor_total: 850000.00,
          },
          {
            id: 3,
            cnpj: '11.222.333/0001-44',
            razao_social: 'Gamma Tecnologia LTDA',
            nome_fantasia: 'Gamma Tech',
            tipo: 'JURIDICA',
            status: 'INATIVO',
            municipio: 'Brasília',
            uf: 'DF',
            telefone: '(61) 3333-4444',
            email: 'contato@gamma.com.br',
            contratos_ativos: 0,
            valor_total: 0,
          },
          {
            id: 4,
            cnpj: '55.666.777/0001-88',
            razao_social: 'Delta Equipamentos LTDA',
            nome_fantasia: 'Delta Equip',
            tipo: 'JURIDICA',
            status: 'ATIVO',
            municipio: 'Belo Horizonte',
            uf: 'MG',
            telefone: '(31) 3222-5555',
            email: 'contato@delta.com.br',
            contratos_ativos: 7,
            valor_total: 2300000.00,
          },
          {
            id: 5,
            cnpj: '123.456.789-01',
            razao_social: 'João da Silva',
            nome_fantasia: 'João Silva',
            tipo: 'FISICA',
            status: 'ATIVO',
            municipio: 'Curitiba',
            uf: 'PR',
            telefone: '(41) 99999-8888',
            email: 'joao@email.com',
            contratos_ativos: 1,
            valor_total: 50000.00,
          },
          {
            id: 6,
            cnpj: '22.333.444/0001-55',
            razao_social: 'Epsilon Materiais LTDA',
            nome_fantasia: 'Epsilon Materiais',
            tipo: 'JURIDICA',
            status: 'ATIVO',
            municipio: 'Porto Alegre',
            uf: 'RS',
            telefone: '(51) 3111-2222',
            email: 'contato@epsilon.com.br',
            contratos_ativos: 4,
            valor_total: 980000.00,
          },
        ],
        total: 6,
        page: currentPage,
        pages: 1,
      }

      setFornecedores(mockData.items)
      setTotalItems(mockData.total)

    } catch (err) {
      setError('Erro ao carregar fornecedores')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handleCnpjChange = (value) => {
    // Aplicar máscara
    const formatted = formatCNPJorCPF(value)
    setCnpjFilter(formatted)

    // Validar apenas se tiver conteúdo
    if (formatted) {
      const unformatted = unformatCNPJ(formatted)
      // Validar apenas se tiver 11 (CPF) ou 14 (CNPJ) dígitos
      if (unformatted.length === 11 || unformatted.length === 14) {
        setCnpjValid(isValidCNPJorCPF(formatted))
      } else {
        setCnpjValid(true) // Não validar enquanto digita
      }
    } else {
      setCnpjValid(true)
    }

    setCurrentPage(1)
  }

  const clearCnpjFilter = () => {
    setCnpjFilter('')
    setCnpjValid(true)
    setCurrentPage(1)
  }

  const handleDelete = async () => {
    try {
      // Simular exclusão (remover do estado local)
      setFornecedores(prev => prev.filter(f => f.id !== selectedFornecedor.id))
      setTotalItems(prev => prev - 1)
      setShowDeleteModal(false)
      setSelectedFornecedor(null)
      alert('Fornecedor deletado com sucesso!')
    } catch (err) {
      alert('Erro ao deletar fornecedor: ' + err.message)
    }
  }

  const handleSearchPNCP = async (cnpj) => {
    try {
      console.log('Iniciando consulta PNCP para CNPJ:', cnpj)
      setPncpLoading(true)
      const cnpjLimpo = unformatCNPJ(cnpj)
      console.log('CNPJ limpo:', cnpjLimpo)
      const data = await getFornecedorPNCP(cnpjLimpo)
      console.log('Dados recebidos do PNCP:', data)
      setPncpData(data)
      setShowPNCPModal(true)
    } catch (err) {
      console.error('Erro completo:', err)
      console.error('Response:', err.response)
      alert('Erro ao buscar no PNCP: ' + (err.response?.data?.detail || err.message))
    } finally {
      setPncpLoading(false)
    }
  }

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  // Filtrar fornecedores
  const filteredFornecedores = fornecedores.filter(f => {
    // Filtro de nome
    const matchSearch = !searchTerm || 
      f.razao_social.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.nome_fantasia.toLowerCase().includes(searchTerm.toLowerCase())
    
    // Filtro de CNPJ
    const matchCnpj = !cnpjFilter || 
      unformatCNPJ(f.cnpj).includes(unformatCNPJ(cnpjFilter))
    
    // Filtro de status
    const matchStatus = statusFilter === 'all' || f.status === statusFilter
    
    // Filtro de tipo
    const matchTipo = tipoFilter === 'all' || f.tipo === tipoFilter
    
    return matchSearch && matchCnpj && matchStatus && matchTipo
  })

  // Paginação
  const totalPages = Math.ceil(filteredFornecedores.length / itemsPerPage)
  const indexOfLastItem = currentPage * itemsPerPage
  const indexOfFirstItem = indexOfLastItem - itemsPerPage
  const currentFornecedores = filteredFornecedores.slice(indexOfFirstItem, indexOfLastItem)

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const getStatusBadge = (status) => {
    return status === 'ATIVO' 
      ? 'badge badge-success' 
      : 'badge bg-gray-100 text-gray-800'
  }

  const getTipoBadge = (tipo) => {
    return tipo === 'JURIDICA'
      ? 'badge bg-blue-100 text-blue-800'
      : 'badge bg-purple-100 text-purple-800'
  }

  if (loading && currentPage === 1) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando fornecedores...</p>
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
            <div className="flex items-center space-x-4">
              <Link to="/dashboard/gestor" className="text-gray-600 hover:text-primary-600">
                ← Voltar
              </Link>
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
                  <span className="text-2xl">🏢</span>
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Fornecedores</h1>
                  <p className="text-xs text-gray-500">Gestão de Fornecedores</p>
                </div>
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
        {/* Header da Página */}
        <div className="mb-8">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-2">
                🏢 Fornecedores
              </h2>
              <p className="text-gray-600">
                Gerencie fornecedores e consulte o PNCP
              </p>
            </div>
            <button
              onClick={() => setShowAddModal(true)}
              className="mt-4 md:mt-0 btn-primary"
            >
              ➕ Novo Fornecedor
            </button>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="card card-body">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total</p>
                <p className="text-3xl font-bold text-gray-900">{totalItems}</p>
              </div>
              <span className="text-3xl">🏢</span>
            </div>
          </div>
          <div className="card card-body">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Ativos</p>
                <p className="text-3xl font-bold text-success-600">
                  {fornecedores.filter(f => f.status === 'ATIVO').length}
                </p>
              </div>
              <span className="text-3xl">✅</span>
            </div>
          </div>
          <div className="card card-body">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">PJ</p>
                <p className="text-3xl font-bold text-blue-600">
                  {fornecedores.filter(f => f.tipo === 'JURIDICA').length}
                </p>
              </div>
              <span className="text-3xl">🏛️</span>
            </div>
          </div>
          <div className="card card-body">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">PF</p>
                <p className="text-3xl font-bold text-purple-600">
                  {fornecedores.filter(f => f.tipo === 'FISICA').length}
                </p>
              </div>
              <span className="text-3xl">👤</span>
            </div>
          </div>
        </div>

        {/* Filtros */}
        <div className="card card-body mb-8">
          <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
            🔍 Filtros
            {(searchTerm || cnpjFilter || statusFilter !== 'all' || tipoFilter !== 'all') && (
              <span className="ml-3 badge bg-primary-100 text-primary-800">
                {filteredFornecedores.length} resultado(s)
              </span>
            )}
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Busca por Nome */}
            <div>
              <label className="form-label">Buscar por Nome</label>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => {
                  setSearchTerm(e.target.value)
                  setCurrentPage(1)
                }}
                placeholder="Razão social ou fantasia..."
                className="form-input"
              />
            </div>

            {/* Filtro CNPJ/CPF */}
            <div>
              <label className="form-label">
                CNPJ/CPF
                {cnpjFilter && !cnpjValid && (
                  <span className="ml-2 text-xs text-danger-600">⚠️ Inválido</span>
                )}
              </label>
              <div className="relative">
                <input
                  type="text"
                  value={cnpjFilter}
                  onChange={(e) => handleCnpjChange(e.target.value)}
                  placeholder="00.000.000/0000-00"
                  className={`form-input pr-10 ${
                    cnpjFilter && !cnpjValid ? 'border-danger-300 focus:border-danger-500 focus:ring-danger-500' : ''
                  }`}
                  maxLength={18}
                />
                {cnpjFilter && (
                  <button
                    onClick={clearCnpjFilter}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    title="Limpar"
                  >
                    ✕
                  </button>
                )}
              </div>
              {cnpjFilter && cnpjValid && unformatCNPJ(cnpjFilter).length >= 11 && (
                <p className="text-xs text-success-600 mt-1">✓ Válido</p>
              )}
            </div>

            {/* Filtro Status */}
            <div>
              <label className="form-label">Status</label>
              <select
                value={statusFilter}
                onChange={(e) => {
                  setStatusFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="form-input"
              >
                <option value="all">Todos</option>
                <option value="ATIVO">✅ Ativo</option>
                <option value="INATIVO">⛔ Inativo</option>
              </select>
            </div>

            {/* Filtro Tipo */}
            <div>
              <label className="form-label">Tipo</label>
              <select
                value={tipoFilter}
                onChange={(e) => {
                  setTipoFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="form-input"
              >
                <option value="all">Todos</option>
                <option value="JURIDICA">🏛️ Pessoa Jurídica</option>
                <option value="FISICA">👤 Pessoa Física</option>
              </select>
            </div>
          </div>

          {/* Botão Limpar Filtros */}
          {(searchTerm || cnpjFilter || statusFilter !== 'all' || tipoFilter !== 'all') && (
            <div className="mt-4 flex justify-end">
              <button
                onClick={() => {
                  setSearchTerm('')
                  setCnpjFilter('')
                  setCnpjValid(true)
                  setStatusFilter('all')
                  setTipoFilter('all')
                  setCurrentPage(1)
                }}
                className="btn-ghost text-sm"
              >
                🔄 Limpar Todos os Filtros
              </button>
            </div>
          )}
        </div>

        {/* Tabela */}
        <div className="card">
          <div className="card-body">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      CNPJ/CPF
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Razão Social
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Tipo
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Localização
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Contratos
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Status
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {currentFornecedores.length === 0 ? (
                    <tr>
                      <td colSpan="7" className="px-4 py-12 text-center">
                        <span className="text-6xl mb-4 block">🔍</span>
                        <p className="text-gray-600 font-medium mb-2">
                          Nenhum fornecedor encontrado
                        </p>
                        {(searchTerm || cnpjFilter || statusFilter !== 'all' || tipoFilter !== 'all') && (
                          <p className="text-sm text-gray-500">
                            Tente ajustar os filtros de busca
                          </p>
                        )}
                      </td>
                    </tr>
                  ) : (
                    currentFornecedores.map((fornecedor) => (
                      <tr key={fornecedor.id} className="hover:bg-gray-50">
                        <td className="px-4 py-4">
                          <span className="text-sm font-mono text-gray-900">
                            {fornecedor.cnpj}
                          </span>
                        </td>
                        <td className="px-4 py-4">
                          <div className="text-sm font-medium text-gray-900">
                            {fornecedor.razao_social}
                          </div>
                          <div className="text-xs text-gray-500">
                            {fornecedor.nome_fantasia}
                          </div>
                        </td>
                        <td className="px-4 py-4">
                          <span className={getTipoBadge(fornecedor.tipo)}>
                            {fornecedor.tipo === 'JURIDICA' ? '🏛️ PJ' : '👤 PF'}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-sm text-gray-900">
                          {fornecedor.municipio}/{fornecedor.uf}
                        </td>
                        <td className="px-4 py-4">
                          <div className="text-sm font-medium text-gray-900">
                            {fornecedor.contratos_ativos} ativos
                          </div>
                          <div className="text-xs text-gray-500">
                            {formatCurrency(fornecedor.valor_total)}
                          </div>
                        </td>
                        <td className="px-4 py-4">
                          <span className={getStatusBadge(fornecedor.status)}>
                            {fornecedor.status}
                          </span>
                        </td>
                        <td className="px-4 py-4">
                          <div className="flex space-x-2">
                            <button
                              onClick={() => {
                                setSelectedFornecedor(fornecedor)
                                setShowDetailsModal(true)
                              }}
                              className="text-primary-600 hover:text-primary-900 text-sm font-medium"
                              title="Ver detalhes"
                            >
                              👁️
                            </button>
                            <button
                              onClick={() => {
                                setSelectedFornecedor(fornecedor)
                                setShowEditModal(true)
                              }}
                              className="text-info-600 hover:text-info-900 text-sm font-medium"
                              title="Editar"
                            >
                              ✏️
                            </button>
                            <button
                              onClick={() => handleSearchPNCP(fornecedor.cnpj)}
                              disabled={pncpLoading}
                              className="text-success-600 hover:text-success-900 text-sm font-medium disabled:opacity-50"
                              title="Consultar PNCP"
                            >
                              {pncpLoading ? '⏳' : '🔍'}
                            </button>
                            <button
                              onClick={() => {
                                setSelectedFornecedor(fornecedor)
                                setShowDeleteModal(true)
                              }}
                              className="text-danger-600 hover:text-danger-900 text-sm font-medium"
                              title="Deletar"
                            >
                              🗑️
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            {/* Paginação */}
            {totalPages > 1 && (
              <div className="mt-6 flex flex-col md:flex-row items-center justify-between border-t border-gray-200 pt-4">
                <div className="text-sm text-gray-700 mb-4 md:mb-0">
                  Mostrando {indexOfFirstItem + 1} a {Math.min(indexOfLastItem, filteredFornecedores.length)} de {filteredFornecedores.length} fornecedores
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                    className="px-3 py-2 rounded-lg bg-white border border-gray-300 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    ← Anterior
                  </button>

                  <div className="flex space-x-1">
                    {[...Array(totalPages)].map((_, index) => (
                      <button
                        key={index + 1}
                        onClick={() => setCurrentPage(index + 1)}
                        className={`px-3 py-2 rounded-lg text-sm font-medium ${
                          currentPage === index + 1
                            ? 'bg-primary-600 text-white'
                            : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'
                        }`}
                      >
                        {index + 1}
                      </button>
                    ))}
                  </div>

                  <button
                    onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                    disabled={currentPage === totalPages}
                    className="px-3 py-2 rounded-lg bg-white border border-gray-300 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Próximo →
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Modal Delete */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-xl font-bold text-gray-900 mb-4">
              Confirmar Exclusão
            </h3>
            <p className="text-gray-600 mb-6">
              Tem certeza que deseja excluir o fornecedor <strong>{selectedFornecedor?.razao_social}</strong>?
            </p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => {
                  setShowDeleteModal(false)
                  setSelectedFornecedor(null)
                }}
                className="btn-ghost"
              >
                Cancelar
              </button>
              <button
                onClick={handleDelete}
                className="btn-danger"
              >
                Sim, Excluir
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal Adicionar Fornecedor */}
      <AddFornecedorModal
        isOpen={showAddModal}
        onClose={() => setShowAddModal(false)}
        onSave={(newFornecedor) => {
          setFornecedores(prev => [...prev, {
            ...newFornecedor,
            id: Date.now(),
          }])
          setTotalItems(prev => prev + 1)
          alert('Fornecedor adicionado com sucesso!')
        }}
      />

      {/* Modal Editar Fornecedor */}
      <EditFornecedorModal
        isOpen={showEditModal}
        onClose={() => {
          setShowEditModal(false)
          setSelectedFornecedor(null)
        }}
        fornecedor={selectedFornecedor}
        onSave={(updatedFornecedor) => {
          setFornecedores(prev => prev.map(f => 
            f.id === updatedFornecedor.id ? updatedFornecedor : f
          ))
          alert('Fornecedor atualizado com sucesso!')
        }}
      />

      {/* Modal Detalhes Fornecedor */}
      <FornecedorDetailsModal
        isOpen={showDetailsModal}
        onClose={() => {
          setShowDetailsModal(false)
          setSelectedFornecedor(null)
        }}
        fornecedor={selectedFornecedor}
      />

      {/* Modal PNCP */}
      {showPNCPModal && pncpData && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden">
            {/* Header */}
            <div className="bg-gradient-to-r from-purple-600 to-purple-700 text-white p-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-bold flex items-center gap-3">
                    🔍 Dados do PNCP
                  </h2>
                  <p className="text-purple-100 text-sm mt-1">
                    Informações do Portal Nacional de Contratações Públicas
                  </p>
                </div>
                <button
                  onClick={() => {
                    setShowPNCPModal(false)
                    setPncpData(null)
                  }}
                  className="text-white hover:bg-white hover:bg-opacity-20 rounded-full p-2 transition-colors"
                  title="Fechar"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            {/* Conteúdo */}
            <div className="p-6 overflow-y-auto max-h-[calc(90vh-180px)]">
              {/* Dados Cadastrais */}
              <div className="bg-gray-50 rounded-lg p-4 mb-6">
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                  📋 Dados Cadastrais
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="text-sm font-medium text-gray-600">CNPJ</label>
                    <p className="text-gray-900 font-mono">{formatCNPJorCPF(pncpData.cnpj)}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Situação</label>
                    <p className="text-green-600 font-semibold">{pncpData.situacao_cadastral}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Razão Social</label>
                    <p className="text-gray-900">{pncpData.razao_social}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Nome Fantasia</label>
                    <p className="text-gray-900">{pncpData.nome_fantasia}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Porte</label>
                    <p className="text-gray-900">{pncpData.porte}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Data Abertura</label>
                    <p className="text-gray-900">{new Date(pncpData.data_abertura).toLocaleDateString('pt-BR')}</p>
                  </div>
                </div>
              </div>

              {/* Endereço */}
              <div className="bg-gray-50 rounded-lg p-4 mb-6">
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                  📍 Endereço
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="md:col-span-2">
                    <label className="text-sm font-medium text-gray-600">Logradouro</label>
                    <p className="text-gray-900">{pncpData.logradouro}, {pncpData.numero}</p>
                    {pncpData.complemento && <p className="text-gray-600 text-sm">{pncpData.complemento}</p>}
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Bairro</label>
                    <p className="text-gray-900">{pncpData.bairro}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">CEP</label>
                    <p className="text-gray-900 font-mono">{pncpData.cep}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Município/UF</label>
                    <p className="text-gray-900">{pncpData.municipio} - {pncpData.uf}</p>
                  </div>
                </div>
              </div>

              {/* Contratos */}
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                  📄 Contratos no PNCP ({pncpData.total_contratos})
                </h3>
                <div className="space-y-3">
                  {pncpData.contratos_pncp.map((contrato, index) => (
                    <div key={index} className="bg-white border border-gray-200 rounded-lg p-4">
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <h4 className="font-semibold text-gray-900">Contrato {contrato.numero}</h4>
                          <p className="text-sm text-gray-600">{contrato.objeto}</p>
                        </div>
                        <span className="text-lg font-bold text-green-600">
                          R$ {contrato.valor.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                        </span>
                      </div>
                      <div className="grid grid-cols-2 gap-2 text-sm">
                        <div>
                          <span className="text-gray-600">Assinatura:</span>{' '}
                          <span className="text-gray-900">{new Date(contrato.data_assinatura).toLocaleDateString('pt-BR')}</span>
                        </div>
                        <div>
                          <span className="text-gray-600">Vigência:</span>{' '}
                          <span className="text-gray-900">{new Date(contrato.vigencia).toLocaleDateString('pt-BR')}</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-4 pt-4 border-t border-gray-300">
                  <div className="flex justify-between items-center">
                    <span className="text-lg font-semibold text-gray-800">Valor Total:</span>
                    <span className="text-2xl font-bold text-green-600">
                      R$ {pncpData.valor_total.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Footer */}
            <div className="border-t border-gray-200 bg-gray-50 px-6 py-4">
              <div className="flex justify-between items-center">
                <p className="text-xs text-gray-500">
                  Última atualização: {new Date(pncpData.ultima_atualizacao).toLocaleString('pt-BR')}
                </p>
                <button
                  onClick={() => {
                    setShowPNCPModal(false)
                    setPncpData(null)
                  }}
                  className="px-6 py-2.5 bg-purple-600 text-white font-medium rounded-lg hover:bg-purple-700 transition-colors"
                >
                  Fechar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

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

export default Fornecedores
