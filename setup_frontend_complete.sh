#!/bin/bash
# setup_frontend_complete.sh
# Setup completo do frontend do zero
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🚀 Setup Completo Frontend - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

# Voltar para raiz do repositório
cd /workspaces/sentinela

# Verificar se pasta frontend existe
if [ ! -d "frontend" ]; then
    echo "📁 Pasta frontend não encontrada. Criando..."
    mkdir -p frontend
fi

cd frontend

# 1. Criar package.json
echo "📦 Criando package.json..."

cat > package.json << 'PKG'
{
  "name": "sentinela-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0 --port ${PORT:-4173}",
    "lint": "eslint ."
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.3",
    "react-hook-form": "^7.50.0",
    "axios": "^1.6.7",
    "chart.js": "^4.4.1",
    "react-chartjs-2": "^5.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.1.0",
    "tailwindcss": "^3.4.1",
    "postcss": "^8.4.35",
    "autoprefixer": "^10.4.17",
    "eslint": "^8.56.0"
  }
}
PKG

# 2. Criar vite.config.js
echo "⚡ Criando vite.config.js..."

cat > vite.config.js << 'VITE'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

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
    host: true,
    proxy: {
      '/api': {
        target: 'http://0.0.0.0:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})
VITE

# 3. Criar postcss.config.js
echo "🔧 Criando postcss.config.js..."

cat > postcss.config.js << 'POSTCSS'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSS

# 4. Criar tailwind.config.js
echo "🎨 Criando tailwind.config.js..."

cat > tailwind.config.js << 'TAILWIND'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eef2ff',
          500: '#6366f1',
          600: '#4f46e5',
          700: '#4338ca',
        },
        secondary: {
          50: '#faf5ff',
          500: '#a855f7',
          600: '#9333ea',
        },
        success: {
          50: '#f0fdf4',
          500: '#22c55e',
          600: '#16a34a',
        },
        danger: {
          50: '#fef2f2',
          500: '#ef4444',
          600: '#dc2626',
        },
      },
    },
  },
  plugins: [],
}
TAILWIND

# 5. Criar index.html
echo "📄 Criando index.html..."

cat > index.html << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sentinela - Login</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
HTML

# 6. Criar estrutura src/
echo "📁 Criando estrutura src/..."

mkdir -p src/{components,pages,services,contexts,utils,assets}

# 7. Criar src/index.css
cat > src/index.css << 'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-all;
  }
  
  .btn-primary {
    @apply btn bg-primary-600 text-white hover:bg-primary-700;
  }
  
  .card {
    @apply bg-white rounded-xl shadow-lg;
  }
  
  .card-body {
    @apply p-6;
  }
  
  .form-input {
    @apply w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500;
  }
  
  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }
  
  .form-error {
    @apply text-sm text-danger-600 mt-1;
  }
  
  .spinner {
    @apply animate-spin rounded-full border-b-2 border-current;
  }
  
  .gradient-text {
    @apply bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent;
  }
}
CSS

# 8. Criar src/main.jsx
cat > src/main.jsx << 'MAIN'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
MAIN

# 9. Criar src/App.jsx
cat > src/App.jsx << 'APP'
function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="text-6xl mb-4">🛡️</div>
          <h1 className="text-4xl font-bold gradient-text mb-4">
            Sentinela
          </h1>
          <p className="text-gray-600 mb-8">
            Frontend configurado com sucesso!
          </p>
          <div className="space-y-2 text-sm text-gray-500">
            <p>⚛️ React 18.2</p>
            <p>⚡ Vite 5.1</p>
            <p>🎨 Tailwind CSS 3.4</p>
          </div>
          <div className="mt-8">
            <a
              href="/login"
              className="btn-primary"
            >
              Ir para Login
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
APP

# 10. Criar .env
echo "🔐 Criando .env..."

cat > .env << 'ENV'
VITE_API_URL=http://0.0.0.0:8080
ENV

# 11. Criar .gitignore
cat > .gitignore << 'IGNORE'
# Dependencies
node_modules

# Build
dist
*.local

# Environment
.env
.env.local

# Logs
*.log
npm-debug.log*

# Editor
.vscode
.idea

# OS
.DS_Store
IGNORE

# 12. Instalar dependências
echo ""
echo "📥 Instalando dependências..."
npm install

echo ""
echo "================================================================"
echo "✅ FRONTEND CONFIGURADO COM SUCESSO"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo "📂 Localização: /workspaces/sentinela/frontend"
echo ""
echo "📁 Estrutura criada:"
echo "  ✓ package.json"
echo "  ✓ vite.config.js"
echo "  ✓ tailwind.config.js"
echo "  ✓ postcss.config.js"
echo "  ✓ index.html"
echo "  ✓ src/main.jsx"
echo "  ✓ src/App.jsx"
echo "  ✓ src/index.css"
echo "  ✓ .env"
echo ""
echo "🚀 Iniciar servidor:"
echo "  npm run dev"
echo ""
echo "🌐 Acessar:"
echo "  http://localhost:3000"
echo ""

read -p "Iniciar servidor agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    npm run dev
else
    echo "Para iniciar: cd /workspaces/sentinela/frontend && npm run dev"
fi