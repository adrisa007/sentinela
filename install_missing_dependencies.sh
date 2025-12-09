#!/bin/bash
# install_missing_dependencies.sh
# Instala todas as dependências necessárias
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "📦 Instalando Dependências - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Instalar dependências faltantes
echo "📥 Instalando react-router-dom e outras dependências..."

npm install react-router-dom react-hook-form axios chart.js react-chartjs-2

echo "✓ Dependências principais instaladas"
echo ""

# 2. Instalar dev dependencies
echo "📥 Instalando dev dependencies..."

npm install -D @vitejs/plugin-react vite tailwindcss postcss autoprefixer

echo "✓ Dev dependencies instaladas"
echo ""

# 3. Verificar instalação
echo "🔍 Verificando instalações..."

npm list react-router-dom
npm list react-hook-form
npm list axios

echo ""
echo "================================================================"
echo "✅ DEPENDÊNCIAS INSTALADAS"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "✅ Instalado:"
echo "  • react-router-dom"
echo "  • react-hook-form"
echo "  • axios"
echo "  • chart.js"
echo "  • react-chartjs-2"
echo "  • vite"
echo "  • tailwindcss"
echo ""
echo "🚀 Reiniciar servidor:"
echo "  npm run dev"
echo ""

# Reiniciar servidor automaticamente
read -p "Reiniciar servidor agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    npm run dev
fi