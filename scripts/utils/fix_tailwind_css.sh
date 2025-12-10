#!/bin/bash
# fix_tailwind_css.sh
# Corrige index.css para adrisa007/sentinela (ID: 1112237272)

echo "🎨 Corrigindo Tailwind CSS - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd frontend

# Corrigir src/index.css
cat > src/index.css << 'INDEXCSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    @apply scroll-smooth;
  }
  
  body {
    @apply bg-gradient-to-br from-gray-50 via-white to-gray-50 text-gray-900 antialiased;
  }
  
  *:focus-visible {
    @apply outline-none ring-2 ring-primary-500 ring-offset-2;
  }
}

@layer components {
  /* Buttons */
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
  
  .btn-outline {
    @apply btn border-2 border-primary-600 text-primary-600 hover:bg-primary-50;
  }
  
  .btn-ghost {
    @apply btn text-gray-700 hover:bg-gray-100;
  }
  
  /* Cards */
  .card {
    @apply bg-white rounded-xl shadow-md hover:shadow-lg 
           transition-all duration-200 overflow-hidden;
  }
  
  .card-body {
    @apply p-6;
  }
  
  .card-header {
    @apply px-6 py-4 border-b border-gray-200;
  }
  
  /* Status Badge */
  .badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full 
           text-xs font-medium;
  }
  
  .badge-success {
    @apply badge bg-green-50 text-green-600;
  }
  
  .badge-warning {
    @apply badge bg-yellow-50 text-yellow-600;
  }
  
  .badge-danger {
    @apply badge bg-red-50 text-red-600;
  }
  
  /* Loading Spinner */
  .spinner {
    @apply animate-spin rounded-full border-b-2 border-current;
  }
  
  /* Container */
  .container {
    @apply max-w-7xl mx-auto px-4 sm:px-6 lg:px-8;
  }
  
  /* Gradient Text */
  .gradient-text {
    @apply bg-gradient-to-r from-primary-600 to-secondary-600 
           bg-clip-text text-transparent;
  }
}

@layer utilities {
  /* Custom scrollbar */
  .scrollbar-thin::-webkit-scrollbar {
    width: 6px;
  }
  
  .scrollbar-thin::-webkit-scrollbar-track {
    @apply bg-gray-100;
  }
  
  .scrollbar-thin::-webkit-scrollbar-thumb {
    @apply bg-gray-400 rounded-full;
  }
  
  .scrollbar-thin::-webkit-scrollbar-thumb:hover {
    @apply bg-gray-500;
  }
}
INDEXCSS

echo "✓ src/index.css corrigido"

# Atualizar tailwind.config.js para garantir cores corretas
cat > tailwind.config.js << 'TAILWINDCONFIG'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f4ff',
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
      },
    },
  },
  plugins: [],
}
TAILWINDCONFIG

echo "✓ tailwind.config.js atualizado"

echo ""
echo "================================================================"
echo "✅ TAILWIND CSS CORRIGIDO"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "🎨 Correções aplicadas:"
echo "  ✓ Removida classe inexistente 'border-border'"
echo "  ✓ Simplificado @layer base"
echo "  ✓ Mantidas todas as utility classes"
echo "  ✓ Cores primary e secondary configuradas"
echo ""
echo "🚀 Iniciando dev server..."
echo ""

# Limpar cache do Vite
rm -rf node_modules/.vite

# Reiniciar servidor
npm run dev