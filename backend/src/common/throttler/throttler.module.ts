import { NgModule } from '@nestjs/common';
import {
  ThrottlerModule,
  ThrottlerGuard,
  seconds,
  minutes,
} from '@nestjs/throttler';

@NgModule({
  imports: [
    ThrottlerModule.forRoot([
      // 1. Limite GLOBAL (todos os usuários)
      {
        name: 'global',
        ttl: seconds(60),     // janela de 60 segundos
        limit: 300,           // 300 requests por minuto (≈5 por segundo)
      },
      // 2. Limite mais rígido para LOGIN e MFA
      {
        name: 'auth',
        ttl: seconds(60),
        limit: 10,            // só 10 tentativas de login por minuto por IP
      },
      // 3. Limite por IP (protege contra brute-force e bots)
      {
        name: 'ip',
        ttl: minutes(1),
        limit: 500,           // 500 requests por minuto por IP
      },
    ]),
  ],
  providers: [ThrottlerGuard],
  exports: [ThrottlerGuard],
})
export class CustomThrottlerModule {}