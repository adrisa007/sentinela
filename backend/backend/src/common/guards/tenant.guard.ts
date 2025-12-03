import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new UnauthorizedException('Usuário não autenticado');
    }

    if (user.perfil === 'ROOT') {
      return true;
    }

    if (!user.entidadeId) {
      throw new ForbiddenException('Usuário sem entidade vinculada');
    }

    const entidade = await this.prisma.entidade.findUnique({
      where: { id: user.entidadeId },
    });

    if (!entidade) {
      throw new ForbiddenException('Entidade não encontrada');
    }

    if (entidade.status === 'INATIVA') {
      throw new ForbiddenException(
        'Entidade inativa. Entre em contato com o administrador.',
      );
    }

    if (entidade.status === 'SUSPENSA') {
      throw new ForbiddenException(
        'Entidade suspensa. Regularize a situação para continuar.',
      );
    }

    request.entidade = entidade;
    return true;
  }
}
