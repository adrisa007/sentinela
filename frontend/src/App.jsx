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
