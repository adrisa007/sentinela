/**
 * Serviço de Certidões - adrisa007/sentinela (ID: 1112237272)
 * Integração com backend via Axios
 */
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

// Configurar axios com interceptors
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Interceptor para adicionar token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Interceptor para tratar erros
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

/**
 * Buscar certidões vencendo
 */
export const getCertidoesVencendo = async (dias = 30) => {
  try {
    const response = await api.get(`/certidoes/vencendo`, {
      params: { dias }
    })
    return response.data
  } catch (error) {
    console.error('Erro ao buscar certidões vencendo:', error)
    throw error
  }
}

/**
 * Buscar todas as certidões de uma entidade
 */
export const getCertidoesByEntidade = async (entidadeId) => {
  try {
    const response = await api.get(`/entidades/${entidadeId}/certidoes`)
    return response.data
  } catch (error) {
    console.error('Erro ao buscar certidões da entidade:', error)
    throw error
  }
}

/**
 * Criar nova certidão
 */
export const createCertidao = async (certidaoData) => {
  try {
    const response = await api.post('/certidoes', certidaoData)
    return response.data
  } catch (error) {
    console.error('Erro ao criar certidão:', error)
    throw error
  }
}

/**
 * Atualizar certidão
 */
export const updateCertidao = async (certidaoId, certidaoData) => {
  try {
    const response = await api.put(`/certidoes/${certidaoId}`, certidaoData)
    return response.data
  } catch (error) {
    console.error('Erro ao atualizar certidão:', error)
    throw error
  }
}

/**
 * Renovar certidão
 */
export const renovarCertidao = async (certidaoId, novaValidade) => {
  try {
    const response = await api.patch(`/certidoes/${certidaoId}/renovar`, {
      data_validade: novaValidade
    })
    return response.data
  } catch (error) {
    console.error('Erro ao renovar certidão:', error)
    throw error
  }
}

/**
 * Buscar estatísticas de certidões
 */
export const getCertidoesStats = async () => {
  try {
    const response = await api.get('/certidoes/stats')
    return response.data
  } catch (error) {
    console.error('Erro ao buscar estatísticas de certidões:', error)
    throw error
  }
}

export default {
  getCertidoesVencendo,
  getCertidoesByEntidade,
  createCertidao,
  updateCertidao,
  renovarCertidao,
  getCertidoesStats,
}
