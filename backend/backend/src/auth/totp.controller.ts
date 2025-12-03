import { Controller, Post, Body, Req, UseGuards, Get } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TotpService } from './totp.service';

@Controller('auth/totp')
@UseGuards(JwtAuthGuard)
export class TotpController {
  constructor(private totpService: TotpService) {}

  @Post('setup')
  async setupTotp(@Req() req) {
    return this.totpService.generateSecret(req.user.id);
  }

  @Post('verify')
  async verifyTotp(@Req() req, @Body('token') token: string) {
    return this.totpService.verifyToken(req.user.id, token);
  }

  @Get('qrcode')
  async getQrCode(@Req() req) {
    return this.totpService.getQrCode(req.user.id);
  }
}
