import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App.jsx'
import './index.css'

/**
 * Entry Point - adrisa007/sentinela (ID: 1112237272)
 * React 18 + React Router + Axios
 */

// Log de inicialização
console.log('🛡️ Sentinela Frontend')
console.log('📦 Repository: adrisa007/sentinela (ID: 1112237272)')
console.log('⚛️  React:', React.version)
console.log('🔗 API Backend:', import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app')
console.log('🌐 Environment:', import.meta.env.MODE)

// React 18 createRoot com Router
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
