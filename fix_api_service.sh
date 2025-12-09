#!/bin/bash
# fix_api_service.sh
# Corrige src/services/api.js para adrisa007/sentinela (ID: 1112237272)

echo "🔧 Corrigindo src/services/api.js"
echo "Repositório: adrisa007/sentinela (ID: 1112237272)"
echo ""

cd frontend

# Criar api.js completo e correto
cat > src/services/api.js << 'APISERVICE'
import axios from 'axios'

/**
 * API Client para Sentinela Backend
 * Repository: adrisa007/sentinela (ID: 1112237272)
 * Backend: https://web-production-8355.up.railway.app
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

// Criar instância do axios
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Log da requisição
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

// Response interceptor
api.interceptors.response.use(
  (response) => {
    console.log(`[API] ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('[API] Response Error:', error.response?.status, error.message)
    
    // Tratamento de erros comuns
    if (error.response?.status === 401) {
      // Token inválido ou expirado
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    
    if (error.response?.status === 503) {
      console.warn('[API] Service temporarily unavailable')
    }
    
    return Promise.reject(error)
  }
)

// ==========================================
// ENDPOINTS DA API
// ==========================================

/**
 * Root endpoint - Informações gerais da API
 */
export const fetchRoot = async () => {
  const { data } = await api.get('/')
  return data
}

/**
 * Health Check - Status geral do sistema
 */
export const fetchHealth = async () => {
  const { data } = await api.get('/health')
  return data
}

/**
 * Health Live - Liveness check (Redis)
 */
export const fetchHealthLive = async () => {
  const { data } = await api.get('/health/live')
  return data
}

/**
 * Health Ready - Readiness check (Database)
 */
export const fetchHealthReady = async () => {
  const { data } = await api.get('/health/ready')
  return data
}

/**
 * Health Neon - Informações do Neon Database
 */
export const fetchHealthNeon = async () => {
  const { data } = await api.get('/health/neon')
  return data
}

/**
 * Login - Autenticação de usuário
 */
export const login = async (credentials) => {
  const { data } = await api.post('/auth/login', credentials)
  if (data.token) {
    localStorage.setItem('token', data.token)
  }
  return data
}

/**
 * Logout - Encerrar sessão
 */
export const logout = () => {
  localStorage.removeItem('token')
  window.location.href = '/'
}

/**
 * Get Current User
 */
export const getCurrentUser = async () => {
  const { data } = await api.get('/auth/me')
  return data
}

// Exportar instância configurada
export default api
APISERVICE

echo "✓ src/services/api.js corrigido"

# Criar .env.example
cat > .env.example << 'ENVEXAMPLE'
# API Backend URL
VITE_API_URL=https://web-production-8355.up.railway.app

# Para desenvolvimento local, comente a linha acima e descomente abaixo:
# VITE_API_URL=http://localhost:8000
ENVEXAMPLE

echo "✓ .env.example criado"

# Criar .env para desenvolvimento
cat > .env << 'ENV'
VITE_API_URL=https://web-production-8355.up.railway.app
ENV

echo "✓ .env criado"

echo ""
echo "================================================================"
echo "✅ API SERVICE CORRIGIDO"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo "🔗 API Backend: https://web-production-8355.up.railway.app"
echo ""
echo "📁 Arquivos criados/corrigidos:"
echo "  ✓ src/services/api.js (completo)"
echo "  ✓ .env.example"
echo "  ✓ .env"
echo ""
echo "🔌 Endpoints disponíveis:"
echo "  • fetchRoot()"
echo "  • fetchHealth()"
echo "  • fetchHealthLive()"
echo "  • fetchHealthReady()"
echo "  • fetchHealthNeon()"
echo "  • login(credentials)"
echo "  • logout()"
echo "  • getCurrentUser()"
echo ""
echo "🚀 Próximos passos:"
echo "  npm install"
echo "  npm run dev"
echo ""