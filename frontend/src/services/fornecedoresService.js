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
  console.log('Token encontrado:', token ? 'SIM' : 'NÃO')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Interceptor para erros (redirecionar 401)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      console.error('Erro 401: Token inválido ou expirado')
      // Limpar dados de autenticação
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      // Redirecionar para login
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

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
    console.log('API Base URL:', API_URL)
    console.log('Chamando endpoint:', `/pncp/fornecedor/${cnpj}`)
    console.log('URL completa:', `${API_URL}/pncp/fornecedor/${cnpj}`)
    const response = await api.get(`/pncp/fornecedor/${cnpj}`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar no PNCP:', error)
    console.error('Erro details:', {
      message: error.message,
      response: error.response,
      request: error.request,
      config: error.config
    })
    throw error
  }
}

/**
 * 🔧 Teste do endpoint PNCP sem autenticação (debug)
 */
export const testPNCPConnection = async (cnpj) => {
  try {
    console.log('🧪 TESTE: Chamando endpoint sem auth:', `/pncp/test/${cnpj}`)
    const response = await api.get(`/pncp/test/${cnpj}`)
    console.log('🧪 TESTE: Resposta recebida:', response.data)
    return response.data
  } catch (error) {
    console.error('🧪 TESTE: Erro na conexão:', error)
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
