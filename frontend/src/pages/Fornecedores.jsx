import { useState, useEffect } from 'react'
import { useAuth } from '@contexts/AuthContext'
import api from '@services/api'

/**
 * Página de Fornecedores para adrisa007/sentinela (ID: 1112237272)
 * 
 * Features:
 * - Tabela paginada de fornecedores
 * - Filtro por CNPJ, Razão Social, Status
 * - Botão adicionar fornecedor
 * - Integração com /fornecedores
 * - Consulta PNCP via /pncp/fornecedor/{cnpj}
 * - Modal para adicionar/editar
 * - Busca em tempo real
 */

function Fornecedores() {
  const { user } = useAuth()
  const [fornecedores, setFornecedores] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  
  // Paginação
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(10)
  const [totalItems, setTotalItems] = useState(0)
  
  // Filtros
  const [filtros, setFiltros] = useState({
    cnpj: '',
    razaoSocial: '',
    status: 'TODOS',
  })
  
  // Modal
  const [showModal, setShowModal] = useState(false)
  const [modalMode, setModalMode] = useState('add') // 'add' ou 'edit'
  const [fornecedorSelecionado, setFornecedorSelecionado] = useState(null)
  
  // Consulta PNCP
  const [consultandoPNCP, setConsultandoPNCP] = useState(false)
  const [dadosPNCP, setDadosPNCP] = useState(null)

  // ==========================================
  // CARREGAR FORNECEDORES
  // ==========================================
  useEffect(() => {
    carregarFornecedores()
  }, [currentPage, filtros])

  const carregarFornecedores = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const params = {
        page: currentPage,
        per_page: itemsPerPage,
        ...filtros,
      }
      
      const { data } = await api.get('/fornecedores', { params })
      
      setFornecedores(data.items || data)
      setTotalItems(data.total || data.length)
      
    } catch (error) {
      console.error('Erro ao carregar fornecedores:', error)
      setError('Erro ao carregar fornecedores. Usando dados de exemplo.')
      
      // Dados mock para desenvolvimento
      usarDadosMock()
    } finally {
      setLoading(false)
    }
  }

  const usarDadosMock = () => {
    const mockData = [
      {
        id: 1,
        cnpj: '12.345.678/0001-90',
        razao_social: 'Empresa de Vigilância Segura Ltda',
        nome_fantasia: 'Segura Vigilância',
        email: 'contato@seguravigi.com.br',
        telefone: '(11) 98765-4321',
        status: 'ATIVO',
        endereco: 'Rua das Flores, 123 - São Paulo/SP',
        data_cadastro: '2024-01-15',
        contratos_ativos: 3,
      },
      {
        id: 2,
        cnpj: '98.765.432/0001-10',
        razao_social: 'TechSecurity Sistemas Ltda',
        nome_fantasia: 'TechSecurity',
        email: 'comercial@techsecurity.com.br',
        telefone: '(11) 3456-7890',
        status: 'ATIVO',
        endereco: 'Av. Paulista, 1000 - São Paulo/SP',
        data_cadastro: '2024-02-20',
        contratos_ativos: 2,
      },
      {
        id: 3,
        cnpj: '11.222.333/0001-44',
        razao_social: 'Segurança Total Brasil S.A.',
        nome_fantasia: 'Total Segurança',
        email: 'contato@totalseg.com.br',
        telefone: '(21) 2222-3333',
        status: 'INATIVO',
        endereco: 'Rua do Comércio, 500 - Rio de Janeiro/RJ',
        data_cadastro: '2023-11-10',
        contratos_ativos: 0,
      },
    ]
    
    setFornecedores(mockData)
    setTotalItems(mockData.length)
  }

  // ==========================================
  // CONSULTAR PNCP
  // ==========================================
  const consultarPNCP = async (cnpj) => {
    setConsultandoPNCP(true)
    setDadosPNCP(null)
    
    try {
      // Remover formatação do CNPJ
      const cnpjLimpo = cnpj.replace(/\D/g, '')
      
      const { data } = await api.get(`/pncp/fornecedor/${cnpjLimpo}`)
      
      setDadosPNCP(data)
      
      // Preencher formulário com dados do PNCP
      if (data) {
        setFornecedorSelecionado({
          ...fornecedorSelecionado,
          razao_social: data.razao_social || data.nome,
          nome_fantasia: data.nome_fantasia,
          email: data.email,
          telefone: data.telefone,
          endereco: data.endereco_completo || `${data.logradouro}, ${data.numero} - ${data.municipio}/${data.uf}`,
        })
      }
      
      return data
      
    } catch (error) {
      console.error('Erro ao consultar PNCP:', error)
      alert('Erro ao consultar PNCP. Verifique o CNPJ e tente novamente.')
      return null
    } finally {
      setConsultandoPNCP(false)
    }
  }

  // ==========================================
  // CRUD OPERATIONS
  // ==========================================
  const handleAdicionar = () => {
    setModalMode('add')
    setFornecedorSelecionado({
      cnpj: '',
      razao_social: '',
      nome_fantasia: '',
      email: '',
      telefone: '',
      status: 'ATIVO',
      endereco: '',
    })
    setDadosPNCP(null)
    setShowModal(true)
  }

  const handleEditar = (fornecedor) => {
    setModalMode('edit')
    setFornecedorSelecionado(fornecedor)
    setShowModal(true)
  }

  const handleSalvar = async () => {
    try {
      if (modalMode === 'add') {
        await api.post('/fornecedores', fornecedorSelecionado)
      } else {
        await api.put(`/fornecedores/${fornecedorSelecionado.id}`, fornecedorSelecionado)
      }
      
      setShowModal(false)
      carregarFornecedores()
      alert('Fornecedor salvo com sucesso!')
      
    } catch (error) {
      console.error('Erro ao salvar fornecedor:', error)
      alert('Erro ao salvar fornecedor. Tente novamente.')
    }
  }

  const handleExcluir = async (id) => {
    if (!confirm('Deseja realmente excluir este fornecedor?')) return
    
    try {
      await api.delete(`/fornecedores/${id}`)
      carregarFornecedores()
      alert('Fornecedor excluído com sucesso!')
    } catch (error) {
      console.error('Erro ao excluir fornecedor:', error)
      alert('Erro ao excluir fornecedor.')
    }
  }

  // ==========================================
  // PAGINAÇÃO
  // ==========================================
  const totalPages = Math.ceil(totalItems / itemsPerPage)
  
  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= totalPages) {
      setCurrentPage(newPage)
    }
  }

  // ==========================================
  // FILTROS
  // ==========================================
  const handleFiltroChange = (campo, valor) => {
    setFiltros(prev => ({ ...prev, [campo]: valor }))
    setCurrentPage(1) // Reset para primeira página
  }

  const limparFiltros = () => {
    setFiltros({
      cnpj: '',
      razaoSocial: '',
      status: 'TODOS',
    })
    setCurrentPage(1)
  }

  // ==========================================
  // RENDER
  // ==========================================
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">🏢 Fornecedores</h1>
          <p className="text-gray-600 mt-1">
            Gerenciar fornecedores e consultar PNCP
          </p>
        </div>
        <button
          onClick={handleAdicionar}
          className="btn-primary flex items-center space-x-2"
        >
          <span>➕</span>
          <span>Adicionar Fornecedor</span>
        </button>
      </div>

      {/* Filtros */}
      <div className="card card-body">
        <h2 className="text-lg font-semibold mb-4">🔍 Filtros</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">CNPJ</label>
            <input
              type="text"
              placeholder="00.000.000/0000-00"
              value={filtros.cnpj}
              onChange={(e) => handleFiltroChange('cnpj', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium mb-1">Razão Social</label>
            <input
              type="text"
              placeholder="Nome da empresa"
              value={filtros.razaoSocial}
              onChange={(e) => handleFiltroChange('razaoSocial', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium mb-1">Status</label>
            <select
              value={filtros.status}
              onChange={(e) => handleFiltroChange('status', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            >
              <option value="TODOS">Todos</option>
              <option value="ATIVO">Ativo</option>
              <option value="INATIVO">Inativo</option>
            </select>
          </div>
          
          <div className="flex items-end">
            <button
              onClick={limparFiltros}
              className="btn-ghost w-full"
            >
              🔄 Limpar Filtros
            </button>
          </div>
        </div>
      </div>

      {/* Tabela */}
      <div className="card card-body">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">
            Lista de Fornecedores ({totalItems})
          </h2>
          <button
            onClick={carregarFornecedores}
            className="text-primary-600 hover:text-primary-700 text-sm"
          >
            🔄 Atualizar
          </button>
        </div>

        {loading ? (
          <div className="flex justify-center py-12">
            <div className="spinner w-12 h-12 border-primary-600"></div>
          </div>
        ) : fornecedores.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-500 text-lg">📋 Nenhum fornecedor encontrado</p>
            <button
              onClick={handleAdicionar}
              className="btn-primary mt-4"
            >
              Adicionar Primeiro Fornecedor
            </button>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-sm font-semibold">CNPJ</th>
                    <th className="px-4 py-3 text-left text-sm font-semibold">Razão Social</th>
                    <th className="px-4 py-3 text-left text-sm font-semibold">Contato</th>
                    <th className="px-4 py-3 text-center text-sm font-semibold">Status</th>
                    <th className="px-4 py-3 text-center text-sm font-semibold">Contratos</th>
                    <th className="px-4 py-3 text-center text-sm font-semibold">Ações</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {fornecedores.map((fornecedor) => (
                    <FornecedorRow
                      key={fornecedor.id}
                      fornecedor={fornecedor}
                      onEditar={handleEditar}
                      onExcluir={handleExcluir}
                      onConsultarPNCP={consultarPNCP}
                    />
                  ))}
                </tbody>
              </table>
            </div>

            {/* Paginação */}
            {totalPages > 1 && (
              <div className="flex justify-center items-center space-x-2 mt-6">
                <button
                  onClick={() => handlePageChange(currentPage - 1)}
                  disabled={currentPage === 1}
                  className="px-3 py-1 border rounded disabled:opacity-50"
                >
                  ← Anterior
                </button>
                
                <span className="text-sm">
                  Página {currentPage} de {totalPages}
                </span>
                
                <button
                  onClick={() => handlePageChange(currentPage + 1)}
                  disabled={currentPage === totalPages}
                  className="px-3 py-1 border rounded disabled:opacity-50"
                >
                  Próxima →
                </button>
              </div>
            )}
          </>
        )}
      </div>

      {/* Modal Adicionar/Editar */}
      {showModal && (
        <ModalFornecedor
          mode={modalMode}
          fornecedor={fornecedorSelecionado}
          onSave={handleSalvar}
          onClose={() => setShowModal(false)}
          onConsultarPNCP={consultarPNCP}
          consultandoPNCP={consultandoPNCP}
          dadosPNCP={dadosPNCP}
          setFornecedor={setFornecedorSelecionado}
        />
      )}
    </div>
  )
}

// ==========================================
// COMPONENTE: FornecedorRow
// ==========================================
function FornecedorRow({ fornecedor, onEditar, onExcluir, onConsultarPNCP }) {
  return (
    <tr className="hover:bg-gray-50 transition">
      <td className="px-4 py-3 text-sm font-mono">{fornecedor.cnpj}</td>
      <td className="px-4 py-3">
        <div>
          <p className="font-medium">{fornecedor.razao_social}</p>
          {fornecedor.nome_fantasia && (
            <p className="text-sm text-gray-500">{fornecedor.nome_fantasia}</p>
          )}
        </div>
      </td>
      <td className="px-4 py-3 text-sm">
        <div>
          <p>📧 {fornecedor.email}</p>
          <p>📞 {fornecedor.telefone}</p>
        </div>
      </td>
      <td className="px-4 py-3 text-center">
        <span className={`badge ${fornecedor.status === 'ATIVO' ? 'badge-success' : 'badge-danger'}`}>
          {fornecedor.status}
        </span>
      </td>
      <td className="px-4 py-3 text-center">
        <span className="font-semibold">{fornecedor.contratos_ativos || 0}</span>
      </td>
      <td className="px-4 py-3">
        <div className="flex justify-center space-x-2">
          <button
            onClick={() => onConsultarPNCP(fornecedor.cnpj)}
            className="text-blue-600 hover:text-blue-700 text-sm"
            title="Consultar PNCP"
          >
            🔍
          </button>
          <button
            onClick={() => onEditar(fornecedor)}
            className="text-primary-600 hover:text-primary-700 text-sm"
            title="Editar"
          >
            ✏️
          </button>
          <button
            onClick={() => onExcluir(fornecedor.id)}
            className="text-red-600 hover:text-red-700 text-sm"
            title="Excluir"
          >
            🗑️
          </button>
        </div>
      </td>
    </tr>
  )
}

// ==========================================
// COMPONENTE: ModalFornecedor
// ==========================================
function ModalFornecedor({
  mode,
  fornecedor,
  onSave,
  onClose,
  onConsultarPNCP,
  consultandoPNCP,
  dadosPNCP,
  setFornecedor,
}) {
  const handleChange = (campo, valor) => {
    setFornecedor(prev => ({ ...prev, [campo]: valor }))
  }

  const handleConsultarClick = async () => {
    if (fornecedor.cnpj) {
      await onConsultarPNCP(fornecedor.cnpj)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
          <h2 className="text-2xl font-bold">
            {mode === 'add' ? '➕ Adicionar Fornecedor' : '✏️ Editar Fornecedor'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 text-2xl"
          >
            ×
          </button>
        </div>

        <div className="p-6 space-y-4">
          {/* CNPJ com botão de consulta PNCP */}
          <div>
            <label className="block text-sm font-medium mb-1">
              CNPJ *
            </label>
            <div className="flex space-x-2">
              <input
                type="text"
                value={fornecedor.cnpj}
                onChange={(e) => handleChange('cnpj', e.target.value)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg"
                placeholder="00.000.000/0000-00"
                required
              />
              <button
                onClick={handleConsultarClick}
                disabled={consultandoPNCP || !fornecedor.cnpj}
                className="btn-secondary flex items-center space-x-2 disabled:opacity-50"
              >
                {consultandoPNCP ? (
                  <>
                    <span className="spinner w-4 h-4 border-white"></span>
                    <span>Consultando...</span>
                  </>
                ) : (
                  <>
                    <span>🔍</span>
                    <span>Consultar PNCP</span>
                  </>
                )}
              </button>
            </div>
            {dadosPNCP && (
              <p className="text-sm text-green-600 mt-1">
                ✅ Dados preenchidos do PNCP
              </p>
            )}
          </div>

          {/* Razão Social */}
          <div>
            <label className="block text-sm font-medium mb-1">Razão Social *</label>
            <input
              type="text"
              value={fornecedor.razao_social}
              onChange={(e) => handleChange('razao_social', e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
          </div>

          {/* Nome Fantasia */}
          <div>
            <label className="block text-sm font-medium mb-1">Nome Fantasia</label>
            <input
              type="text"
              value={fornecedor.nome_fantasia || ''}
              onChange={(e) => handleChange('nome_fantasia', e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
            />
          </div>

          {/* Email e Telefone */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Email</label>
              <input
                type="email"
                value={fornecedor.email || ''}
                onChange={(e) => handleChange('email', e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Telefone</label>
              <input
                type="tel"
                value={fornecedor.telefone || ''}
                onChange={(e) => handleChange('telefone', e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              />
            </div>
          </div>

          {/* Endereço */}
          <div>
            <label className="block text-sm font-medium mb-1">Endereço</label>
            <textarea
              value={fornecedor.endereco || ''}
              onChange={(e) => handleChange('endereco', e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              rows="2"
            />
          </div>

          {/* Status */}
          <div>
            <label className="block text-sm font-medium mb-1">Status</label>
            <select
              value={fornecedor.status}
              onChange={(e) => handleChange('status', e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg"
            >
              <option value="ATIVO">Ativo</option>
              <option value="INATIVO">Inativo</option>
            </select>
          </div>

          {/* Botões */}
          <div className="flex justify-end space-x-3 pt-4">
            <button
              onClick={onClose}
              className="btn-ghost"
            >
              Cancelar
            </button>
            <button
              onClick={onSave}
              className="btn-primary"
            >
              {mode === 'add' ? '➕ Adicionar' : '💾 Salvar'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Fornecedores
