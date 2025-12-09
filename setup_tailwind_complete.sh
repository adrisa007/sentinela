#!/bin/bash
# setup_tailwind_complete.sh
# Adiciona e configura Tailwind CSS completo
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🎨 Adicionando Tailwind CSS - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Instalar Tailwind CSS e dependências
echo "📦 Instalando Tailwind CSS..."
npm install -D tailwindcss@latest postcss@latest autoprefixer@latest

echo "✓ Tailwind CSS instalado"
echo ""

# 2. Criar tailwind.config.js otimizado
echo "🎨 Criando tailwind.config.js..."

cat > tailwind.config.js << 'TAILWIND'
/** @type {import('tailwindcss').Config} */

/**
 * Tailwind CSS Configuration
 * Repository: adrisa007/sentinela (ID: 1112237272)
 * https://tailwindcss.com/docs/configuration
 */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],

  // Dark mode strategy
  darkMode: 'class', // 'media' or 'class'

  theme: {
    extend: {
      // Cores customizadas do Sentinela
      colors: {
        // Primary - Azul/Índigo
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

        // Secondary - Roxo/Violeta
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

        // Success - Verde
        success: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
        },

        // Warning - Amarelo/Laranja
        warning: {
          50: '#fffbeb',
          100: '#fef3c7',
          200: '#fde68a',
          300: '#fcd34d',
          400: '#fbbf24',
          500: '#f59e0b',
          600: '#d97706',
          700: '#b45309',
          800: '#92400e',
          900: '#78350f',
        },

        // Danger - Vermelho
        danger: {
          50: '#fef2f2',
          100: '#fee2e2',
          200: '#fecaca',
          300: '#fca5a5',
          400: '#f87171',
          500: '#ef4444',
          600: '#dc2626',
          700: '#b91c1c',
          800: '#991b1b',
          900: '#7f1d1d',
        },

        // Info - Azul claro
        info: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
      },

      // Font families
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'Oxygen',
          'Ubuntu',
          'Cantarell',
          'Fira Sans',
          'Droid Sans',
          'Helvetica Neue',
          'sans-serif',
        ],
        serif: [
          'Georgia',
          'Cambria',
          'Times New Roman',
          'Times',
          'serif',
        ],
        mono: [
          'ui-monospace',
          'SFMono-Regular',
          'SF Mono',
          'Monaco',
          'Menlo',
          'Consolas',
          'Liberation Mono',
          'Courier New',
          'monospace',
        ],
      },

      // Spacing customizado
      spacing: {
        '128': '32rem',
        '144': '36rem',
        '160': '40rem',
      },

      // Border radius customizado
      borderRadius: {
        '4xl': '2rem',
        '5xl': '2.5rem',
      },

      // Box shadow customizado
      boxShadow: {
        'card': '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
        'card-hover': '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
        'card-lg': '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
        'inner-lg': 'inset 0 2px 4px 0 rgb(0 0 0 / 0.05)',
        'glow': '0 0 20px rgb(99 102 241 / 0.5)',
      },

      // Animações customizadas
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'spin-fast': 'spin 0.5s linear infinite',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'bounce-slow': 'bounce 2s infinite',
        'wiggle': 'wiggle 1s ease-in-out infinite',
        'slide-in': 'slideIn 0.3s ease-out',
        'slide-out': 'slideOut 0.3s ease-in',
        'fade-in': 'fadeIn 0.3s ease-out',
        'fade-out': 'fadeOut 0.3s ease-in',
        'scale-in': 'scaleIn 0.2s ease-out',
        'scale-out': 'scaleOut 0.2s ease-in',
      },

      // Keyframes para animações
      keyframes: {
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
        slideIn: {
          '0%': { transform: 'translateY(-100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideOut: {
          '0%': { transform: 'translateY(0)', opacity: '1' },
          '100%': { transform: 'translateY(-100%)', opacity: '0' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeOut: {
          '0%': { opacity: '1' },
          '100%': { opacity: '0' },
        },
        scaleIn: {
          '0%': { transform: 'scale(0.9)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
        scaleOut: {
          '0%': { transform: 'scale(1)', opacity: '1' },
          '100%': { transform: 'scale(0.9)', opacity: '0' },
        },
      },

      // Z-index
      zIndex: {
        '60': '60',
        '70': '70',
        '80': '80',
        '90': '90',
        '100': '100',
      },

      // Max width
      maxWidth: {
        '8xl': '88rem',
        '9xl': '96rem',
      },

      // Backdrop blur
      backdropBlur: {
        xs: '2px',
      },

      // Gradient color stops
      gradientColorStops: {
        'primary-start': '#4f46e5',
        'primary-end': '#9333ea',
      },
    },
  },

  // Plugins
  plugins: [
    // Plugin para forms (opcional - descomente se quiser usar)
    // require('@tailwindcss/forms'),
    
    // Plugin para typography (opcional - descomente se quiser usar)
    // require('@tailwindcss/typography'),
    
    // Plugin para aspect ratio (opcional - descomente se quiser usar)
    // require('@tailwindcss/aspect-ratio'),
    
    // Plugin para line-clamp (opcional - descomente se quiser usar)
    // require('@tailwindcss/line-clamp'),
  ],

  // Variantes customizadas
  variants: {
    extend: {
      opacity: ['disabled'],
      cursor: ['disabled'],
      backgroundColor: ['active', 'disabled'],
      textColor: ['active', 'disabled'],
      borderColor: ['active', 'disabled'],
    },
  },

  // Safelist - classes que não devem ser removidas no purge
  safelist: [
    // Cores de status
    'bg-success-500',
    'bg-warning-500',
    'bg-danger-500',
    'bg-info-500',
    'text-success-500',
    'text-success-600',
    'text-warning-500',
    'text-warning-600',
    'text-danger-500',
    'text-danger-600',
    'text-info-500',
    'text-info-600',
    // Border colors
    'border-success-500',
    'border-warning-500',
    'border-danger-500',
    'border-info-500',
  ],
}
TAILWIND

echo "✓ tailwind.config.js criado"
echo ""

# 3. Criar postcss.config.js
echo "🔧 Criando postcss.config.js..."

cat > postcss.config.js << 'POSTCSS'
/**
 * PostCSS Configuration
 * Repository: adrisa007/sentinela (ID: 1112237272)
 */
export default {
  plugins: {
    // Tailwind CSS
    tailwindcss: {},
    
    // Autoprefixer para compatibilidade cross-browser
    autoprefixer: {},
    
    // Minificação CSS em produção (opcional)
    ...(process.env.NODE_ENV === 'production'
      ? {
          cssnano: {
            preset: ['default', {
              discardComments: {
                removeAll: true,
              },
            }],
          },
        }
      : {}),
  },
}
POSTCSS

echo "✓ postcss.config.js criado"
echo ""

# 4. Criar/Atualizar src/index.css com Tailwind
echo "🎨 Criando src/index.css com Tailwind..."

cat > src/index.css << 'INDEXCSS'
/**
 * Global Styles - adrisa007/sentinela (ID: 1112237272)
 * Tailwind CSS imports and custom styles
 */

/* Tailwind CSS directives */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom base styles */
@layer base {
  * {
    @apply antialiased;
  }

  html {
    @apply scroll-smooth;
  }

  body {
    @apply bg-gray-50 text-gray-900;
  }

  /* Focus styles */
  *:focus-visible {
    @apply outline-none ring-2 ring-primary-500 ring-offset-2;
  }

  /* Scrollbar styling */
  ::-webkit-scrollbar {
    @apply w-2 h-2;
  }

  ::-webkit-scrollbar-track {
    @apply bg-gray-100;
  }

  ::-webkit-scrollbar-thumb {
    @apply bg-gray-400 rounded-full;
  }

  ::-webkit-scrollbar-thumb:hover {
    @apply bg-gray-500;
  }
}

/* Custom components */
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

  .btn-success {
    @apply btn bg-success-600 text-white hover:bg-success-700 
           focus:ring-success-500;
  }

  .btn-danger {
    @apply btn bg-danger-600 text-white hover:bg-danger-700 
           focus:ring-danger-500;
  }

  .btn-outline {
    @apply btn border-2 border-primary-600 text-primary-600 
           hover:bg-primary-50;
  }

  .btn-ghost {
    @apply btn text-gray-700 hover:bg-gray-100;
  }

  /* Cards */
  .card {
    @apply bg-white rounded-xl shadow-card hover:shadow-card-hover 
           transition-all duration-200 overflow-hidden;
  }

  .card-body {
    @apply p-6;
  }

  .card-header {
    @apply px-6 py-4 border-b border-gray-200 bg-gray-50;
  }

  .card-footer {
    @apply px-6 py-4 border-t border-gray-200 bg-gray-50;
  }

  /* Badges */
  .badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full 
           text-xs font-medium;
  }

  .badge-success {
    @apply badge bg-success-100 text-success-800;
  }

  .badge-warning {
    @apply badge bg-warning-100 text-warning-800;
  }

  .badge-danger {
    @apply badge bg-danger-100 text-danger-800;
  }

  .badge-info {
    @apply badge bg-info-100 text-info-800;
  }

  /* Loading spinner */
  .spinner {
    @apply animate-spin rounded-full border-b-2 border-current;
  }

  /* Container */
  .container {
    @apply max-w-7xl mx-auto px-4 sm:px-6 lg:px-8;
  }

  /* Gradient text */
  .gradient-text {
    @apply bg-gradient-to-r from-primary-600 to-secondary-600 
           bg-clip-text text-transparent;
  }

  /* Form elements */
  .form-input {
    @apply w-full px-4 py-2 border border-gray-300 rounded-lg 
           focus:ring-2 focus:ring-primary-500 focus:border-transparent 
           transition;
  }

  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }

  .form-error {
    @apply mt-1 text-sm text-danger-600;
  }
}

/* Custom utilities */
@layer utilities {
  /* Scrollbar utilities */
  .scrollbar-thin {
    scrollbar-width: thin;
  }

  .scrollbar-none {
    scrollbar-width: none;
  }

  .scrollbar-none::-webkit-scrollbar {
    display: none;
  }

  /* Text utilities */
  .text-balance {
    text-wrap: balance;
  }

  /* Animation delays */
  .animation-delay-150 {
    animation-delay: 150ms;
  }

  .animation-delay-300 {
    animation-delay: 300ms;
  }

  .animation-delay-500 {
    animation-delay: 500ms;
  }
}

/* Dark mode styles (opcional) */
@media (prefers-color-scheme: dark) {
  /* Adicione estilos dark mode aqui se necessário */
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
}
INDEXCSS

echo "✓ src/index.css criado"
echo ""

# 5. Criar arquivo de exemplo de componentes Tailwind
echo "📝 Criando docs/TAILWIND_GUIDE.md..."

mkdir -p docs

cat > docs/TAILWIND_GUIDE.md << 'GUIDE'
# Tailwind CSS Guide - adrisa007/sentinela (ID: 1112237272)

## 🎨 Cores Disponíveis

### Primary (Azul/Índigo)
```jsx
<div className="bg-primary-500 text-white">Primary</div>
<button className="btn-primary">Botão Primary</button>