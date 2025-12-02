import { Injectable, LoggerService } from '@nestjs/common';
import * as winston from 'winston';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class CustomLoggerService implements LoggerService {
  private logger: winston.Logger;

  constructor(private configService: ConfigService) {
    const isVercel = !!process.env.VERCEL;

    this.logger = winston.createLogger({
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
      format: winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
        winston.format.errors({ stack: true }),
        winston.format.json(), // ← JSON estruturado (perfeito para Vercel + Loki)
        winston.format.printf((info) => {
          const { timestamp, level, message, ...meta } = info;
          return JSON.stringify({
            timestamp,
            level: level.toUpperCase(),
            message,
            projeto: 'Sentinela',
            ambiente: process.env.NODE_ENV || 'development',
            entidadeId: meta.entidadeId || null,
            usuarioId: meta.usuarioId || null,
            usuarioEmail: meta.usuarioEmail || null,
            ip: meta.ip || null,
            ...meta,
          });
        }),
      ),
      transports: [
        // 1. Vercel Logs (automaticamente capturado no dashboard)
        new winston.transports.Console({
          stderrLevels: ['error', 'warn'],
        }),

        // 2. (FUTURO) Envio direto para Grafana Loki (descomente quando quiser)
        // new LokiTransport({
        //   host: 'https://loki.suaempresa.com',
        //   labels: { app: 'sentinela' },
        //   json: true,
        // }),
      ],
    });

    // Em Vercel, o console.log já vai pro dashboard – garantimos compatibilidade
    if (isVercel) {
      this.logger.add(
        new winston.transports.Console({
          format: winston.format.simple(),
        }),
      );
    }
  }

  log(message: string, context?: any) {
    this.logger.info(message, context);
  }

  error(message: string, trace?: string, context?: any) {
    this.logger.error(message, { trace, ...context });
  }

  warn(message: string, context?: any) {
    this.logger.warn(message, context);
  }

  debug(message: string, context?: any) {
    this.logger.debug(message, context);
  }

  verbose(message: string, context?: any) {
    this.logger.verbose(message, context);
  }
}