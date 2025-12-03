"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const speakeasy = __importStar(require("speakeasy"));
const qrcode = __importStar(require("qrcode"));
const bcrypt = __importStar(require("bcrypt"));
const prisma_service_1 = require("../../prisma/prisma.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let AuthController = class AuthController {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async setupTotp(req) {
        const user = req.user;
        if (user.perfil === 'ROOT' || user.perfil === 'GESTOR') {
            if (user.totpEnabled) {
                throw new common_1.BadRequestException('MFA já está ativo');
            }
        }
        else {
            throw new common_1.ForbiddenException('MFA só é permitido para ROOT e GESTOR');
        }
        const secret = speakeasy.generateSecret({
            name: `Sentinela (${user.email})`,
            issuer: 'Sentinela',
        });
        await this.prisma.usuario.update({
            where: { id: user.id },
            data: {
                totpSecret: await bcrypt.hash(secret.base32, 12),
                totpTempSecret: secret.base32,
            },
        });
        const qrCodeUrl = await qrcode.toDataURL(secret.otpauth_url);
        return {
            qrCode: qrCodeUrl,
            secret: secret.base32,
            message: 'Escaneie com Google Authenticator e confirme o código',
        };
    }
    async verifyTotp(req, body) {
        const user = await this.prisma.usuario.findUnique({
            where: { id: req.user.id },
            select: { totpTempSecret: true, perfil: true },
        });
        const verified = speakeasy.totp.verify({
            secret: user.totpTempSecret,
            encoding: 'base32',
            token: body.token,
            window: 2,
        });
        if (!verified) {
            throw new common_1.UnauthorizedException('Código inválido ou expirado');
        }
        await this.prisma.usuario.update({
            where: { id: req.user.id },
            data: {
                totpEnabled: true,
                totpSecret: await bcrypt.hash(user.totpTempSecret, 12),
                totpTempSecret: null,
            },
        });
        return { message: 'MFA ativado com sucesso!' };
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, common_1.Post)('totp/setup'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "setupTotp", null);
__decorate([
    (0, common_1.Post)('totp/verify'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "verifyTotp", null);
exports.AuthController = AuthController = __decorate([
    (0, common_1.Controller)('auth'),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map