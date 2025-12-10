#!/bin/bash
# fix_login_navigation.sh
# Corrige navegação para tela de login
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔧 Corrigindo Navegação Login - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Atualizar App.jsx com rotas
echo "📱 Atualizando App.jsx com React Router..."

cat > src/App.jsx << 'APP'
import { Routes, Route, Link } from 'react-router-dom'
import Login from './pages/Login'
import HomePage from './pages/HomePage'

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/login" element={<Login />} />
    </Routes>
  )
}

export default App
APP

echo "✓ App.jsx atualizado com rotas"

# 2. Criar HomePage
echo "🏠 Criando HomePage..."

mkdir -p src/pages

cat > src/pages/HomePage.jsx << 'HOMEPAGE'
import { Link } from 'react-router-dom'

function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="flex items-center justify-center min-h-screen px-4">
        <div className="text-center">
          <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-6 animate-pulse-slow">
            <span className="text-6xl">🛡️</span>
          </div>
          
          <h1 className="text-6xl font-bold mb-3">
            <span className="gradient-text">Sentinela</span>
          </h1>
          
          <p className="text-2xl text-gray-600 mb-2">
            Vigilância total, risco zero.
          </p>
          
          <p className="text-sm text-gray-500 mb-8">
            Sistema de Monitoramento e Segurança
          </p>
          
          <div className="space-y-2 text-sm text-gray-500 mb-8">
            <p>⚛️ React 18.2</p>
            <p>⚡ Vite 5.1</p>
            <p>🎨 Tailwind CSS 3.4</p>
            <p>🛣️ React Router 6</p>
          </div>
          
          <div className="space-y-4">
            <Link to="/login" className="btn-primary inline-block px-8 py-3 text-lg">
              🔐 Ir para Login
            </Link>
            
            <div className="flex justify-center space-x-4 text-sm">
              <a
                href="https://web-production-8355.up.railway.app/docs"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary-600 hover:text-primary-700"
              >
                📚 API Docs
              </a>
              <span className="text-gray-300">•</span>
              <a
                href="https://github.com/adrisa007/sentinela"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary-600 hover:text-primary-700"
              >
                🐙 GitHub
              </a>
            </div>
          </div>
          
          <div className="mt-12 text-xs text-gray-400">
            <p>adrisa007/sentinela | Repository ID: 1112237272</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default HomePage
HOMEPAGE

echo "✓ HomePage criada"

# 3. Criar página de Login simplificada
echo "🔐 Criando Login page..."

cat > src/pages/Login.jsx << 'LOGIN'
import { useState } from 'react'
import { Link } from 'react-router-dom'

function Login() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e) => {
    e.preventDefault()
    console.log('Login:', { email, password })
    alert('Login em desenvolvimento!')
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-secondary-50 px-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-24 h-24 bg-primary-100 rounded-full mb-4">
            <span className="text-6xl">🔐</span>
          </div>
          <h1 className="text-4xl font-bold mb-2">
            <span className="gradient-text">Login</span>
          </h1>
          <p className="text-gray-600">
            Sistema Sentinela - Acesso Seguro
          </p>
        </div>

        {/* Login Card */}
        <div className="card card-body">
          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div>
              <label htmlFor="email" className="form-label">
                Email ou Usuário <span className="text-danger-500">*</span>
              </label>
              <input
                id="email"
                type="text"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="form-input"
                placeholder="admin@sentinela.com"
                required
                autoFocus
              />
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="form-label">
                Senha <span className="text-danger-500">*</span>
              </label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="form-input"
                placeholder="••••••••"
                required
              />
            </div>

            {/* Remember Me */}
            <div className="flex items-center justify-between">
              <label className="flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  className="h-4 w-4 text-primary-600 rounded"
                />
                <span className="ml-2 text-sm text-gray-700">Lembrar-me</span>
              </label>
              
              <a href="#" className="text-sm text-primary-600 hover:text-primary-700">
                Esqueceu a senha?
              </a>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              className="w-full btn-primary py-3 text-base font-semibold"
            >
              🔓 Entrar
            </button>
          </form>

          {/* Footer Links */}
          <div className="mt-6 text-center space-y-2">
            <Link
              to="/"
              className="block text-sm text-gray-600 hover:text-primary-600"
            >
              ← Voltar para Home
            </Link>
          </div>
        </div>

        {/* Info Footer */}
        <div className="mt-6 text-center">
          <p className="text-xs text-gray-500">Sistema Sentinela</p>
          <p className="text-xs text-gray-400 mt-1">
            adrisa007/sentinela | Repository ID: 1112237272
          </p>
        </div>
      </div>
    </div>
  )
}

export default Login
LOGIN

echo "✓ Login page criada"

# 4. Atualizar index.css com animações
echo "🎨 Atualizando index.css..."

cat > src/index.css << 'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply antialiased;
  }
  
  body {
    @apply bg-gray-50;
  }
}

@layer components {
  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-all duration-200 
           focus:outline-none focus:ring-2 focus:ring-offset-2 
           disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .btn-primary {
    @apply btn bg-primary-600 text-white hover:bg-primary-700 
           focus:ring-primary-500 shadow-sm hover:shadow-md 
           transform hover:scale-105;
  }
  
  .card {
    @apply bg-white rounded-xl shadow-lg overflow-hidden;
  }
  
  .card-body {
    @apply p-6;
  }
  
  .form-input {
    @apply w-full px-4 py-2 border border-gray-300 rounded-lg 
           focus:ring-2 focus:ring-primary-500 focus:border-transparent 
           transition-all;
  }
  
  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }
  
  .gradient-text {
    @apply bg-gradient-to-r from-primary-600 to-secondary-600 
           bg-clip-text text-transparent;
  }
}

@layer utilities {
  .animate-pulse-slow {
    animation: pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }
}
CSS

echo "✓ index.css atualizado"

# 5. Verificar se react-router-dom está instalado
echo "📦 Verificando react-router-dom..."

if ! npm list react-router-dom &> /dev/null; then
    echo "Instalando react-router-dom..."
    npm install react-router-dom
fi

echo "✓ react-router-dom verificado"

echo ""
echo "================================================================"
echo "✅ NAVEGAÇÃO PARA LOGIN CORRIGIDA"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "✅ Arquivos criados/atualizados:"
echo "  ✓ src/App.jsx (rotas)"
echo "  ✓ src/pages/HomePage.jsx"
echo "  ✓ src/pages/Login.jsx"
echo "  ✓ src/index.css"
echo ""
echo "🛣️  Rotas disponíveis:"
echo "  • / → HomePage"
echo "  • /login → Login"
echo ""
echo "🔄 Reiniciando servidor..."
echo ""

# Matar processo do Vite se estiver rodando
pkill -f vite

# Aguardar 2 segundos
sleep 2

# Reiniciar servidor
npm run dev