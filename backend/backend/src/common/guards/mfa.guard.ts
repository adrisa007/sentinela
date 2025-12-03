import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class MfaGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    const isPublic = this.reflector.get<boolean>('isPublic', context.getHandler());
    if (isPublic) return true;

    if (!user) return true;

    const requiresMfa = ['ROOT', 'GESTOR'].includes(user.perfil);

    if (requiresMfa && user.totpEnabled && !user.mfaVerified) {
      throw new UnauthorizedException(
        'Autenticação MFA necessária. Verifique o código TOTP.',
      );
    }

    return true;
  }
}
