import { Request } from 'express';
import { PrismaService } from '../../prisma/prisma.service';
type RequestWithUser = Request & {
    user?: any;
};
export declare class AuthController {
    private readonly prisma;
    constructor(prisma: PrismaService);
    setupTotp(req: RequestWithUser): Promise<{
        qrCode: string;
        secret: string;
        message: string;
    }>;
    verifyTotp(req: RequestWithUser, body: {
        token: string;
    }): Promise<{
        message: string;
    }>;
}
export {};
