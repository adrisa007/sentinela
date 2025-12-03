import { Controller, Get } from '@nestjs/common';
import { HealthCheckService, HealthCheck, HealthCheckResult } from '@nestjs/terminus';
import { PrismaHealthIndicator } from './prisma.health';

/**
 * Health Check Controller
 * Lei 14.133/2021 - Sentinela
 * 
 * Rotas:
 * - GET /health → Status geral da aplicação (200 OK)
 * - GET /ready  → Readiness probe (verifica conexão com Neon PostgreSQL)
 * - GET /live   → Liveness probe (sempre retorna 200 se a app está rodando)
 */
@Controller()
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prismaHealth: PrismaHealthIndicator,
  ) {}

  /**
   * Health check básico - retorna status da aplicação
   */
  @Get('health')
  @HealthCheck()
  async check(): Promise<HealthCheckResult> {
    return this.health.check([
      () => this.prismaHealth.isHealthy('database'),
    ]);
  }

  /**
   * Readiness probe - verifica se a aplicação está pronta para receber tráfego
   * Usado pelo Kubernetes/Vercel para determinar se o container está pronto
   */
  @Get('ready')
  @HealthCheck()
  async ready(): Promise<HealthCheckResult> {
    return this.health.check([
      () => this.prismaHealth.isHealthy('database'),
    ]);
  }

  /**
   * Liveness probe - verifica se a aplicação está viva
   * Usado pelo Kubernetes/Vercel para determinar se o container precisa ser reiniciado
   */
  @Get('live')
  live(): { status: string; timestamp: string; uptime: number } {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    };
  }
}
