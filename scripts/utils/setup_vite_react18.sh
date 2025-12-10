#!/bin/bash
# setup_vite_react18.sh
# Configura frontend completo com Vite + React 18
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "⚛️  Configurando Vite + React 18 - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Criar package.json completo
echo "📦 Criando package.json com React 18..."

cat > package.json << 'PKGJSON'
{
  "name": "sentinela-frontend",
  "private": true,
  "version": "1.0.0",
  "description": "Frontend React 18 para adrisa007/sentinela (ID: 1112237272)",
  "type": "module",
  "author": "Adriano",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/adrisa007/sentinela.git"
  },
  "keywords": [
    "react",
    "vite",
    "tailwind",
    "sentinela",
    "monitoring",
    "security"
  ],
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0 --port ${PORT:-4173}",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0",
    "format": "prettier --write \"src/**/*.{js,jsx,css,md}\""
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.3",
    "react-hook-form": "^7.50.0",
    "axios": "^1.6.7",
    "chart.js": "^4.4.1",
    "react-chartjs-2": "^5.2.0",
    "date-fns": "^3.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.2.55",
    "@types/react-dom": "^18.2.19",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.1.0",
    "tailwindcss": "^3.4.1",
    "postcss": "^8.4.35",
    "autoprefixer": "^10.4.17",
    "eslint": "^8.56.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "prettier": "^3.2.5"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
PKGJSON

echo "✓ package.json criado"
echo ""

# 2. Criar/Atualizar vite.config.js
echo "⚡ Criando vite.config.js otimizado..."

cat > vite.config.js << 'VITECONFIG'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

/**
 * Vite Configuration - adrisa007/sentinela (ID: 1112237272)
 * https://vitejs.dev/config/
 */
export default defineConfig({
  plugins: [
    react({
      // React 18 automatic JSX runtime
      jsxRuntime: 'automatic',
      // Fast Refresh
      fastRefresh: true,
      // Babel config
      babel: {
        plugins: [
          // Remover PropTypes em produção
          process.env.NODE_ENV === 'production' && [
            'transform-react-remove-prop-types',
            { removeImport: true }
          ]
        ].filter(Boolean),
      },
    }),
  ],

  // Path aliases
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

  // Dev server
  server: {
    port: 3000,
    host: true,
    open: false,
    strictPort: false,
    cors: true,
    
    // Proxy para API backend
    proxy: {
      '/api': {
        target: process.env.VITE_API_URL || 'https://web-production-8355.up.railway.app',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ''),
        configure: (proxy, options) => {
          proxy.on('proxyReq', (proxyReq, req) => {
            console.log('[Proxy]', req.method, req.url)
          })
        },
      },
    },

    // HMR
    hmr: {
      overlay: true,
      timeout: 30000,
    },

    // Watch
    watch: {
      usePolling: process.env.VITE_USE_POLLING === 'true',
    },
  },

  // Build
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    minify: 'terser',
    
    terserOptions: {
      compress: {
        drop_console: process.env.NODE_ENV === 'production',
        drop_debugger: true,
      },
    },

    // Rollup options
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'chart-vendor': ['chart.js', 'react-chartjs-2'],
          'form-vendor': ['react-hook-form'],
        },
      },
    },

    chunkSizeWarningLimit: 1000,
    assetsInlineLimit: 4096,
  },

  // Optimize deps
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-router-dom',
      'axios',
      'react-hook-form',
      'chart.js',
      'react-chartjs-2',
    ],
  },

  // Preview
  preview: {
    port: 4173,
    host: true,
    strictPort: false,
  },

  // Base
  base: '/',

  // Env prefix
  envPrefix: 'VITE_',
})
VITECONFIG

echo "✓ vite.config.js criado"
echo ""

# 3. Criar .eslintrc.cjs
echo "🔍 Criando .eslintrc.cjs..."

cat > .eslintrc.cjs << 'ESLINTRC'
module.exports = {
  root: true,
  env: {
    browser: true,
    es2020: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:react/jsx-runtime',
    'plugin:react-hooks/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  settings: {
    react: {
      version: '18.2',
    },
  },
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true },
    ],
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',
    'no-unused-vars': 'warn',
  },
}
ESLINTRC

echo "✓ .eslintrc.cjs criado"
echo ""

# 4. Criar .prettierrc
echo "💅 Criando .prettierrc..."

cat > .prettierrc << 'PRETTIER'
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "useTabs": false,
  "trailingComma": "es5",
  "printWidth": 100,
  "arrowParens": "always",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "jsxSingleQuote": false,
  "jsxBracketSameLine": false
}
PRETTIER

echo "✓ .prettierrc criado"
echo ""

# 5. Criar index.html otimizado
echo "📄 Criando index.html..."

cat > index.html << 'INDEXHTML'
<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/shield.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- Primary Meta Tags -->
    <title>Sentinela - Vigilância Total, Risco Zero</title>
    <meta name="title" content="Sentinela - Sistema de Monitoramento e Segurança" />
    <meta name="description" content="Sistema completo de monitoramento e segurança construído com React 18, FastAPI e Neon Database. Repository: adrisa007/sentinela (ID: 1112237272)" />
    <meta name="keywords" content="sentinela, monitoramento, segurança, vigilância, react, fastapi, neon" />
    <meta name="author" content="Adriano" />
    <meta name="theme-color" content="#4f46e5" />
    
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website" />
    <meta property="og:url" content="https://web-production-8355.up.railway.app/" />
    <meta property="og:title" content="Sentinela - Vigilância Total, Risco Zero" />
    <meta property="og:description" content="Sistema de monitoramento e segurança com React 18 e FastAPI" />
    
    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image" />
    <meta property="twitter:url" content="https://web-production-8355.up.railway.app/" />
    <meta property="twitter:title" content="Sentinela - Vigilância Total, Risco Zero" />
    <meta property="twitter:description" content="Sistema de monitoramento e segurança com React 18 e FastAPI" />
    
    <!-- Preconnect para performance -->
    <link rel="preconnect" href="https://web-production-8355.up.railway.app" />
    <link rel="dns-prefetch" href="https://web-production-8355.up.railway.app" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
INDEXHTML

echo "✓ index.html criado"
echo ""

# 6. Criar src/main.jsx com React 18
echo "⚛️  Criando src/main.jsx..."

cat > src/main.jsx << 'MAINJSX'
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
MAINJSX

echo "✓ src/main.jsx criado"
echo ""

# 7. Criar src/App.jsx básico
echo "📱 Criando src/App.jsx..."

cat > src/App.jsx << 'APPJSX'
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
APPJSX

echo "✓ src/App.jsx criado"
echo ""

# 8. Criar README.md do frontend
cat > README.md << 'README'
# Frontend - adrisa007/sentinela (ID: 1112237272)

Frontend React 18 com Vite para o sistema Sentinela.

## 🚀 Quick Start

```bash
# Instalar dependências
npm install

# Dev server
npm run dev

# Build produção
npm run build

# Preview build
npm run preview