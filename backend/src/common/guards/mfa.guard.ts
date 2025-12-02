import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

@Injectable()
export class MfaGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // ROOT e GESTOR = MFA obrigatório
    if (user && (user.perfil === 'ROOT' || user.perfil === 'GESTOR')) {
      if (!user.totpEnabled) {
        throw new UnauthorizedException(
          'MFA obrigatório.\n\nAcesse /auth/totp/setup para ativar o Google Authenticator.',
        );
      }
    }

    return true;
  }
}