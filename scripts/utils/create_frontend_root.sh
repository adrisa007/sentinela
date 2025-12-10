#!/bin/bash
# create_frontend_root.sh
# Cria pasta frontend na raiz para adrisa007/sentinela (ID: 1112237272)

echo "🎨 Criando Frontend na Raiz - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

# Voltar para raiz do repositório
cd /workspaces/sentinela

# 1. Criar estrutura frontend
echo "📁 Criando estrutura de pastas..."

mkdir -p frontend/{src/{components,pages,services,contexts,utils,assets},public}

echo "✓ Estrutura criada"
echo ""

# 2. Criar package.json
echo "📦 Criando package.json..."

cat > frontend/package.json << 'PKGJSON'
{
  "name": "sentinela-frontend",
  "version": "1.0.0",
  "description": "Frontend React para adrisa007/sentinela (ID: 1112237272)",
  "type": "module",
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0 --port $PORT",
    "lint": "eslint . --ext js,jsx"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.1",
    "react-hook-form": "^7.49.2",
    "axios": "^1.6.2",
    "chart.js": "^4.4.0",
    "react-chartjs-2": "^5.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.32",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.55.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0"
  }
}
PKGJSON

echo "✓ package.json criado"

# 3. Configurar Vite
cat > frontend/vite.config.js << 'VITECONFIG'
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
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'https://web-production-8355.up.railway.app',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})
VITECONFIG

echo "✓ vite.config.js criado"

# 4. Configurar Tailwind
cat > frontend/tailwind.config.js << 'TAILWIND'
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          500: '#6366f1',
          600: '#4f46e5',
          700: '#4338ca',
        },
        secondary: {
          500: '#a855f7',
          600: '#9333ea',
          700: '#7e22ce',
        },
      },
    },
  },
  plugins: [],
}
TAILWIND

cat > frontend/postcss.config.js << 'POSTCSS'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSS

echo "✓ Tailwind configurado"

# 5. Criar index.html
cat > frontend/index.html << 'HTML'
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sentinela - adrisa007/sentinela (ID: 1112237272)</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
HTML

echo "✓ index.html criado"

# 6. Criar arquivos React básicos
cat > frontend/src/main.jsx << 'MAIN'
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

cat > frontend/src/App.jsx << 'APP'
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
APP

cat > frontend/src/index.css << 'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  @apply bg-gray-50;
}
CSS

echo "✓ Arquivos React criados"

# 7. Criar .gitignore
cat > frontend/.gitignore << 'IGNORE'
node_modules
dist
.env
.env.local
*.log
.vite
IGNORE

echo "✓ .gitignore criado"

# 8. Criar .env
cat > frontend/.env << 'ENV'
VITE_API_URL=https://web-production-8355.up.railway.app
ENV

cat > frontend/.env.example << 'ENVEX'
VITE_API_URL=https://web-production-8355.up.railway.app
# Para desenvolvimento local:
# VITE_API_URL=http://localhost:8000
ENVEX

echo "✓ .env criado"

# 9. Criar README do frontend
cat > frontend/README.md << 'README'
# Frontend - adrisa007/sentinela (ID: 1112237272)

## 🚀 Quick Start

```bash
cd frontend
npm install
npm run dev