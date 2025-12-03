"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const throttler_1 = require("@nestjs/throttler");
const passport_1 = require("@nestjs/passport");
const jwt_1 = require("@nestjs/jwt");
const prisma_service_1 = require("./prisma/prisma.service");
const logger_service_1 = require("./common/logger/logger.service");
const jwt_strategy_1 = require("./common/guards/jwt.strategy");
const auth_controller_1 = require("./modules/auth/auth.controller");
const csrf_controller_1 = require("./common/controllers/csrf.controller");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            passport_1.PassportModule,
            jwt_1.JwtModule.registerAsync({
                inject: [config_1.ConfigService],
                useFactory: (config) => ({
                    secret: config.get('JWT_SECRET') || 'sentinela-secret-key-change-in-production',
                    signOptions: { expiresIn: '24h' },
                }),
            }),
            throttler_1.ThrottlerModule.forRoot([
                {
                    ttl: 60000,
                    limit: 30,
                },
            ]),
        ],
        controllers: [auth_controller_1.AuthController, csrf_controller_1.CsrfController],
        providers: [prisma_service_1.PrismaService, logger_service_1.CustomLoggerService, jwt_strategy_1.JwtStrategy],
        exports: [prisma_service_1.PrismaService, logger_service_1.CustomLoggerService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map