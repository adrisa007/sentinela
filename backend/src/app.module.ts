import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { PrismaService } from './prisma/prisma.service';
import { CustomLoggerService } from './common/logger/logger.service';
import { JwtStrategy } from './common/guards/jwt.strategy';
import { AuthController } from './modules/auth/auth.controller';
import { CsrfController } from './common/controllers/csrf.controller';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PassportModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET') || 'sentinela-secret-key-change-in-production',
        signOptions: { expiresIn: '24h' },
      }),
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 30,
      },
    ]),
    HealthModule,
  ],
  controllers: [AuthController, CsrfController],
  providers: [PrismaService, CustomLoggerService, JwtStrategy],
  exports: [PrismaService, CustomLoggerService],
})
export class AppModule {}
