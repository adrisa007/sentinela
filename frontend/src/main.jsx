import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App.jsx'
import './index.css'

/**
 * Entry point - adrisa007/sentinela (ID: 1112237272)
 * React 18 com createRoot API
 */

console.log('🛡️ Sentinela Frontend')
console.log('Repository: adrisa007/sentinela (ID: 1112237272)')
console.log('React version:', React.version)
console.log('Backend API:', import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app')

// React 18 createRoot API
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
