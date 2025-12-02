app.enableCors({
  origin: [
    'https://sentinela-opal-seven.vercel.app',
    'http://localhost:3000', // dev
  ],
  credentials: true,
});