import { LoggerService } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
export declare class CustomLoggerService implements LoggerService {
    private configService;
    private logger;
    constructor(configService: ConfigService);
    log(message: string, context?: any): void;
    error(message: string, trace?: string, context?: any): void;
    warn(message: string, context?: any): void;
    debug(message: string, context?: any): void;
    verbose(message: string, context?: any): void;
}
