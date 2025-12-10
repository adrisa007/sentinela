#!/bin/bash
# open_fornecedores_browser.sh
# Configura e abre lista de fornecedores no browser
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🌐 Abrindo Fornecedores no Browser - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Atualizar App.jsx com rota de Fornecedores
cat > src/App.jsx << 'APP'
import { Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import HomePage from './pages/HomePage'
import Login from './pages/Login'
import DashboardGestor from './pages/DashboardGestor'
import Fornecedores from './pages/Fornecedores'
import ProtectedRoute from './components/ProtectedRoute'

/**
 * App Principal - adrisa007/sentinela (ID: 1112237272)
 */

function App() {
  return (
    <AuthProvider>
      <Routes>
        {/* Rotas Públicas */}
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<Login />} />

        {/* Rotas Protegidas */}
        <Route 
          path="/dashboard/gestor" 
          element={
            <ProtectedRoute>
              <DashboardGestor />
            </ProtectedRoute>
          } 
        />
        
        <Route 
          path="/fornecedores" 
          element={
            <ProtectedRoute>
              <Fornecedores />
            </ProtectedRoute>
          } 
        />
        
        {/* Redirect padrão */}
        <Route path="/dashboard" element={<Navigate to="/dashboard/gestor" replace />} />
        
        {/* 404 */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  )
}

export default App
APP

echo "✓ App.jsx atualizado com rota /fornecedores"

# 2. Criar HomePage simples se não existir
if [ ! -f "src/pages/HomePage.jsx" ]; then
  cat > src/pages/HomePage.jsx << 'HOME'
import { Link } from 'react-router-dom'

function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50 flex items-center justify-center">
      <div className="text-center">
        <div className="mb-8">
          <span className="text-8xl">🛡️</span>
        </div>
        <h1 className="text-5xl font-bold mb-4">
          <span className="gradient-text">Sentinela</span>
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Sistema de Gestão e Vigilância
        </p>
        <div className="space-x-4">
          <Link to="/login" className="btn-primary px-8 py-3">
            🔐 Login
          </Link>
          <Link to="/fornecedores" className="btn-ghost px-8 py-3">
            🏢 Fornecedores
          </Link>
        </div>
        <p className="text-xs text-gray-400 mt-8">
          Repository: adrisa007/sentinela | ID: 1112237272
        </p>
      </div>
    </div>
  )
}

export default HomePage
HOME
  echo "✓ HomePage.jsx criado"
fi

# 3. Verificar se servidor está rodando
SERVER_RUNNING=false
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "✓ Servidor já está rodando na porta 3000"
    SERVER_RUNNING=true
else
    echo "🚀 Iniciando servidor..."
    npm run dev > /tmp/vite.log 2>&1 &
    sleep 5
    SERVER_RUNNING=true
fi

# 4. Fazer login automático via localStorage
echo ""
echo "🔐 Configurando autenticação automática..."

# Criar script HTML temporário para fazer login
cat > /tmp/auto_login.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Auto Login - Sentinela</title>
</head>
<body>
    <h2>Configurando login...</h2>
    <p id="status">Aguarde...</p>
    <script>
        // Mock user e token
        const mockUser = {
            id: 1,
            email: 'gestor@sentinela.com',
            role: 'GESTOR',
            name: 'gestor'
        };
        const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.' + Date.now();

        // Salvar no localStorage
        localStorage.setItem('token', mockToken);
        localStorage.setItem('user', JSON.stringify(mockUser));

        document.getElementById('status').innerHTML = 
            '✅ Login configurado!<br>Redirecionando para Fornecedores...';

        // Redirecionar para fornecedores
        setTimeout(() => {
            window.location.href = 'http://localhost:3000/fornecedores';
        }, 1000);
    </script>
</body>
</html>
HTML

# 5. Criar script de teste em JavaScript
cat > /tmp/test_fornecedores.js << 'JS'
// Script de teste para Fornecedores
console.log('='.repeat(60))
console.log('📋 Testando Página de Fornecedores')
console.log('Repository: adrisa007/sentinela | ID: 1112237272')
console.log('='.repeat(60))

// Verificar localStorage
const token = localStorage.getItem('token')
const user = localStorage.getItem('user')

console.log('\n🔐 Autenticação:')
console.log('Token:', token ? '✅ Presente' : '❌ Ausente')
console.log('User:', user ? '✅ ' + JSON.parse(user).email : '❌ Ausente')

// Verificar URL
console.log('\n🌐 URL Atual:', window.location.href)
console.log('Rota esperada: /fornecedores')

// Verificar elementos da página
setTimeout(() => {
    const hasTable = document.querySelector('table') !== null
    const hasFilters = document.querySelector('input[placeholder*="Buscar"]') !== null
    const hasStats = document.querySelectorAll('.card').length > 0

    console.log('\n📊 Elementos da Página:')
    console.log('Tabela:', hasTable ? '✅' : '❌')
    console.log('Filtros:', hasFilters ? '✅' : '❌')
    console.log('Stats Cards:', hasStats ? '✅' : '❌')

    if (hasTable && hasFilters && hasStats) {
        console.log('\n✅ Página de Fornecedores carregada com sucesso!')
    } else {
        console.log('\n⚠️ Alguns elementos não foram encontrados')
    }
}, 2000)
JS

# 6. Abrir no browser
echo ""
echo "🌐 Abrindo no browser..."
echo ""

# Detectar sistema operacional e abrir browser
if command -v xdg-open > /dev/null; then
    # Linux
    xdg-open "file:///tmp/auto_login.html" 2>/dev/null
elif command -v open > /dev/null; then
    # macOS
    open "file:///tmp/auto_login.html"
else
    # Fallback: abrir diretamente
    echo "⚠️ Não foi possível detectar comando de abertura do browser"
    echo "📋 Abra manualmente:"
    echo "   1. http://localhost:3000/login"
    echo "   2. Email: gestor@sentinela.com"
    echo "   3. Senha: qualquer"
    echo "   4. Navegue para: http://localhost:3000/fornecedores"
fi

sleep 3

# 7. Informações de acesso
echo ""
echo "================================================================"
echo "✅ PÁGINA DE FORNECEDORES CONFIGURADA"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "🌐 URLs Disponíveis:"
echo "  • http://localhost:3000/                  → Home"
echo "  • http://localhost:3000/login             → Login"
echo "  • http://localhost:3000/fornecedores      → Fornecedores (protegido)"
echo "  • http://localhost:3000/dashboard/gestor  → Dashboard"
echo ""
echo "🔐 Credenciais de Teste:"
echo "  Email: gestor@sentinela.com"
echo "  Senha: qualquer senha"
echo ""
echo "📋 Página de Fornecedores Inclui:"
echo "  ✓ 6 fornecedores mock"
echo "  ✓ 4 cards de estatísticas"
echo "  ✓ 4 filtros (Nome, CNPJ, Status, Tipo)"
echo "  ✓ Tabela paginada (10/página)"
echo "  ✓ 4 ações por fornecedor (Ver, Editar, PNCP, Deletar)"
echo "  ✓ Modal de detalhes com certidões"
echo "  ✓ Modal de adicionar fornecedor"
echo ""
echo "🔍 Para Debug:"
echo "  Abra Console (F12) e cole:"
echo ""
cat /tmp/test_fornecedores.js
echo ""
echo "================================================================"
echo ""

# 8. Verificar se servidor está respondendo
echo "⏳ Aguardando servidor..."
sleep 2

if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Servidor respondendo!"
    echo ""
    echo "🎉 Pronto! A página deve ter aberto automaticamente."
    echo ""
    echo "📱 Se não abriu, acesse manualmente:"
    echo "   http://localhost:3000/fornecedores"
    echo ""
else
    echo "⚠️ Servidor não está respondendo"
    echo ""
    echo "Execute manualmente:"
    echo "  cd /workspaces/sentinela/frontend"
    echo "  npm run dev"
    echo ""
    echo "Depois acesse: http://localhost:3000/fornecedores"
fi

# 9. Mostrar logs do servidor
if [ -f /tmp/vite.log ]; then
    echo "📋 Últimas linhas do log do servidor:"
    tail -n 10 /tmp/vite.log
fi

echo ""
echo "✨ Configuração concluída!"
echo ""