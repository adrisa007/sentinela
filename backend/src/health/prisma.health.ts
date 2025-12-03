import { Injectable } from '@nestjs/common';
import { HealthIndicator, HealthIndicatorResult, HealthCheckError } from '@nestjs/terminus';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PrismaHealthIndicator extends HealthIndicator {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async isHealthy(key: string): Promise<HealthIndicatorResult> {
    try {
      // Query simples para verificar conexão com Neon PostgreSQL
      await this.prisma.$queryRaw`SELECT 1`;
      return this.getStatus(key, true, { message: 'Neon PostgreSQL connected' });
    } catch (error) {
      throw new HealthCheckError(
        'PrismaHealthIndicator failed',
        this.getStatus(key, false, { message: error.message }),
      );
    }
  }
}
