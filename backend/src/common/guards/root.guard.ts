import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';

@Injectable()
export class RootGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user; // vem do JwtAuthGuard

    // 1. Se não tem usuário ou não é ROOT → bloqueia
    if (!user || user.perfil !== 'ROOT') {
      throw new ForbiddenException(
        'Acesso RESTRICTO.\n\nEsta funcionalidade é exclusiva do Administrador Master (ROOT).\n\nVocê não possui permissão para executá-la.',
      );
    }

    // 2. ROOT sempre passa
    return true;
  }
}