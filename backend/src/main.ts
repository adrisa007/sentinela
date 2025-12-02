import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import * as cookieParser from 'cookie-parser';
import * as csurf from 'csurf';
import { ConfigService } from '@nestjs/config';
import { ThrottlerGuard } from '@nestjs/throttler';
import { ThrottlerExceptionFilter } from './common/throttler/throttler-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // =============================================
  // 1. HELMET – Cabeçalhos de segurança
  // =============================================
  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: ["'self'", "'unsafe-inline'", 'https://sentinela-opal-seven.vercel.app'],
          styleSrc: ["'self'", "'unsafe-inline'"],
          imgSrc: ["'self'", 'data:', 'https:'],
          connectSrc: ["'self'", 'https://opal.vercel.app'],
        },
      },
      referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
      hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
      hidePoweredBy: true,
    }),
  );

  // =============================================
  // 2. CORS RESTRITO
  // =============================================
  app.enableCors({
    origin: [
      'https://sentinela-opal-seven.vercel.app',
      'https://sentinela.app',
      'http://localhost:3000',
      'http://localhost:5173',
    ],
    methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token'],
  });

  // =============================================
  // 3. COOKIE PARSER
  // =============================================
  app.use(cookieParser(configService.get('COOKIE_SECRET') || 'chave_super_secreta_256_bits'));

  // =============================================
  // 4. CSRF PROTECTION
  // =============================================
  const csrfProtection = csurf({
    cookie: {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 24 * 60 * 60,
    },
  });

  app.get('/api/csrf-token', (req, res) => {
    res.json({ csrfToken: req.csrfToken() });
  });

  app.use((req, res, next) => {
    if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
      next();
    } else {
      csrfProtection(req, res, next);
    }
  });

  // =============================================
  // 5. RATE LIMITING (THROTTLER)
  // =============================================
  app.useGlobalGuards(app.get(ThrottlerGuard));

  app.useGlobalGuards(
    new (class extends ThrottlerGuard {
      protected getTracker(req: any): string {
        return req.ips?.length ? req.ips[0] : req.ip;
      }

      protected getKeyPrefix(req: any): string {
        if (req.url.includes('/auth')) {
          return 'auth';
        }
        return 'global';
      }
    })(),
  );

  // =============================================
  // 6. EXCEPTION FILTERS
  // =============================================
  app.useGlobalFilters(new ThrottlerExceptionFilter());

  // =============================================
  // START
  // =============================================
  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Sentinela API iniciada na porta ${port}`);
}

bootstrap();

// backend/src/main.ts (adicione esta linha)
app.useGlobalInterceptors(new AuditInterceptor(app.get(PrismaService)));