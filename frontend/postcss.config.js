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
