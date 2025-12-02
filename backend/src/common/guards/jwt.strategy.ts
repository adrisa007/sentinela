import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    private prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get('JWT_SECRET') || 'sentinela-secret-key-change-in-production',
    });
  }

  async validate(payload: any) {
    // Payload contém: { sub: userId, email, perfil, entidadeId }
    const user = await this.prisma.usuario.findUnique({
      where: { id: BigInt(payload.sub) },
      select: {
        id: true,
        email: true,
        nome: true,
        perfil: true,
        entidadeId: true,
        ativo: true,
        totpEnabled: true,
      },
    });

    if (!user || !user.ativo) {
      return null; // Usuário inválido ou inativo
    }

    // Retorna user que será anexado em req.user
    return {
      id: user.id,
      email: user.email,
      nome: user.nome,
      perfil: user.perfil,
      entidadeId: user.entidadeId,
      totpEnabled: user.totpEnabled,
    };
  }
}
