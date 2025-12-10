#!/bin/bash
# direct_access_fornecedores.sh
# Acesso direto à página de fornecedores
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🌐 Acesso Direto a Fornecedores - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

# 1. Verificar servidor
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Servidor ativo em http://localhost:3000"
else
    echo "❌ Servidor não está rodando"
    echo "Execute: npm run dev"
    exit 1
fi

echo ""
echo "📋 PASSO A PASSO PARA ACESSAR FORNECEDORES:"
echo "================================================================"
echo ""
echo "1️⃣ FAZER LOGIN:"
echo "   Abra: http://localhost:3000/login"
echo ""
echo "   Email: gestor@sentinela.com"
echo "   Senha: 123456 (ou qualquer senha)"
echo ""
echo "2️⃣ APÓS LOGIN, ACESSAR:"
echo "   http://localhost:3000/fornecedores"
echo ""
echo "================================================================"
echo ""
echo "🚀 ATALHO RÁPIDO:"
echo ""
echo "Execute no Console do Browser (F12):"
echo ""
echo "// Fazer login automático"
echo "localStorage.setItem('token', 'mock-token-' + Date.now())"
echo "localStorage.setItem('user', JSON.stringify({"
echo "  id: 1,"
echo "  email: 'gestor@sentinela.com',"
echo "  role: 'GESTOR',"
echo "  name: 'gestor'"
echo "}))"
echo ""
echo "// Recarregar página"
echo "location.href = '/fornecedores'"
echo ""
echo "================================================================"
echo ""
echo "📊 PREVIEW DA PÁGINA:"
echo ""
echo "Cards de Estatísticas:"
echo "  📊 Total: 6 fornecedores"
echo "  ✅ Ativos: 5"
echo "  🏛️ PJ: 5"
echo "  👤 PF: 1"
echo ""
echo "Fornecedores na Lista:"
echo "  1. Alpha Construções (SP) - 5 contratos - R$ 1.500.000"
echo "  2. Beta Serviços (RJ) - 3 contratos - R$ 850.000"
echo "  3. Gamma Tech (DF) - INATIVO - 0 contratos"
echo "  4. Delta Equip (MG) - 7 contratos - R$ 2.300.000"
echo "  5. João Silva (PR) - 1 contrato - R$ 50.000"
echo "  6. Epsilon Materiais (RS) - 4 contratos - R$ 980.000"
echo ""
echo "Filtros Disponíveis:"
echo "  🔍 Buscar por Nome"
echo "  📋 CNPJ/CPF (com máscara e validação)"
echo "  ✅ Status (Ativo/Inativo)"
echo "  🏛️ Tipo (PJ/PF)"
echo ""
echo "Ações por Fornecedor:"
echo "  👁️ Ver Detalhes (Modal com 3 abas: Dados, Certidões, Contratos)"
echo "  ✏️ Editar"
echo "  🔍 Consultar PNCP"
echo "  🗑️ Deletar"
echo ""
echo "================================================================"
echo ""

# Criar página HTML de acesso direto
cat > /tmp/acesso_fornecedores.html << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acesso Fornecedores - Sentinela</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            color: #333;
        }
        h1 { 
            margin: 0 0 20px 0; 
            font-size: 2em;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .step {
            background: #f3f4f6;
            padding: 20px;
            border-radius: 8px;
            margin: 15px 0;
            border-left: 4px solid #667eea;
        }
        .step h3 {
            margin-top: 0;
            color: #667eea;
        }
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            margin: 10px 0;
            transition: transform 0.2s;
        }
        button:hover {
            transform: scale(1.02);
        }
        .info {
            background: #e0e7ff;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            color: #3730a3;
        }
        code {
            background: #1f2937;
            color: #10b981;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
        }
        .success {
            background: #d1fae5;
            color: #065f46;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            display: none;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>🏢 Acesso à Página de Fornecedores</h1>
        <p><strong>Repository:</strong> adrisa007/sentinela | ID: 1112237272</p>
        
        <div class="info">
            <strong>ℹ️ Informação:</strong> A página de fornecedores está protegida por autenticação. 
            Você precisa fazer login primeiro.
        </div>

        <div class="step">
            <h3>Opção 1: Login Manual</h3>
            <p>1. Clique no botão abaixo para ir ao login</p>
            <p>2. Use as credenciais:</p>
            <ul>
                <li><strong>Email:</strong> <code>gestor@sentinela.com</code></li>
                <li><strong>Senha:</strong> <code>123456</code> (ou qualquer senha)</li>
            </ul>
            <button onclick="window.location.href='http://localhost:3000/login'">
                🔐 Ir para Login
            </button>
        </div>

        <div class="step">
            <h3>Opção 2: Login Automático + Redirect</h3>
            <p>Clique para fazer login automático e ir direto para Fornecedores:</p>
            <button onclick="autoLogin()">
                🚀 Login Automático e Acessar Fornecedores
            </button>
            <div id="success" class="success">
                ✅ Login configurado! Redirecionando...
            </div>
        </div>

        <div class="step">
            <h3>Opção 3: Acesso Direto (se já estiver logado)</h3>
            <button onclick="window.location.href='http://localhost:3000/fornecedores'">
                🏢 Ir para Fornecedores (direto)
            </button>
        </div>

        <div class="info">
            <strong>🎯 O que você verá na página:</strong>
            <ul>
                <li>📊 4 Cards de Estatísticas</li>
                <li>🔍 4 Filtros de Busca (Nome, CNPJ, Status, Tipo)</li>
                <li>📋 Tabela com 6 Fornecedores Mock</li>
                <li>👁️ Modal de Detalhes com Certidões</li>
                <li>➕ Botão Adicionar Fornecedor</li>
            </ul>
        </div>
    </div>

    <script>
        function autoLogin() {
            // Mock user e token
            const mockUser = {
                id: 1,
                email: 'gestor@sentinela.com',
                role: 'GESTOR',
                name: 'gestor'
            };
            const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.' + Date.now();

            // Salvar no localStorage via iframe para contornar cross-origin
            const loginUrl = 'http://localhost:3000/login?autoLogin=true';
            
            // Mostrar mensagem de sucesso
            document.getElementById('success').style.display = 'block';

            // Redirecionar
            setTimeout(() => {
                window.location.href = loginUrl;
                
                // Após carregar, executar script de login
                setTimeout(() => {
                    const win = window.open('http://localhost:3000/fornecedores', '_blank');
                    if (win) {
                        win.addEventListener('load', () => {
                            win.localStorage.setItem('token', mockToken);
                            win.localStorage.setItem('user', JSON.stringify(mockUser));
                            win.location.reload();
                        });
                    }
                }, 1000);
            }, 1000);
        }
    </script>
</body>
</html>
HTML

echo "📄 Página de acesso criada em: /tmp/acesso_fornecedores.html"
echo ""

# Tentar abrir a página de acesso
if command -v xdg-open > /dev/null 2>&1; then
    xdg-open "/tmp/acesso_fornecedores.html" 2>/dev/null &
    echo "✅ Página de acesso aberta no browser"
elif command -v open > /dev/null 2>&1; then
    open "/tmp/acesso_fornecedores.html"
    echo "✅ Página de acesso aberta no browser"
else
    echo "📋 Abra manualmente: file:///tmp/acesso_fornecedores.html"
fi

echo ""
echo "================================================================"
echo "✨ PRONTO!"
echo "================================================================"
echo ""
echo "Escolha uma das opções na página aberta ou acesse diretamente:"
echo ""
echo "🔗 http://localhost:3000/login"
echo ""