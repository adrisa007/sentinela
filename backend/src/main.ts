// backend/src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ThrottlerGuard } from '@nestjs/throttler';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Rate limiting GLOBAL + POR IP
  app.useGlobalGuards(app.get(ThrottlerGuard));

  // Proteção extra para rotas de auth
  app.useGlobalGuards(
    new (class extends ThrottlerGuard {
      protected getTracker(req: any): string {
        return req.ips.length ? req.ips[0] : req.ip; // Cloudflare/Vercel
      }

      protected getKeyPrefix(req: any): string {
        if (req.url.includes('/auth')) {
          return 'auth'; // limite mais rígido
        }
        return 'global';
      }
    })(),
  );

  await app.listen(3000);
}
bootstrap();

app.enableCors({
  origin: [
    'https://sentinela-opal-seven.vercel.app',
    'http://localhost:3000', // dev
  ],
  credentials: true,
});