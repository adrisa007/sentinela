#!/bin/bash
# update_repository.sh
# Atualiza repositório GitHub com todas as alterações
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔄 Atualizando Repositório GitHub - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela

# 1. Verificar status do Git
echo "📊 Status atual do repositório:"
git status
echo ""

# 2. Verificar branch atual
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Branch atual: $CURRENT_BRANCH"
echo ""

# 3. Adicionar todos os arquivos
echo "📦 Adicionando arquivos ao stage..."
git add .

# Ver o que será commitado
echo ""
echo "📋 Arquivos que serão commitados:"
git status --short
echo ""

# 4. Criar commit detalhado
echo "💾 Criando commit..."

COMMIT_MESSAGE="feat: adiciona frontend React completo com Login e navegação

Frontend completo para adrisa007/sentinela (ID: 1112237272):

🎨 Frontend React 18:
  ✅ Estrutura completa com Vite
  ✅ Tailwind CSS configurado
  ✅ React Router configurado
  ✅ HomePage criada
  ✅ Login page criada
  ✅ Navegação funcionando

📁 Estrutura:
  frontend/
  ├── src/
  │   ├── pages/
  │   │   ├── HomePage.jsx
  │   │   └── Login.jsx
  │   ├── App.jsx (com rotas)
  │   ├── main.jsx
  │   └── index.css
  ├── package.json
  ├── vite.config.js
  ├── tailwind.config.js
  └── postcss.config.js

🛣️  Rotas implementadas:
  • / → HomePage
  • /login → Login page

🔧 Configurações:
  ✅ Vite 5.1 com React plugin
  ✅ Tailwind CSS 3.4
  ✅ React Router 6
  ✅ Path aliases configurados
  ✅ Proxy API configurado

🎯 Features HomePage:
  • Hero section com ícone
  • Título gradiente
  • Botão navegação para Login
  • Links para API Docs e GitHub
  • Informações do repositório

🔐 Features Login:
  • Form completo (email/senha)
  • Design responsivo
  • Validação HTML5
  • Link voltar para Home
  • Card design com shadow

📦 Dependências instaladas:
  • react ^18.2.0
  • react-dom ^18.2.0
  • react-router-dom ^6.21.3
  • vite ^5.1.0
  • tailwindcss ^3.4.1

🚀 Para executar:
  cd frontend
  npm install
  npm run dev
  
🌐 Acesso:
  http://localhost:3000

Repositório: adrisa007/sentinela
Repository ID: 1112237272"

git commit -m "$COMMIT_MESSAGE"

echo "✓ Commit criado"
echo ""

# 5. Verificar remote
echo "🔗 Verificando remote..."
git remote -v
echo ""

# 6. Push para GitHub
echo "⬆️  Fazendo push para GitHub..."
echo ""

# Verificar se há upstream configurado
if git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
    echo "Upstream já configurado, fazendo push..."
    git push
else
    echo "Configurando upstream e fazendo push..."
    git push -u origin $CURRENT_BRANCH
fi

echo ""

# 7. Verificar se push foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "================================================================"
    echo "✅ REPOSITÓRIO ATUALIZADO COM SUCESSO"
    echo "================================================================"
    echo ""
    echo "📦 Repositório: adrisa007/sentinela"
    echo "🆔 Repository ID: 1112237272"
    echo "🌐 GitHub URL: https://github.com/adrisa007/sentinela"
    echo ""
    echo "📊 Status final:"
    git log --oneline -1
    echo ""
    echo "✨ Alterações enviadas para GitHub!"
else
    echo ""
    echo "❌ ERRO AO FAZER PUSH"
    echo ""
    echo "Possíveis soluções:"
    echo "1. Verificar autenticação GitHub"
    echo "2. Executar: git push origin $CURRENT_BRANCH"
    echo "3. Verificar permissões do repositório"
    echo ""
fi