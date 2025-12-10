import { Navigate, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

/**
 * Componente de Rota Protegida - adrisa007/sentinela (ID: 1112237272)
 */

function ProtectedRoute({ children, requiredRole }) {
  const { user, loading, isAuthenticated } = useAuth()
  const location = useLocation()

  console.log('[ProtectedRoute]', { user, loading, isAuthenticated, location: location.pathname })

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
        <div className="text-center">
          <div className="spinner w-16 h-16 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Verificando autenticação...</p>
        </div>
      </div>
    )
  }

  if (!isAuthenticated || !user) {
    console.log('[ProtectedRoute] Não autenticado, redirecionando para login')
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  if (requiredRole && user.role !== requiredRole) {
    console.log('[ProtectedRoute] Sem permissão:', { userRole: user.role, requiredRole })
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
        <div className="card card-body max-w-md text-center">
          <span className="text-6xl mb-4">🚫</span>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Acesso Negado</h2>
          <p className="text-gray-600 mb-4">
            Você não tem permissão para acessar esta página.
          </p>
          <p className="text-sm text-gray-500 mb-4">
            Seu perfil: <strong>{user.role}</strong><br/>
            Perfil necessário: <strong>{requiredRole}</strong>
          </p>
          <button
            onClick={() => window.history.back()}
            className="btn-primary"
          >
            ← Voltar
          </button>
        </div>
      </div>
    )
  }

  console.log('[ProtectedRoute] Acesso permitido')
  return children
}

export default ProtectedRoute
