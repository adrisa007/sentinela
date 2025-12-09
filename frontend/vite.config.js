import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

/**
 * Vite Configuration - adrisa007/sentinela (ID: 1112237272)
 * https://vitejs.dev/config/
 */
export default defineConfig({
  plugins: [
    react({
      // React 18 automatic JSX runtime
      jsxRuntime: 'automatic',
      // Fast Refresh
      fastRefresh: true,
      // Babel config
      babel: {
        plugins: [
          // Remover PropTypes em produção
          process.env.NODE_ENV === 'production' && [
            'transform-react-remove-prop-types',
            { removeImport: true }
          ]
        ].filter(Boolean),
      },
    }),
  ],

  // Path aliases
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

  // Dev server
  server: {
    port: 3000,
    host: true,
    open: false,
    strictPort: false,
    cors: true,
    
    // Proxy para API backend
    proxy: {
      '/api': {
        target: process.env.VITE_API_URL || 'https://web-production-8355.up.railway.app',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ''),
        configure: (proxy, options) => {
          proxy.on('proxyReq', (proxyReq, req) => {
            console.log('[Proxy]', req.method, req.url)
          })
        },
      },
    },

    // HMR
    hmr: {
      overlay: true,
      timeout: 30000,
    },

    // Watch
    watch: {
      usePolling: process.env.VITE_USE_POLLING === 'true',
    },
  },

  // Build
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    minify: 'terser',
    
    terserOptions: {
      compress: {
        drop_console: process.env.NODE_ENV === 'production',
        drop_debugger: true,
      },
    },

    // Rollup options
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'chart-vendor': ['chart.js', 'react-chartjs-2'],
          'form-vendor': ['react-hook-form'],
        },
      },
    },

    chunkSizeWarningLimit: 1000,
    assetsInlineLimit: 4096,
  },

  // Optimize deps
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

  // Preview
  preview: {
    port: 4173,
    host: true,
    strictPort: false,
  },

  // Base
  base: '/',

  // Env prefix
  envPrefix: 'VITE_',
})
