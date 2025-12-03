"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const helmet_1 = __importDefault(require("helmet"));
const cookie_parser_1 = __importDefault(require("cookie-parser"));
const csurf_1 = __importDefault(require("csurf"));
const config_1 = require("@nestjs/config");
const throttler_exception_filter_1 = require("./common/throttler/throttler-exception.filter");
const logger_service_1 = require("./common/logger/logger.service");
const audit_interceptor_1 = require("./common/interceptors/audit.interceptor");
const prisma_service_1 = require("./prisma/prisma.service");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule, { bufferLogs: true });
    const configService = app.get(config_1.ConfigService);
    app.useLogger(app.get(logger_service_1.CustomLoggerService));
    app.use((0, helmet_1.default)({
        contentSecurityPolicy: {
            directives: {
                defaultSrc: ["'self'"],
                scriptSrc: ["'self'", "'unsafe-inline'", 'https://sentinela-opal-seven.vercel.app'],
                styleSrc: ["'self'", "'unsafe-inline'"],
                imgSrc: ["'self'", 'data:', 'https:'],
                connectSrc: ["'self'", 'https://opal.vercel.app'],
            },
        },
        referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
        hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
        hidePoweredBy: true,
    }));
    app.enableCors({
        origin: [
            'https://sentinela-opal-seven.vercel.app',
            'https://sentinela.app',
            'http://localhost:3000',
            'http://localhost:5173',
        ],
        methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
        credentials: true,
        allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token'],
    });
    app.use((0, cookie_parser_1.default)(configService.get('COOKIE_SECRET') || 'chave_super_secreta_256_bits'));
    const csrfProtection = (0, csurf_1.default)({
        cookie: {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 24 * 60 * 60,
        },
    });
    app.use((req, res, next) => {
        if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
            next();
        }
        else {
            csrfProtection(req, res, next);
        }
    });
    try {
        const prisma = app.get(prisma_service_1.PrismaService);
        app.useGlobalInterceptors(new audit_interceptor_1.AuditInterceptor(prisma));
    }
    catch (e) {
    }
    app.useGlobalFilters(new throttler_exception_filter_1.ThrottlerExceptionFilter());
    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`🚀 Sentinela API iniciada na porta ${port}`);
}
bootstrap();
//# sourceMappingURL=main.js.map