#!/bin/bash
# create_vite_tailwind_configs.sh
# Cria vite.config.js e tailwind.config.js completos
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "⚙️  Criando Configurações Vite + Tailwind - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela/frontend

# 1. Criar vite.config.js
echo "⚡ Criando vite.config.js..."

cat > vite.config.js << 'VITECONFIG'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

/**
 * Vite Configuration para adrisa007/sentinela (ID: 1112237272)
 * https://vitejs.dev/config/
 */
export default defineConfig({
  plugins: [
    react({
      // Fast Refresh
      fastRefresh: true,
      // Babel plugins para otimização
      babel: {
        plugins: [
          // Remover PropTypes em produção
          ['transform-react-remove-prop-types', { removeImport: true }],
        ],
      },
    }),
  ],

  // Path aliases para imports mais limpos
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

  // Configuração do servidor de desenvolvimento
  server: {
    port: 3000,
    host: true, // Permite acesso via rede
    open: true, // Abre navegador automaticamente
    strictPort: false, // Tenta outra porta se 3000 estiver ocupada
    
    // Proxy para API backend
    proxy: {
      '/api': {
        target: 'https://web-production-8355.up.railway.app',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ''),
        // Log de requisições proxy
        configure: (proxy, options) => {
          proxy.on('proxyReq', (proxyReq, req, res) => {
            console.log('[Proxy]', req.method, req.url, '→', options.target + req.url)
          })
        },
      },
    },

    // CORS headers
    cors: true,

    // HMR (Hot Module Replacement)
    hmr: {
      overlay: true,
    },

    // Watch options
    watch: {
      usePolling: true, // Necessário em alguns containers/WSL
    },
  },

  // Configuração de build para produção
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true, // Gerar sourcemaps para debug
    minify: 'terser', // Minificação com terser
    
    // Opções do terser
    terserOptions: {
      compress: {
        drop_console: true, // Remove console.log em produção
        drop_debugger: true,
      },
    },

    // Chunks estratégicos para melhor cache
    rollupOptions: {
      output: {
        manualChunks: {
          // Vendor chunks
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'chart-vendor': ['chart.js', 'react-chartjs-2'],
          'form-vendor': ['react-hook-form'],
        },
      },
    },

    // Tamanho máximo de chunk (500kb)
    chunkSizeWarningLimit: 500,

    // Assets inline (base64) até 4kb
    assetsInlineLimit: 4096,
  },

  // Otimizações de dependências
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

  // Variáveis de ambiente
  envPrefix: 'VITE_',

  // Preview (após build)
  preview: {
    port: 4173,
    host: true,
    strictPort: false,
  },

  // Base URL (para deploy)
  base: '/',

  // CSS
  css: {
    devSourcemap: true,
  },
})
VITECONFIG

echo "✓ vite.config.js criado"
echo ""

# 2. Criar tailwind.config.js
echo "🎨 Criando tailwind.config.js..."

cat > tailwind.config.js << 'TAILWINDCONFIG'
/** @type {import('tailwindcss').Config} */

/**
 * Tailwind CSS Configuration para adrisa007/sentinela (ID: 1112237272)
 * https://tailwindcss.com/docs/configuration
 */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],

  // Dark mode (classe ou media query)
  darkMode: 'class', // 'media' ou 'class'

  theme: {
    extend: {
      // Cores customizadas do projeto
      colors: {
        // Primary (Azul/Roxo)
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

        // Secondary (Roxo)
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

        // Success (Verde)
        success: {
          50: '#f0fdf4',
          100: '#dcfce7',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
        },

        // Warning (Amarelo)
        warning: {
          50: '#fffbeb',
          100: '#fef3c7',
          500: '#f59e0b',
          600: '#d97706',
          700: '#b45309',
        },

        // Danger (Vermelho)
        danger: {
          50: '#fef2f2',
          100: '#fee2e2',
          500: '#ef4444',
          600: '#dc2626',
          700: '#b91c1c',
        },

        // Info (Azul claro)
        info: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },

      // Fontes customizadas
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'Oxygen',
          'Ubuntu',
          'Cantarell',
          'Helvetica Neue',
          'sans-serif',
        ],
        mono: [
          'ui-monospace',
          'SFMono-Regular',
          'Monaco',
          'Consolas',
          'Liberation Mono',
          'Courier New',
          'monospace',
        ],
      },

      // Espaçamentos adicionais
      spacing: {
        '128': '32rem',
        '144': '36rem',
      },

      // Border radius
      borderRadius: {
        '4xl': '2rem',
      },

      // Box shadow customizado
      boxShadow: {
        'card': '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
        'card-hover': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        'inner-lg': 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)',
      },

      // Animações customizadas
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'bounce-slow': 'bounce 2s infinite',
        'slide-in': 'slideIn 0.3s ease-out',
        'slide-out': 'slideOut 0.3s ease-in',
        'fade-in': 'fadeIn 0.3s ease-out',
        'fade-out': 'fadeOut 0.3s ease-in',
      },

      // Keyframes para animações
      keyframes: {
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
      },

      // Z-index
      zIndex: {
        '60': '60',
        '70': '70',
        '80': '80',
        '90': '90',
        '100': '100',
      },

      // Tamanhos máximos
      maxWidth: {
        '8xl': '88rem',
        '9xl': '96rem',
      },

      // Backdrop blur
      backdropBlur: {
        xs: '2px',
      },
    },
  },

  // Plugins do Tailwind
  plugins: [
    // Plugin para forms (opcional)
    // require('@tailwindcss/forms'),
    
    // Plugin para typography (opcional)
    // require('@tailwindcss/typography'),
    
    // Plugin para aspect ratio (opcional)
    // require('@tailwindcss/aspect-ratio'),
  ],

  // Variantes customizadas
  variants: {
    extend: {
      opacity: ['disabled'],
      cursor: ['disabled'],
      backgroundColor: ['active', 'disabled'],
      textColor: ['active', 'disabled'],
    },
  },

  // Safelist (classes que não devem ser removidas no purge)
  safelist: [
    'bg-success-500',
    'bg-warning-500',
    'bg-danger-500',
    'bg-info-500',
    'text-success-500',
    'text-warning-500',
    'text-danger-500',
    'text-info-500',
  ],
}
TAILWINDCONFIG

echo "✓ tailwind.config.js criado"
echo ""

# 3. Criar postcss.config.js
echo "🔧 Criando postcss.config.js..."

cat > postcss.config.js << 'POSTCSS'
/**
 * PostCSS Configuration para adrisa007/sentinela (ID: 1112237272)
 */
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
    // Plugin para nested CSS (opcional)
    // 'postcss-nested': {},
    // Plugin para minificação em produção
    ...(process.env.NODE_ENV === 'production' ? { cssnano: {} } : {}),
  },
}
POSTCSS

echo "✓ postcss.config.js criado"
echo ""

# 4. Atualizar/Criar jsconfig.json para intellisense
echo "📝 Criando jsconfig.json..."

cat > jsconfig.json << 'JSCONFIG'
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@pages/*": ["./src/pages/*"],
      "@services/*": ["./src/services/*"],
      "@contexts/*": ["./src/contexts/*"],
      "@utils/*": ["./src/utils/*"],
      "@assets/*": ["./src/assets/*"]
    },
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": false,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "build"]
}
JSCONFIG

echo "✓ jsconfig.json criado"
echo ""

# 5. Criar arquivo de exemplo de variáveis CSS customizadas
echo "🎨 Criando src/styles/variables.css..."

mkdir -p src/styles

cat > src/styles/variables.css << 'VARIABLES'
/**
 * CSS Variables customizadas para adrisa007/sentinela (ID: 1112237272)
 * Pode ser importado no index.css se necessário
 */

:root {
  /* Cores do tema */
  --color-primary: #4f46e5;
  --color-secondary: #9333ea;
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-danger: #ef4444;
  --color-info: #3b82f6;

  /* Tipografia */
  --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-mono: ui-monospace, 'Courier New', monospace;

  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;

  /* Border radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);

  /* Transitions */
  --transition-fast: 150ms ease-in-out;
  --transition-base: 300ms ease-in-out;
  --transition-slow: 500ms ease-in-out;
}

/* Dark mode variables (opcional) */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #1f2937;
    --color-text: #f9fafb;
  }
}
VARIABLES

echo "✓ variables.css criado"
echo ""

# 6. Criar README com documentação
cat > CONFIG_README.md << 'README'
# Configurações Vite + Tailwind - adrisa007/sentinela (ID: 1112237272)

## 📁 Arquivos de Configuração

### vite.config.js
Configuração principal do Vite:
- ✅ Plugin React com Fast Refresh
- ✅ Path aliases (@components, @pages, etc)
- ✅ Proxy para API backend
- ✅ Otimizações de build
- ✅ Sourcemaps
- ✅ Code splitting estratégico

### tailwind.config.js
Configuração do Tailwind CSS:
- ✅ Cores customizadas (primary, secondary, success, etc)
- ✅ Animações personalizadas
- ✅ Box shadows customizados
- ✅ Dark mode support
- ✅ Font families
- ✅ Spacing e breakpoints

### postcss.config.js
Processamento de CSS:
- ✅ Tailwind CSS
- ✅ Autoprefixer
- ✅ Minificação em produção

### jsconfig.json
IntelliSense para VSCode:
- ✅ Path aliases configurados
- ✅ JSX support
- ✅ Module resolution

## 🎨 Cores Disponíveis

```css
/* Primary (Azul/Roxo) */
bg-primary-500, text-primary-600, border-primary-700

/* Secondary (Roxo) */
bg-secondary-500, text-secondary-600

/* Success, Warning, Danger, Info */
bg-success-500, bg-warning-500, bg-danger-500, bg-info-500