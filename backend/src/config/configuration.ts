import { registerAs } from '@nestjs/config';

export default () => ({
  app: registerAs('app', () => ({
    nodeEnv: process.env.NODE_ENV,
    frontendUrl: process.env.FRONTEND_URL,
    apiUrl: process.env.API_URL,
  })),

  database: registerAs('database', () => ({
    url: process.env.DATABASE_URL,
  })),

  jwt: registerAs('jwt', () => ({
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '8h',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  })),

  cookie: registerAs('cookie', () => ({
    secret: process.env.COOKIE_SECRET,
  })),

  crypto: registerAs('crypto', () => ({
    encryptionKey: process.env.ENCRYPTION_KEY,
  })),

  throttle: registerAs('throttle', () => ({
    ttl: Number(process.env.THROTTLE_TTL || 60000),
    limit: Number(process.env.THROTTLE_LIMIT || 300),
    limitLogin: Number(process.env.THROTTLE_LIMIT_LOGIN || 10),
  })),

  vercel: registerAs('vercel', () => ({
    blobToken: process.env.VERCEL_BLOB_TOKEN,
  })),

  sentry: registerAs('sentry', () => ({
    dsn: process.env.SENTRY_DSN,
  })),
});
