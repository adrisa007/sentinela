import {
  Controller,
  Post,
  UseGuards,
  Req,
  Body,
  BadRequestException,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import * as speakeasy from 'speakeasy';
import * as qrcode from 'qrcode';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

type RequestWithUser = Request & { user?: any };

@Controller('auth')
export class AuthController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('totp/setup')
  @UseGuards(JwtAuthGuard)
  async setupTotp(@Req() req: RequestWithUser) {
  const user = req.user;

  // ROOT e GESTOR = obrigatório
  if (user.perfil === 'ROOT' || user.perfil === 'GESTOR') {
    if (user.totpEnabled) {
      throw new BadRequestException('MFA já está ativo');
    }
  } else {
    throw new ForbiddenException('MFA só é permitido para ROOT e GESTOR');
  }

  const secret = speakeasy.generateSecret({
    name: `Sentinela (${user.email})`,
    issuer: 'Sentinela',
  });

  // Salva secret temporário (criptografado)
  await this.prisma.usuario.update({
    where: { id: user.id },
    data: {
      totpSecret: await bcrypt.hash(secret.base32, 12),
      totpTempSecret: secret.base32, // campo temporário (apagar após ativação)
    },
  });

  const qrCodeUrl = await qrcode.toDataURL(secret.otpauth_url!);

  return {
    qrCode: qrCodeUrl,
    secret: secret.base32,
    message: 'Escaneie com Google Authenticator e confirme o código',
  };
  }

  @Post('totp/verify')
  @UseGuards(JwtAuthGuard)
  async verifyTotp(@Req() req: RequestWithUser, @Body() body: { token: string }) {
  const user = await this.prisma.usuario.findUnique({
    where: { id: req.user.id },
    select: { totpTempSecret: true, perfil: true },
  });

  const verified = speakeasy.totp.verify({
    secret: user!.totpTempSecret!,
    encoding: 'base32',
    token: body.token,
    window: 2, // tolera ±60 segundos
  });

  if (!verified) {
    throw new UnauthorizedException('Código inválido ou expirado');
  }

  // Ativa MFA permanentemente
  await this.prisma.usuario.update({
    where: { id: req.user.id },
    data: {
      totpEnabled: true,
      totpSecret: await bcrypt.hash(user!.totpTempSecret!, 12),
      totpTempSecret: null, // limpa campo temporário
    },
  });

  return { message: 'MFA ativado com sucesso!' };
  }
}
