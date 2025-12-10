#!/bin/bash
# setup_router_axios.sh
# Adiciona React Router + Axios ao frontend
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🛣️  Adicionando React Router + Axios - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Instalar dependências
echo "📦 Instalando React Router e Axios..."
npm install react-router-dom@latest axios@latest

echo "✓ Dependências instaladas"
echo ""

# 2. Criar arquivo de configuração do Axios
echo "🔌 Criando src/services/api.js..."

mkdir -p src/services

cat > src/services/api.js << 'APISERVICE'
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
APISERVICE

echo "✓ src/services/api.js criado"
echo ""

# 3. Atualizar src/main.jsx com React Router
echo "⚛️  Atualizando src/main.jsx com Router..."

cat > src/main.jsx << 'MAINJSX'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App.jsx'
import './index.css'

/**
 * Entry Point - adrisa007/sentinela (ID: 1112237272)
 * React 18 + React Router + Axios
 */

// Log de inicialização
console.log('🛡️ Sentinela Frontend')
console.log('📦 Repository: adrisa007/sentinela (ID: 1112237272)')
console.log('⚛️  React:', React.version)
console.log('🔗 API Backend:', import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app')
console.log('🌐 Environment:', import.meta.env.MODE)

// React 18 createRoot com Router
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
MAINJSX

echo "✓ src/main.jsx atualizado"
echo ""

# 4. Criar App.jsx com rotas completas
echo "📱 Criando src/App.jsx com rotas..."

cat > src/App.jsx << 'APPJSX'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useState, useEffect } from 'react'

/**
 * App Component - adrisa007/sentinela (ID: 1112237272)
 * Main application with React Router
 */
function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)

  useEffect(() => {
    // Verificar se usuário está autenticado
    const token = localStorage.getItem('token')
    setIsAuthenticated(!!token)
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/health" element={<HealthPage />} />

        {/* Protected Routes */}
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute isAuthenticated={isAuthenticated}>
              <DashboardPage />
            </ProtectedRoute>
          }
        />

        {/* 404 */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </div>
  )
}

// Protected Route Component
function ProtectedRoute({ isAuthenticated, children }) {
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  return children
}

// ==========================================
// PAGES
// ==========================================

// Home Page
function HomePage() {
  return (
    <div className="flex items-center justify-center min-h-screen px-4">
      <div className="text-center">
        <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-6">
          <span className="text-6xl">🛡️</span>
        </div>
        
        <h1 className="text-5xl font-bold mb-3">
          <span className="gradient-text">Sentinela</span>
        </h1>
        
        <p className="text-xl text-gray-600 mb-2">
          Vigilância total, risco zero.
        </p>
        
        <div className="mt-8 space-y-2 text-sm text-gray-500">
          <p>⚛️  React 18 + Vite 5</p>
          <p>🛣️  React Router 6</p>
          <p>🔌 Axios 1.6</p>
          <p>🎨 Tailwind CSS 3</p>
        </div>

        <div className="mt-8 flex flex-wrap justify-center gap-4">
          <a
            href="/dashboard"
            className="btn-primary"
          >
            📊 Dashboard
          </a>
          <a
            href="/health"
            className="btn-secondary"
          >
            💚 Health Check
          </a>
          <a
            href="https://web-production-8355.up.railway.app/docs"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-outline"
          >
            📚 API Docs
          </a>
        </div>

        <div className="mt-12 text-xs text-gray-400">
          <p>adrisa007/sentinela | Repository ID: 1112237272</p>
        </div>
      </div>
    </div>
  )
}

// Login Page
function LoginPage() {
  return (
    <div className="flex items-center justify-center min-h-screen px-4">
      <div className="card max-w-md w-full">
        <div className="card-body">
          <div className="text-center mb-6">
            <div className="text-5xl mb-4">🔐</div>
            <h2 className="text-2xl font-bold">Login</h2>
            <p className="text-gray-600 mt-2">Entre com suas credenciais</p>
          </div>

          <form className="space-y-4">
            <div>
              <label className="form-label">Email</label>
              <input
                type="email"
                className="form-input"
                placeholder="seu@email.com"
              />
            </div>

            <div>
              <label className="form-label">Senha</label>
              <input
                type="password"
                className="form-input"
                placeholder="••••••••"
              />
            </div>

            <button type="submit" className="btn-primary w-full">
              Entrar
            </button>
          </form>

          <p className="text-center text-sm text-gray-500 mt-4">
            Sistema Sentinela - adrisa007/sentinela
          </p>
        </div>
      </div>
    </div>
  )
}

// Dashboard Page
function DashboardPage() {
  return (
    <div className="container py-8">
      <h1 className="text-4xl font-bold mb-8">📊 Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card">
          <div className="card-body">
            <h3 className="text-lg font-semibold mb-2">Total</h3>
            <p className="text-3xl font-bold text-primary-600">171</p>
          </div>
        </div>
        
        <div className="card">
          <div className="card-body">
            <h3 className="text-lg font-semibold mb-2">Passou</h3>
            <p className="text-3xl font-bold text-success-600">137</p>
          </div>
        </div>
        
        <div className="card">
          <div className="card-body">
            <h3 className="text-lg font-semibold mb-2">Cobertura</h3>
            <p className="text-3xl font-bold text-info-600">80%</p>
          </div>
        </div>
      </div>
    </div>
  )
}

// Health Page
function HealthPage() {
  const [health, setHealth] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchHealthData()
  }, [])

  const fetchHealthData = async () => {
    try {
      const response = await fetch('https://web-production-8355.up.railway.app/health')
      const data = await response.json()
      setHealth(data)
    } catch (error) {
      console.error('Erro ao buscar health:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="container py-8">
      <h1 className="text-4xl font-bold mb-8">💚 Health Check</h1>
      
      {loading ? (
        <div className="flex justify-center">
          <div className="spinner w-12 h-12 border-primary-600"></div>
        </div>
      ) : (
        <div className="card">
          <div className="card-body">
            <pre className="bg-gray-100 p-4 rounded-lg overflow-auto">
              {JSON.stringify(health, null, 2)}
            </pre>
          </div>
        </div>
      )}
    </div>
  )
}

// 404 Page
function NotFoundPage() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <div className="text-8xl mb-4">⚠️</div>
        <h1 className="text-6xl font-bold mb-4">404</h1>
        <p className="text-2xl text-gray-600 mb-8">Página não encontrada</p>
        <a href="/" className="btn-primary">
          🏠 Voltar para Home
        </a>
      </div>
    </div>
  )
}

export default App
APPJSX

echo "✓ src/App.jsx criado"
echo ""

# 5. Criar .env com URL da API
echo "🔐 Criando .env..."

cat > .env << 'ENV'
VITE_API_URL=https://web-production-8355.up.railway.app
ENV

cat > .env.example << 'ENVEX'
# API Backend URL
VITE_API_URL=https://web-production-8355.up.railway.app

# Para desenvolvimento local, descomente abaixo:
# VITE_API_URL=http://localhost:8000
ENVEX

echo "✓ .env criado"
echo ""

# 6. Criar README para Router e Axios
cat > docs/ROUTER_AXIOS_GUIDE.md << 'GUIDE'
# React Router + Axios Guide - adrisa007/sentinela (ID: 1112237272)

## 🛣️  React Router

### Rotas Configuradas

| Path | Component | Protected |
|------|-----------|-----------|
| `/` | HomePage | ❌ Public |
| `/login` | LoginPage | ❌ Public |
| `/health` | HealthPage | ❌ Public |
| `/dashboard` | DashboardPage | ✅ Protected |
| `*` | NotFoundPage | ❌ Public |

### Navegação

```jsx
import { Link, useNavigate } from 'react-router-dom'

// Link Component
<Link to="/dashboard">Dashboard</Link>

// Programmatic Navigation
const navigate = useNavigate()
navigate('/dashboard')
navigate(-1) // Voltar