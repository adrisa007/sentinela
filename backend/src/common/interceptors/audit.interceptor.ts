import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  private readonly logger = new Logger('AUDITORIA');

  constructor(private readonly prisma: PrismaService) {}

  async intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Promise<Observable<any>> {
    const req = context.switchToHttp().getRequest();
    const user = req.user;
    const metodo = req.method;
    const url = req.url;
    const ip = req.ip || req.connection.remoteAddress || 'unknown';

    // Só audita rotas que mudam estado
    if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(metodo)) {
      return next.handle();
    }

    const agora = new Date();
    let dadosAntes: any = null;
    let dadosDepois: any = null;
    let tabelaAfetada = '';
    let registroId: bigint | null = null;
    let acao = '';

    // Captura dados ANTES da execução
    if (req.body && req.route?.path) {
      const pathParts = req.route.path.split('/');
      tabelaAfetada = pathParts[pathParts.length - 1].replace(/s$/, '');
      if (metodo === 'DELETE' || metodo === 'PATCH') {
        const id = req.params.id || req.body.id;
        if (id) {
          try {
            const model = this.prisma[tabelaAfetada as keyof typeof this.prisma];
            if (model && typeof (model as any).findUnique === 'function') {
              dadosAntes = await (model as any).findUnique({ where: { id: BigInt(id) } });
            }
          } catch (e) {
            // tabela não existe ou erro silencioso
          }
        }
      }
    }

    return next.handle().pipe(
      tap(async (resultado) => {
        try {
          // Captura dados DEPOIS
          if (resultado && typeof resultado === 'object') {
            dadosDepois = resultado;
            if (resultado.id) registroId = BigInt(resultado.id);
          }

          acao = metodo === 'POST' ? 'CREATE' : metodo === 'DELETE' ? 'DELETE' : 'UPDATE';

          await this.prisma.auditoriaGlobal.create({
            data: {
              entidadeId: user?.entidadeId || null,
              usuarioId: user?.id || null,
              acao,
              tabelaAfetada: tabelaAfetada.toUpperCase(),
              registroId: registroId || null,
              dadosAntes,
              dadosDepois,
              ipAddress: ip.replace('::ffff:', ''),
              userAgent: req.headers['user-agent'] || null,
              timestamp: agora,
            },
          });

          this.logger.log(
            `${acao} | ${tabelaAfetada} | ID: ${registroId || 'novo'} | Usuário: ${user?.email || 'anônimo'} | IP: ${ip}`,
          );
        } catch (error) {
          this.logger.error('Falha ao gravar auditoria', error.stack);
        }
      }),
    );
  }
}