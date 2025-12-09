import { Link } from 'react-router-dom'

function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="flex items-center justify-center min-h-screen px-4">
        <div className="text-center">
          <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-6 animate-pulse-slow">
            <span className="text-6xl">🛡️</span>
          </div>
          
          <h1 className="text-6xl font-bold mb-3">
            <span className="gradient-text">Sentinela</span>
          </h1>
          
          <p className="text-2xl text-gray-600 mb-2">
            Vigilância total, risco zero.
          </p>
          
          <p className="text-sm text-gray-500 mb-8">
            Sistema de Monitoramento e Segurança
          </p>
          
          <div className="space-y-2 text-sm text-gray-500 mb-8">
            <p>⚛️ React 18.2</p>
            <p>⚡ Vite 5.1</p>
            <p>🎨 Tailwind CSS 3.4</p>
            <p>🛣️ React Router 6</p>
          </div>
          
          <div className="space-y-4">
            <Link to="/login" className="btn-primary inline-block px-8 py-3 text-lg">
              🔐 Ir para Login
            </Link>
            
            <div className="flex justify-center space-x-4 text-sm">
              <a
                href="https://web-production-8355.up.railway.app/docs"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary-600 hover:text-primary-700"
              >
                📚 API Docs
              </a>
              <span className="text-gray-300">•</span>
              <a
                href="https://github.com/adrisa007/sentinela"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary-600 hover:text-primary-700"
              >
                🐙 GitHub
              </a>
            </div>
          </div>
          
          <div className="mt-12 text-xs text-gray-400">
            <p>adrisa007/sentinela | Repository ID: 1112237272</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default HomePage
