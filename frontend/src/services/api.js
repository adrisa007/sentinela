import axios from 'axios'

/**
 * API Client - adrisa007/sentinela (ID: 1112237272)
 * Backend: https://web-production-8355.up.railway.app
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

console.log('[API] Base URL:', API_BASE_URL)

// Criar instância do axios
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
})

// Request interceptor - adiciona token automaticamente
api.interceptors.request.use(
  (config) => {
    // Log da requisição
    console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`)
    
    // Adicionar token JWT se existir
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    return config
  },
  (error) => {
    console.error('[API Request Error]', error)
    return Promise.reject(error)
  }
)

// Response interceptor - tratamento de erros
api.interceptors.response.use(
  (response) => {
    console.log(`[API Response] ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('[API Response Error]', error.response?.status, error.message)
    
    // Tratamento específico de erros
    if (error.response?.status === 401) {
      // Token inválido ou expirado
      console.warn('[API] Token inválido, fazendo logout...')
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    
    if (error.response?.status === 403) {
      console.warn('[API] Acesso negado')
    }
    
    if (error.response?.status === 503) {
      console.warn('[API] Serviço temporariamente indisponível')
    }
    
    return Promise.reject(error)
  }
)

// ==========================================
// HEALTH ENDPOINTS
// ==========================================

export const fetchHealth = async () => {
  const { data } = await api.get('/health')
  return data
}

export const fetchHealthLive = async () => {
  const { data } = await api.get('/health/live')
  return data
}

export const fetchHealthReady = async () => {
  const { data } = await api.get('/health/ready')
  return data
}

export const fetchHealthNeon = async () => {
  const { data } = await api.get('/health/neon')
  return data
}

// ==========================================
// AUTH ENDPOINTS
// ==========================================

export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  logout: () => api.post('/auth/logout'),
  me: () => api.get('/auth/me'),
  setupMFA: () => api.post('/auth/mfa/setup'),
  verifyMFA: (totpCode) => api.post('/auth/mfa/verify', { totp_code: totpCode }),
  disableMFA: (password) => api.post('/auth/mfa/disable', { password }),
}

// ==========================================
// ROOT ENDPOINT
// ==========================================

export const fetchRoot = async () => {
  const { data } = await api.get('/')
  return data
}

// Exportar instância configurada
export default api
