import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user; // vem do JwtAuthGuard

    // 1. Usuário ROOT ignora tudo (governança master)
    if (user?.perfil === 'ROOT') {
      return true;
    }

    // 2. Usuário sem entidadeId = bloqueado (exceto ROOT)
    if (!user?.entidadeId) {
      throw new ForbiddenException(
        'Acesso negado: usuário não vinculado a nenhuma entidade.',
      );
    }

    // 3. Busca a entidade no banco
    const entidade = await this.prisma.entidade.findUnique({
      where: { id: user.entidadeId },
      select: { id: true, status: true, razaoSocial: true },
    });

    // 4. Entidade não encontrada
    if (!entidade) {
      throw new NotFoundException(
        'Entidade não encontrada. Contate o administrador.',
      );
    }

    // 5. Entidade INATIVA ou SUSPENSA = bloqueia tudo
    if (entidade.status !== 'ATIVA') {
      throw new ForbiddenException(
        `Acesso temporariamente suspenso.\n\nEntidade: ${entidade.razaoSocial}\nStatus: ${entidade.status}\n\nContate o administrador master (ROOT).`,
      );
    }

    // 6. Tudo OK → injeta entidade no request (útil em services)
    request.entidade = entidade;

    return true;
  }
}