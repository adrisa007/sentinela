import { Routes, Route } from 'react-router-dom'

/**
 * App Component - adrisa007/sentinela (ID: 1112237272)
 * Main application with React Router
 */
function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </div>
  )
}

// Home Page Component
function HomePage() {
  return (
    <div className="flex items-center justify-center min-h-screen px-4">
      <div className="text-center">
        <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-6">
          <span className="text-6xl">🛡️</span>
        </div>
        
        <h1 className="text-5xl font-bold mb-3">
          <span className="bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent">
            Sentinela
          </span>
        </h1>
        
        <p className="text-xl text-gray-600 mb-2">
          Vigilância total, risco zero.
        </p>
        
        <div className="mt-8 space-y-2 text-sm text-gray-500">
          <p>⚛️  React 18.2 + Vite 5.1</p>
          <p>🎨 Tailwind CSS 3.4</p>
          <p>📦 Repository: adrisa007/sentinela</p>
          <p>🆔 ID: 1112237272</p>
        </div>

        <div className="mt-8 flex justify-center space-x-4">
          <a
            href="https://web-production-8355.up.railway.app/docs"
            target="_blank"
            rel="noopener noreferrer"
            className="px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            📚 API Docs
          </a>
          <a
            href="https://github.com/adrisa007/sentinela"
            target="_blank"
            rel="noopener noreferrer"
            className="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
          >
            🐙 GitHub
          </a>
        </div>
      </div>
    </div>
  )
}

// 404 Page
function NotFound() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <div className="text-8xl mb-4">⚠️</div>
        <h1 className="text-4xl font-bold mb-2">404</h1>
        <p className="text-gray-600">Página não encontrada</p>
      </div>
    </div>
  )
}

export default App
