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
