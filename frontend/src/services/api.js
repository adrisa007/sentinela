import axios from 'axios'

/**
 * API Client para adrisa007/sentinela (ID: 1112237272)
 * Backend: https://web-production-8355.up.railway.app
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor - adiciona token automaticamente
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

// Response interceptor - trata erros de autenticação
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token inválido ou expirado
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

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

export const fetchRoot = async () => {
  const { data } = await api.get('/')
  return data
}

export default api
