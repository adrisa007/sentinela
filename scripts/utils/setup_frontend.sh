#!/bin/bash
# configure_frontend_complete.sh
# Configuração completa do frontend para adrisa007/sentinela (ID: 1112237272)

echo "⚙️  CONFIGURAÇÃO COMPLETA DO FRONTEND"
echo "Repositório: adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd frontend

# 1. Atualizar package.json com todas as dependências
echo "📦 Atualizando package.json..."

cat > package.json << 'PKGJSON'
{
  "name": "sentinela-frontend",
  "version": "1.0.0",
  "description": "Frontend React para Sentinela - adrisa007/sentinela (ID: 1112237272)",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.1",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.32",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.55.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5"
  }
}
PKGJSON

echo "✓ package.json atualizado"

# 2. Configurar vite.config.js
echo "⚡ Configurando vite.config.js..."

cat > vite.config.js << 'VITECONFIG'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@services': path.resolve(__dirname, './src/services'),
      '@contexts': path.resolve(__dirname, './src/contexts'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@assets': path.resolve(__dirname, './src/assets'),
    },
  },
  server: {
    port: 3000,
    open: true,
    proxy: {
      '/api': {
        target: 'https://web-production-8355.up.railway.app',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    chunkSizeWarningLimit: 1000,
  },
})
VITECONFIG

echo "✓ vite.config.js configurado"

# 3. Configurar tailwind.config.js
echo "🎨 Configurando tailwind.config.js..."

cat > tailwind.config.js << 'TAILWINDCONFIG'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f4ff',
          100: '#e0e7ff',
          200: '#c7d2fe',
          300: '#a5b4fc',
          400: '#818cf8',
          500: '#6366f1',
          600: '#4f46e5',
          700: '#4338ca',
          800: '#3730a3',
          900: '#312e81',
          950: '#1e1b4b',
        },
        secondary: {
          50: '#faf5ff',
          100: '#f3e8ff',
          200: '#e9d5ff',
          300: '#d8b4fe',
          400: '#c084fc',
          500: '#a855f7',
          600: '#9333ea',
          700: '#7e22ce',
          800: '#6b21a8',
          900: '#581c87',
          950: '#3b0764',
        },
        success: {
          50: '#f0fdf4',
          500: '#22c55e',
          600: '#16a34a',
        },
        warning: {
          50: '#fffbeb',
          500: '#f59e0b',
          600: '#d97706',
        },
        danger: {
          50: '#fef2f2',
          500: '#ef4444',
          600: '#dc2626',
        },
      },
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'Oxygen',
          'Ubuntu',
          'Cantarell',
          'Helvetica Neue',
          'sans-serif',
        ],
      },
      boxShadow: {
        'card': '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
        'card-hover': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      },
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
    },
  },
  plugins: [],
}
TAILWINDCONFIG

echo "✓ tailwind.config.js configurado"

# 4. Configurar postcss.config.js
echo "🔧 Configurando postcss.config.js..."

cat > postcss.config.js << 'POSTCSSCONFIG'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSSCONFIG

echo "✓ postcss.config.js configurado"

# 5. Atualizar index.html
echo "📄 Atualizando index.html..."

cat > index.html << 'INDEXHTML'
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/shield.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Sentinela - Sistema de Monitoramento e Segurança. Vigilância total, risco zero. Repositório: adrisa007/sentinela (ID: 1112237272)" />
    <meta name="keywords" content="sentinela, monitoramento, segurança, vigilância, react, fastapi, neon, railway" />
    <meta name="author" content="Adriano" />
    <meta name="theme-color" content="#4f46e5" />
    
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website" />
    <meta property="og:url" content="https://web-production-8355.up.railway.app" />
    <meta property="og:title" content="Sentinela - Vigilância Total, Risco Zero" />
    <meta property="og:description" content="Sistema de monitoramento e segurança com React, FastAPI e Neon Database" />
    
    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image" />
    <meta property="twitter:url" content="https://web-production-8355.up.railway.app" />
    <meta property="twitter:title" content="Sentinela - Vigilância Total, Risco Zero" />
    <meta property="twitter:description" content="Sistema de monitoramento e segurança com React, FastAPI e Neon Database" />
    
    <title>Sentinela - Vigilância Total, Risco Zero</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
INDEXHTML

echo "✓ index.html atualizado"

# 6. Atualizar src/main.jsx
echo "⚛️  Atualizando src/main.jsx..."

cat > src/main.jsx << 'MAINJSX'
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
MAINJSX

echo "✓ src/main.jsx atualizado"

# 7. Atualizar src/index.css com Tailwind
echo "🎨 Atualizando src/index.css..."

cat > src/index.css << 'INDEXCSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply border-border;
  }
  
  html {
    @apply scroll-smooth;
  }
  
  body {
    @apply bg-gradient-to-br from-gray-50 via-white to-gray-50 text-gray-900 antialiased;
    font-feature-settings: "rlig" 1, "calt" 1;
  }
  
  /* Remove outline padrão e adiciona custom */
  *:focus-visible {
    @apply outline-none ring-2 ring-primary-500 ring-offset-2;
  }
}

@layer components {
  /* Buttons */
  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .btn-primary {
    @apply btn bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500 shadow-sm hover:shadow-md;
  }
  
  .btn-secondary {
    @apply btn bg-secondary-600 text-white hover:bg-secondary-700 focus:ring-secondary-500 shadow-sm hover:shadow-md;
  }
  
  .btn-outline {
    @apply btn border-2 border-primary-600 text-primary-600 hover:bg-primary-50;
  }
  
  .btn-ghost {
    @apply btn text-gray-700 hover:bg-gray-100;
  }
  
  /* Cards */
  .card {
    @apply bg-white rounded-xl shadow-card hover:shadow-card-hover transition-all duration-200 overflow-hidden;
  }
  
  .card-body {
    @apply p-6;
  }
  
  .card-header {
    @apply px-6 py-4 border-b border-gray-200;
  }
  
  /* Status Badge */
  .badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
  }
  
  .badge-success {
    @apply badge bg-success-50 text-success-600;
  }
  
  .badge-warning {
    @apply badge bg-warning-50 text-warning-600;
  }
  
  .badge-danger {
    @apply badge bg-danger-50 text-danger-600;
  }
  
  /* Loading Spinner */
  .spinner {
    @apply animate-spin rounded-full border-b-2 border-current;
  }
  
  /* Container */
  .container {
    @apply max-w-7xl mx-auto px-4 sm:px-6 lg:px-8;
  }
  
  /* Gradient Text */
  .gradient-text {
    @apply bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent;
  }
}

@layer utilities {
  /* Custom scrollbar */
  .scrollbar-thin::-webkit-scrollbar {
    width: 6px;
  }
  
  .scrollbar-thin::-webkit-scrollbar-track {
    @apply bg-gray-100;
  }
  
  .scrollbar-thin::-webkit-scrollbar-thumb {
    @apply bg-gray-400 rounded-full;
  }
  
  .scrollbar-thin::-webkit-scrollbar-thumb:hover {
    @apply bg-gray-500;
  }
  
  /* Animations */
  @keyframes slideInFromTop {
    from {
      transform: translateY(-100%);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
  
  .animate-slide-in {
    animation: slideInFromTop 0.3s ease-out;
  }
}

/* Loading state */
.loading {
  @apply pointer-events-none opacity-50;
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
}
INDEXCSS

echo "✓ src/index.css atualizado"

# 8. Atualizar src/services/api.js com configuração completa
echo "🔌 Atualizando src/services/api.js..."

cat > src/services/api.js << 'APISERVICE'
import axios from 'axios'

/**
 * API Client para Sentinela Backend
 * Repository: adrisa007/sentinela (ID: 1112237272)
 * Backend: https://web-production-8355.up.railway.app
 */

// Base URL - usa proxy do Vite em dev, URL completa em produção
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://web-production-8355.up.railway.app'

console.log('API Base URL:', API_BASE_URL)

// Criar instância do axios
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
})

// Request interceptor - log e adicionar headers
api.interceptors.request.use(
  (config) => {
    console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`)
    
    // Adicionar token se existir
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    return config
  },
  (error) => {
    console.error('[API] Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor - tratamento de erros
api.interceptors.response.use(
  (response) => {
    console.log(`[API] ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('[API] Response Error:', error.response?.status, error.message)
    
    // Tratamento específico de erros
    if (error.response?.status === 401) {
      console</body>