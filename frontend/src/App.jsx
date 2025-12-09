import { Routes, Route } from 'react-router-dom'

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Routes>
        <Route path="/" element={<Home />} />
      </Routes>
    </div>
  )
}

function Home() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <div className="text-6xl mb-4">🛡️</div>
        <h1 className="text-4xl font-bold text-primary-600 mb-2">
          Sentinela
        </h1>
        <p className="text-gray-600">
          adrisa007/sentinela (ID: 1112237272)
        </p>
        <p className="text-gray-500 mt-4">
          Frontend React + Vite + Tailwind CSS
        </p>
      </div>
    </div>
  )
}

export default App
