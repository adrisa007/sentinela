import { Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import HomePage from './pages/HomePage'
import Login from './pages/Login'
import DashboardGestor from './pages/DashboardGestor'
import ProtectedRoute from './components/ProtectedRoute'

/**
 * App Principal - adrisa007/sentinela (ID: 1112237272)
 */

function App() {
  return (
    <AuthProvider>
      <Routes>
        {/* Rotas Públicas */}
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<Login />} />

        {/* Rotas Protegidas */}
        <Route 
          path="/dashboard/gestor" 
          element={
            <ProtectedRoute>
              <DashboardGestor />
            </ProtectedRoute>
          } 
        />
        
        {/* Redirect padrão */}
        <Route path="/dashboard" element={<Navigate to="/dashboard/gestor" replace />} />
        
        {/* 404 */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  )
}

export default App
