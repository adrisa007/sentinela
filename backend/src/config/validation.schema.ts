import Joi from 'joi';

export const validationSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'production', 'test').required(),
  DATABASE_URL: Joi.string().uri().required(),

  JWT_SECRET: Joi.string().min(32).required(),
  JWT_EXPIRES_IN: Joi.string().default('8h'),
  JWT_REFRESH_EXPIRES_IN: Joi.string().default('30d'),

  COOKIE_SECRET: Joi.string().min(32).default('change_me_cookie_secret_32_chars_min'),

  ENCRYPTION_KEY: Joi.string().length(64).hex().required(),

  FRONTEND_URL: Joi.string().uri().default('http://localhost:5173'),
  API_URL: Joi.string().uri().default('http://localhost:3000'),

  THROTTLE_TTL: Joi.number().integer().min(1000).default(60000),
  THROTTLE_LIMIT: Joi.number().integer().min(1).default(300),
  THROTTLE_LIMIT_LOGIN: Joi.number().integer().min(1).default(10),

  VERCEL_BLOB_TOKEN: Joi.string().optional(),

  SENTRY_DSN: Joi.string().uri().optional(),
});
