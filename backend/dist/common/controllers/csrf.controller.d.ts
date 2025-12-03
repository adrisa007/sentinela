import { Request, Response } from 'express';
export declare class CsrfController {
    getCsrfToken(req: Request & {
        csrfToken?: () => string;
    }, res: Response): void;
}
