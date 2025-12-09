import axios from 'axios'

/**
 * API Client para Sentinela Backend
 * Repository: adrisa007/sentinela (ID: 1112237272)
 * Backend: https://web-production-8355.up.railway.app
 */

// Base URL - usa proxy do Vite em dev, URL completa em produção
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

console.log('API Base URL:', API_BASE_URL)

// Criar instância do axios
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
})

// Request interceptor - log e adicionar headers
api.interceptors.request.use(
  (config) => {
    console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`)
    
    // Adicionar token se existir
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    return config
  },
  (error) => {
    console.error('[API] Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor - tratamento de erros
api.interceptors.response.use(
  (response) => {
    console.log(`[API] ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('[API] Response Error:', error.response?.status, error.message)
    
    // Tratamento específico de erros
    if (error.response?.status === 401) {
      console</body>
