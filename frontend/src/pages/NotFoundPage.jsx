import { Link } from 'react-router-dom'

/**
 * NotFoundPage - adrisa007/sentinela (ID: 1112237272)
 */

function NotFoundPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="text-center">
        <div className="text-9xl mb-6 animate-bounce">⚠️</div>
        <h1 className="text-6xl font-bold mb-4">404</h1>
        <p className="text-2xl text-gray-600 mb-8">Página não encontrada</p>
        <Link to="/" className="btn-primary text-lg">
          🏠 Voltar para Home
        </Link>
        <p className="mt-8 text-sm text-gray-500">
          adrisa007/sentinela | Repository ID: 1112237272
        </p>
      </div>
    </div>
  )
}

export default NotFoundPage
