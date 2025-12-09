import { Link } from 'react-router-dom'
import { AlertTriangle } from 'lucide-react'

function NotFoundPage() {
  return (
    <div className="text-center py-20">
      <AlertTriangle className="w-20 h-20 mx-auto mb-6 text-yellow-600" />
      <h1 className="text-6xl font-bold mb-4">404</h1>
      <p className="text-2xl text-gray-600 mb-8">Página não encontrada</p>
      <Link to="/" className="btn-primary">
        Voltar para Home
      </Link>
    </div>
  )
}

export default NotFoundPage
