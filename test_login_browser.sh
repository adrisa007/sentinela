#!/bin/bash
# test_login_browser.sh
# Guia para testar Login no browser
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🌐 Testando Login no Browser - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Verificar se dependências estão instaladas
echo "📦 Verificando dependências..."
if [ ! -d "node_modules" ]; then
    echo "Instalando dependências..."
    npm install
else
    echo "✓ Dependências já instaladas"
fi
echo ""

# 2. Verificar variáveis de ambiente
echo "🔐 Verificando .env..."
if [ ! -f ".env" ]; then
    echo "Criando .env..."
    cat > .env << 'ENV'
VITE_API_URL=https://web-production-8355.up.railway.app
ENV
    echo "✓ .env criado"
else
    echo "✓ .env existe"
    cat .env
fi
echo ""

# 3. Criar script de teste
cat > test_login.md << 'TESTGUIDE'
# 🧪 Guia de Teste - Login Page

## 🚀 Iniciar Servidor

```bash
cd frontend
npm run dev