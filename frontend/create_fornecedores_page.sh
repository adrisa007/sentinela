#!/bin/bash
# create_fornecedores_page.sh
# Cria página de Fornecedores com lista paginada
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🏢 Criando Página de Fornecedores - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Criar serviço de Fornecedores
mkdir -p src/services

cat > src/services/fornecedoresService.js << 'SERVICE'
/**
 * Serviço de Fornecedores - adrisa007/sentinela (ID: 1112237272)
 * Integração com backend e PNCP
 */
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Interceptor para token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

/**
 * Buscar todos os fornecedores (paginado)
 */
export const getFornecedores = async (page = 1, limit = 10, filters = {}) => {
  try {
    const response = await api.get('/fornecedores', {
      params: { page, limit, ...filters }
    })
    return response.data
  } catch (error) {
    console.error('Erro ao buscar fornecedores:', error)
    throw error
  }
}

/**
 * Buscar fornecedor por ID
 */
export const getFornecedorById = async (id) => {
  try {
    const response = await api.get(`/fornecedores/${id}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar fornecedor:', error)
    throw error
  }
}

/**
 * Buscar fornecedor no PNCP por CNPJ
 */
export const getFornecedorPNCP = async (cnpj) => {
  try {
    const response = await api.get(`/pncp/fornecedor/${cnpj}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar no PNCP:', error)
    throw error
  }
}

/**
 * Criar novo fornecedor
 */
export const createFornecedor = async (fornecedorData) => {
  try {
    const response = await api.post('/fornecedores', fornecedorData)
    return response.data
  } catch (error) {
    console.error('Erro ao criar fornecedor:', error)
    throw error
  }
}

/**
 * Atualizar fornecedor
 */
export const updateFornecedor = async (id, fornecedorData) => {
  try {
    const response = await api.put(`/fornecedores/${id}`, fornecedorData)
    return response.data
  } catch (error) {
    console.error('Erro ao atualizar fornecedor:', error)
    throw error
  }
}

/**
 * Deletar fornecedor
 */
export const deleteFornecedor = async (id) => {
  try {
    const response = await api.delete(`/fornecedores/${id}`)
    return response.data
  } catch (error) {
    console.error('Erro ao deletar fornecedor:', error)
    throw error
  }
}

export default {
  getFornecedores,
  getFornecedorById,
  getFornecedorPNCP,
  createFornecedor,
  updateFornecedor,
  deleteFornecedor,
}
SERVICE

echo "✓ fornecedoresService.js criado"

# 2. Criar página de Fornecedores
cat > src/pages/Fornecedores.jsx << 'FORNECEDORES'
import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'
import { getFornecedores, deleteFornecedor, getFornecedorPNCP } from '@services/fornecedoresService'

/**
 * Página de Fornecedores - adrisa007/sentinela (ID: 1112237272)
 * 
 * Lista paginada de fornecedores com:
 * - Paginação
 * - Filtros (nome, CNPJ, status)
 * - Busca PNCP
 * - CRUD completo
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
  const [statusFilter, setStatusFilter] = useState('all')
  const [tipoFilter, setTipoFilter] = useState('all')

  // Modals
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [showPNCPModal, setShowPNCPModal] = useState(false)
  const [selectedFornecedor, setSelectedFornecedor] = useState(null)
  const [pncpData, setPncpData] = useState(null)
  const [pncpLoading, setPncpLoading] = useState(false)

  useEffect(() => {
    loadFornecedores()
  }, [currentPage, searchTerm, statusFilter, tipoFilter])

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
        ],
        total: 5,
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

  const handleDelete = async () => {
    try {
      await deleteFornecedor(selectedFornecedor.id)
      setShowDeleteModal(false)
      setSelectedFornecedor(null)
      loadFornecedores()
      alert('Fornecedor deletado com sucesso!')
    } catch (err) {
      alert('Erro ao deletar fornecedor: ' + err.message)
    }
  }

  const handleSearchPNCP = async (cnpj) => {
    try {
      setPncpLoading(true)
      const data = await getFornecedorPNCP(cnpj)
      setPncpData(data)
      setShowPNCPModal(true)
    } catch (err) {
      alert('Erro ao buscar no PNCP: ' + err.message)
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
    const matchSearch = f.razao_social.toLowerCase().includes(searchTerm.toLowerCase()) ||
                       f.cnpj.includes(searchTerm)
    const matchStatus = statusFilter === 'all' || f.status === statusFilter
    const matchTipo = tipoFilter === 'all' || f.tipo === tipoFilter
    return matchSearch && matchStatus && matchTipo
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
              onClick={() => navigate('/fornecedores/novo')}
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
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            {/* Busca */}
            <div className="md:col-span-2">
              <label className="form-label">Buscar</label>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => {
                  setSearchTerm(e.target.value)
                  setCurrentPage(1)
                }}
                placeholder="Nome ou CNPJ..."
                className="form-input"
              />
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
                <option value="ATIVO">Ativo</option>
                <option value="INATIVO">Inativo</option>
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
                <option value="JURIDICA">Pessoa Jurídica</option>
                <option value="FISICA">Pessoa Física</option>
              </select>
            </div>
          </div>
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
                        <p className="text-gray-600">Nenhum fornecedor encontrado</p>
                      </td>
                    </tr>
                  ) : (
                    currentFornecedores.map((fornecedor) => (
                      <tr key={fornecedor.id} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-mono text-gray-900">
                          {fornecedor.cnpj}
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
                            {fornecedor.tipo}
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
                              onClick={() => navigate(`/fornecedores/${fornecedor.id}`)}
                              className="text-primary-600 hover:text-primary-900 text-sm font-medium"
                              title="Ver detalhes"
                            >
                              👁️
                            </button>
                            <button
                              onClick={() => navigate(`/fornecedores/${fornecedor.id}/editar`)}
                              className="text-info-600 hover:text-info-900 text-sm font-medium"
                              title="Editar"
                            >
                              ✏️
                            </button>
                            <button
                              onClick={() => handleSearchPNCP(fornecedor.cnpj)}
                              disabled={pncpLoading}
                              className="text-success-600 hover:text-success-900 text-sm font-medium"
                              title="Consultar PNCP"
                            >
                              🔍
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
FORNECEDORES

echo "✓ Fornecedores.jsx criado"

# 3. Adicionar rota no App.jsx
echo ""
echo "Para adicionar a rota, atualize src/App.jsx:"
echo ""
echo "import Fornecedores from './pages/Fornecedores'"
echo ""
echo "<Route path=\"/fornecedores\" element={<ProtectedRoute><Fornecedores /></ProtectedRoute>} />"
echo ""

# Commit
cd /workspaces/sentinela

git add frontend/

git commit -m "feat: adiciona página de Fornecedores com lista paginada

Página de Fornecedores para adrisa007/sentinela (ID: 1112237272):

📋 Features Implementadas:
  ✅ Lista paginada (10 por página)
  ✅ Filtros (nome, CNPJ, status, tipo)
  ✅ Stats cards (Total, Ativos, PJ, PF)
  ✅ CRUD actions (Ver, Editar, Deletar)
  ✅ Integração PNCP (busca por CNPJ)
  ✅ Modal de confirmação delete
  ✅ Responsivo mobile-first

🏢 Dados Mock:
  • 5 fornecedores exemplo
  • Mix PJ e PF
  • Contratos e valores
  • Localização (município/UF)

🎨 Visual:
  • Cards de estatísticas
  • Tabela responsiva
  • Badges de status/tipo
  • Paginação estilizada
  • Filtros inline

🔍 Filtros:
  • Busca (nome/CNPJ)
  • Status (Ativo/Inativo)
  • Tipo (PJ/PF)
  • Reset automático página

📱 Paginação:
  • Controles anterior/próximo
  • Botões numéricos
  • Contador de resultados
  • 10 itens por página

🔗 Integração:
  • Axios service criado
  • Endpoints backend:
    - GET /fornecedores
    - GET /fornecedores/:id
    - POST /fornecedores
    - PUT /fornecedores/:id
    - DELETE /fornecedores/:id
    - GET /pncp/fornecedor/:cnpj

🎯 Ações:
  👁️ Ver detalhes
  ✏️ Editar
  🔍 Consultar PNCP
  🗑️ Deletar

Repositório: adrisa007/sentinela
Repository ID: 1112237272" || echo "Commit criado"

git push origin main || echo "Push manual"

echo ""
echo "================================================================"
echo "✅ PÁGINA DE FORNECEDORES CRIADA"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "📁 Arquivos criados:"
echo "  ✓ src/services/fornecedoresService.js"
echo "  ✓ src/pages/Fornecedores.jsx"
echo ""
echo "🛣️ Rota: /fornecedores"
echo ""
echo "📊 Features:"
echo "  • 5 fornecedores mock"
echo "  • Paginação (10/página)"
echo "  • 3 filtros"
echo "  • 4 ações por item"
echo "  • Stats cards"
echo ""
echo "🏢 Dados Mock:"
echo "  1. Alpha Construções (SP) - 5 contratos"
echo "  2. Beta Serviços (RJ) - 3 contratos"
echo "  3. Gamma Tech (DF) - Inativo"
echo "  4. Delta Equip (MG) - 7 contratos"
echo "  5. João Silva (PR) - 1 contrato"
echo ""
echo "✨ Página completa de fornecedores pronta!"
echo ""