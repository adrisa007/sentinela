import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import csurf from 'csurf';
import { ConfigService } from '@nestjs/config';
import { ThrottlerGuard } from '@nestjs/throttler';
import { ThrottlerExceptionFilter } from './common/throttler/throttler-exception.filter';
import { CustomLoggerService } from './common/logger/logger.service';
import { AuditInterceptor } from './common/interceptors/audit.interceptor';
import { PrismaService } from './prisma/prisma.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  const configService = app.get(ConfigService);

  // Substitui o logger padrão do Nest pelo nosso
  app.useLogger(app.get(CustomLoggerService));

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

  // Rota CSRF será tratada por um controller dedicado (veja auth.controller ou crie csrf.controller)

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
  // Garanta que o ThrottlerGuard esteja disponível via DI (configure ThrottlerModule no AppModule)
  // Comentado temporariamente - use @UseGuards(ThrottlerGuard) em controllers específicos se necessário
  // app.useGlobalGuards(app.get(ThrottlerGuard));

  // Guard customizado para track por IP e prefixo por rota
  // Nota: Requer ThrottlerGuard com storage e reflector configurados adequadamente
  // Comente se causar erros de inicialização
  // app.useGlobalGuards(
  //   new (class extends ThrottlerGuard {
  //     protected async getTracker(req: any): Promise<string> {
  //       return req.ips?.length ? req.ips[0] : req.ip;
  //     }
  //
  //     protected getKeyPrefix(req: any): string {
  //       if (req.url.includes('/auth')) return 'auth';
  //       return 'global';
  //     }
  //   })(),
  // );

  // =============================================
  // 6. INTERCEPTORS / EXCEPTION FILTERS
  // =============================================
  // Auditoria (interceptor) — usa PrismaService
  try {
    const prisma = app.get(PrismaService);
    app.useGlobalInterceptors(new AuditInterceptor(prisma));
  } catch (e) {
    // Se o PrismaService não estiver registrado ainda, ignora (ou registre-o no AppModule)
    // console.warn('PrismaService não disponível para AuditInterceptor');
  }

  app.useGlobalFilters(new ThrottlerExceptionFilter());

  // =============================================
  // START
  // =============================================
  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Sentinela API iniciada na porta ${port}`);
}

bootstrap();