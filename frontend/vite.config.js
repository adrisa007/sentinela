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
