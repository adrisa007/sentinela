import { Controller, Get, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';

@Controller('api')
export class CsrfController {
  @Get('csrf-token')
  getCsrfToken(@Req() req: Request & { csrfToken?: () => string }, @Res() res: Response) {
    const token = req.csrfToken ? req.csrfToken() : null;
    res.json({ csrfToken: token });
  }
}
