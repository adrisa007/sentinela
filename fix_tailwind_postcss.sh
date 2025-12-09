#!/bin/bash
# fix_tailwind_postcss.sh
# Corrige erro PostCSS do Tailwind CSS
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🔧 Corrigindo Tailwind CSS PostCSS - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Remover instalação antiga
echo "🧹 Removendo instalação antiga..."
rm -rf node_modules
rm -f package-lock.json

# 2. Atualizar package.json
echo "📦 Atualizando package.json..."

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
    "@types/react": "^18.2.55",
    "@types/react-dom": "^18.2.19",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.1.0",
    "tailwindcss": "^3.4.1",
    "@tailwindcss/postcss": "^4.0.0-alpha.25",
    "postcss": "^8.4.35",
    "autoprefixer": "^10.4.17",
    "eslint": "^8.56.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0"
  }
}
PKG

echo "✓ package.json atualizado"

# 3. Atualizar postcss.config.js
echo "🔧 Atualizando postcss.config.js..."

cat > postcss.config.js << 'POSTCSS'
export default {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
}
POSTCSS

echo "✓ postcss.config.js atualizado"

# 4. Verificar tailwind.config.js
echo "🎨 Verificando tailwind.config.js..."

if [ ! -f "tailwind.config.js" ]; then
    cat > tailwind.config.js << 'TAILWIND'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eef2ff',
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
          100: '#dcfce7',
          500: '#22c55e',
          600: '#16a34a',
        },
        warning: {
          50: '#fffbeb',
          100: '#fef3c7',
          500: '#f59e0b',
          600: '#d97706',
        },
        danger: {
          50: '#fef2f2',
          100: '#fee2e2',
          500: '#ef4444',
          600: '#dc2626',
        },
        info: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
        },
      },
    },
  },
  plugins: [],
}
TAILWIND
fi

echo "✓ tailwind.config.js verificado"

# 5. Verificar src/index.css
echo "📝 Verificando src/index.css..."

if [ ! -f "src/index.css" ]; then
    mkdir -p src
    cat > src/index.css << 'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply antialiased;
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
           focus:ring-primary-500 shadow-sm hover:shadow-md;
  }

  .btn-secondary {
    @apply btn bg-secondary-600 text-white hover:bg-secondary-700 
           focus:ring-secondary-500 shadow-sm hover:shadow-md;
  }

  .btn-ghost {
    @apply btn text-gray-700 hover:bg-gray-100;
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
           transition;
  }

  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }

  .form-error {
    @apply text-sm text-danger-600;
  }

  .spinner {
    @apply animate-spin rounded-full border-b-2 border-current;
  }

  .gradient-text {
    @apply bg-gradient-to-r from-primary-600 to-secondary-600 
           bg-clip-text text-transparent;
  }

  .badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full 
           text-xs font-medium;
  }

  .badge-success {
    @apply badge bg-success-100 text-success-800;
  }

  .badge-danger {
    @apply badge bg-danger-100 text-danger-800;
  }
}
CSS
fi

echo "✓ src/index.css verificado"

# 6. Instalar dependências
echo "📥 Instalando dependências..."
npm install

echo ""
echo "================================================================"
echo "✅ TAILWIND CSS CORRIGIDO"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "🔧 Alterações realizadas:"
echo "  ✓ package.json atualizado"
echo "  ✓ @tailwindcss/postcss instalado"
echo "  ✓ postcss.config.js corrigido"
echo "  ✓ tailwind.config.js verificado"
echo "  ✓ src/index.css verificado"
echo "  ✓ node_modules reinstalado"
echo ""
echo "🚀 Iniciar servidor:"
echo "  npm run dev"
echo ""
echo "🌐 Acesse:"
echo "  http://localhost:3000/login"
echo ""

# Perguntar se quer iniciar
read -p "Iniciar servidor agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Iniciando servidor..."
    npm run dev
else
    echo ""
    echo "Para iniciar manualmente:"
    echo "  npm run dev"
fi