import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import * as speakeasy from 'speakeasy';
import * as qrcode from 'qrcode';

@Injectable()
export class TotpService {
  constructor(private prisma: PrismaService) {}

  async generateSecret(userId: number) {
    const user = await this.prisma.usuario.findUnique({ where: { id: userId } });
    if (!user) throw new UnauthorizedException('Usuário não encontrado');

    const secret = speakeasy.generateSecret({
      name: `Sentinela (${user.email})`,
      issuer: process.env.MFA_ISSUER || 'Sentinela',
    });

    await this.prisma.usuario.update({
      where: { id: userId },
      data: { totpSecret: secret.base32 },
    });

    return {
      secret: secret.base32,
      otpauthUrl: secret.otpauth_url,
    };
  }

  async getQrCode(userId: number) {
    const user = await this.prisma.usuario.findUnique({ where: { id: userId } });
    if (!user || !user.totpSecret) {
      throw new UnauthorizedException('MFA não configurado');
    }

    const otpauthUrl = speakeasy.otpauthURL({
      secret: user.totpSecret,
      label: user.email,
      issuer: process.env.MFA_ISSUER || 'Sentinela',
      encoding: 'base32',
    });

    const qrCodeDataUrl = await qrcode.toDataURL(otpauthUrl);
    return { qrCodeDataUrl };
  }

  async verifyToken(userId: number, token: string) {
    const user = await this.prisma.usuario.findUnique({ where: { id: userId } });
    if (!user || !user.totpSecret) {
      throw new UnauthorizedException('MFA não configurado');
    }

    const verified = speakeasy.totp.verify({
      secret: user.totpSecret,
      encoding: 'base32',
      token,
      window: 2,
    });

    if (!verified) {
      throw new UnauthorizedException('Código MFA inválido');
    }

    if (!user.totpEnabled) {
      await this.prisma.usuario.update({
        where: { id: userId },
        data: { totpEnabled: true },
      });
    }

    return { success: true, message: 'MFA verificado com sucesso' };
  }
}
