import { Link } from 'react-router-dom'
import { Shield, Activity, LayoutDashboard } from 'lucide-react'

function Layout({ children }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      {/* Header */}
      <header className="bg-white shadow-md">
        <nav className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Link to="/" className="flex items-center space-x-2">
              <Shield className="w-8 h-8 text-primary-600" />
              <span className="text-2xl font-bold bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent">
                Sentinela
              </span>
            </Link>
            
            <div className="flex items-center space-x-6">
              <Link to="/" className="flex items-center space-x-1 hover:text-primary-600 transition-colors">
                <Shield className="w-5 h-5" />
                <span>Home</span>
              </Link>
              <Link to="/dashboard" className="flex items-center space-x-1 hover:text-primary-600 transition-colors">
                <LayoutDashboard className="w-5 h-5" />
                <span>Dashboard</span>
              </Link>
              <Link to="/health" className="flex items-center space-x-1 hover:text-primary-600 transition-colors">
                <Activity className="w-5 h-5" />
                <span>Health</span>
              </Link>
            </div>
          </div>
        </nav>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-gray-900 text-white mt-16">
        <div className="container mx-auto px-4 py-8 text-center">
          <p className="text-lg font-semibold mb-2">🛡️ Sentinela</p>
          <p className="text-gray-400">Vigilância total, risco zero.</p>
          <p className="text-gray-500 text-sm mt-4">
            Repository ID: 1112237272 | adrisa007/sentinela
          </p>
        </div>
      </footer>
    </div>
  )
}

export default Layout
