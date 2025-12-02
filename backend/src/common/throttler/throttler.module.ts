import { Module } from '@nestjs/common';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        name: 'global',
        ttl: 60000,
        limit: 300,
      },
      {
        name: 'auth',
        ttl: 60000,
        limit: 10,
      },
    ]),
  ],
  providers: [ThrottlerGuard],
  exports: [ThrottlerGuard],
})
export class CustomThrottlerModule {}