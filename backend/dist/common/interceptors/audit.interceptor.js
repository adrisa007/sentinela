"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuditInterceptor = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../prisma/prisma.service");
const operators_1 = require("rxjs/operators");
let AuditInterceptor = class AuditInterceptor {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger('AUDITORIA');
    }
    async intercept(context, next) {
        const req = context.switchToHttp().getRequest();
        const user = req.user;
        const metodo = req.method;
        const url = req.url;
        const ip = req.ip || req.connection.remoteAddress || 'unknown';
        if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(metodo)) {
            return next.handle();
        }
        const agora = new Date();
        let dadosAntes = null;
        let dadosDepois = null;
        let tabelaAfetada = '';
        let registroId = null;
        let acao = '';
        if (req.body && req.route?.path) {
            const pathParts = req.route.path.split('/');
            tabelaAfetada = pathParts[pathParts.length - 1].replace(/s$/, '');
            if (metodo === 'DELETE' || metodo === 'PATCH') {
                const id = req.params.id || req.body.id;
                if (id) {
                    try {
                        const model = this.prisma[tabelaAfetada];
                        if (model && typeof model.findUnique === 'function') {
                            dadosAntes = await model.findUnique({ where: { id: BigInt(id) } });
                        }
                    }
                    catch (e) {
                    }
                }
            }
        }
        return next.handle().pipe((0, operators_1.tap)(async (resultado) => {
            try {
                if (resultado && typeof resultado === 'object') {
                    dadosDepois = resultado;
                    if (resultado.id)
                        registroId = BigInt(resultado.id);
                }
                acao = metodo === 'POST' ? 'CREATE' : metodo === 'DELETE' ? 'DELETE' : 'UPDATE';
                await this.prisma.auditoriaGlobal.create({
                    data: {
                        entidadeId: user?.entidadeId || null,
                        usuarioId: user?.id || null,
                        acao,
                        tabelaAfetada: tabelaAfetada.toUpperCase(),
                        registroId: registroId || null,
                        dadosAntes,
                        dadosDepois,
                        ipAddress: ip.replace('::ffff:', ''),
                        userAgent: req.headers['user-agent'] || null,
                        timestamp: agora,
                    },
                });
                this.logger.log(`${acao} | ${tabelaAfetada} | ID: ${registroId || 'novo'} | Usuário: ${user?.email || 'anônimo'} | IP: ${ip}`);
            }
            catch (error) {
                this.logger.error('Falha ao gravar auditoria', error.stack);
            }
        }));
    }
};
exports.AuditInterceptor = AuditInterceptor;
exports.AuditInterceptor = AuditInterceptor = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AuditInterceptor);
//# sourceMappingURL=audit.interceptor.js.map