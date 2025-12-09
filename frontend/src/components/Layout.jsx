import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@contexts/AuthContext'

function Layout({ children }) {
  const { isAuthenticated, user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const isGestorOrRoot = user && ['ROOT', 'GESTOR'].includes(user.role)

  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-white shadow">
        <nav className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <Link to="/" className="flex items-center space-x-2">
              <span className="text-3xl">🛡️</span>
              <span className="text-2xl font-bold text-primary-600">Sentinela</span>
            </Link>

            <div className="flex items-center space-x-6">
              <Link to="/" className="hover:text-primary-600 transition">
                🏠 Home
              </Link>
              {isAuthenticated && (
                <>
                  <Link to="/dashboard" className="hover:text-primary-600 transition">
                    📊 Dashboard
                  </Link>
                  {isGestorOrRoot && (
                    <Link to="/dashboard/gestor" className="hover:text-primary-600 transition">
                      📈 Dashboard Gestor
                    </Link>
                  )}
                </>
              )}
              <Link to="/health" className="hover:text-primary-600 transition">
                💚 Health
              </Link>

              {isAuthenticated ? (
                <div className="flex items-center space-x-4">
                  <span className="text-sm text-gray-600">
                    👤 {user?.username}
                    {user?.role && (
                      <span className="ml-2 badge badge-success text-xs">
                        {user.role}
                      </span>
                    )}
                  </span>
                  <button onClick={handleLogout} className="btn-ghost text-sm">
                    🚪 Sair
                  </button>
                </div>
              ) : (
                <Link to="/login" className="btn-primary">
                  🔐 Login
                </Link>
              )}
            </div>
          </div>
        </nav>
      </header>

      <main className="flex-1 container mx-auto px-4 py-8">
        {children}
      </main>

      <footer className="bg-gray-900 text-white py-8 mt-auto">
        <div className="container mx-auto text-center">
          <p className="text-lg font-semibold">🛡️ Sentinela</p>
          <p className="text-gray-400 mt-2">Vigilância total, risco zero.</p>
          <p className="text-gray-500 text-sm mt-4">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
        </div>
      </footer>
    </div>
  )
}

export default Layout
