import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App.jsx'
import './index.css'

// Log de inicialização
console.log('🛡️ Sentinela Frontend')
console.log('Repository: adrisa007/sentinela')
console.log('Repository ID: 1112237272')
console.log('API Backend: https://web-production-8355.up.railway.app')

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
