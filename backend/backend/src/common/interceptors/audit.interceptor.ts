import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { PrismaService } from '../../../prisma/prisma.service';
import { TipoAuditoria } from '@prisma/client';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(private prisma: PrismaService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url, body, user, ip, headers } = request;

    if (method === 'GET' || url.includes('/health')) {
      return next.handle();
    }

    const acaoMap: Record<string, TipoAuditoria> = {
      POST: 'CREATE',
      PUT: 'UPDATE',
      PATCH: 'UPDATE',
      DELETE: 'DELETE',
    };

    const acao = acaoMap[method];
    if (!acao) return next.handle();

    const dadosAntes = request.dadosAntes || null;
    
    return next.handle().pipe(
      tap(async (response) => {
        try {
          const tabela = this.extractTableName(url);
          const registroId = this.extractRecordId(url, response);

          await this.prisma.auditoriaGlobal.create({
            data: {
              acao,
              tabela,
              registroId,
              dadosAntes,
              dadosDepois: response,
              ip: ip || headers['x-forwarded-for'] || headers['x-real-ip'],
              userAgent: headers['user-agent'],
              usuarioId: user?.id || null,
            },
          });
        } catch (error) {
          console.error('Erro ao registrar auditoria:', error);
        }
      }),
    );
  }

  private extractTableName(url: string): string | null {
    const match = url.match(/\/api\/([^\/]+)/);
    return match ? match[1] : null;
  }

  private extractRecordId(url: string, response: any): number | null {
    const match = url.match(/\/(\d+)$/);
    if (match) return parseInt(match[1]);
    if (response?.id) return response.id;
    return null;
  }
}
