import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';

@Injectable()
export class RootGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || user.perfil !== 'ROOT') {
      throw new ForbiddenException(
        'Acesso restrito ao administrador ROOT',
      );
    }

    return true;
  }
}
