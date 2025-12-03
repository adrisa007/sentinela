"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CustomThrottlerModule = void 0;
const common_1 = require("@nestjs/common");
const throttler_1 = require("@nestjs/throttler");
let CustomThrottlerModule = class CustomThrottlerModule {
};
exports.CustomThrottlerModule = CustomThrottlerModule;
exports.CustomThrottlerModule = CustomThrottlerModule = __decorate([
    (0, common_1.Module)({
        imports: [
            throttler_1.ThrottlerModule.forRoot([
                {
                    name: 'global',
                    ttl: 60000,
                    limit: 300,
                },
                {
                    name: 'auth',
                    ttl: 60000,
                    limit: 10,
                },
            ]),
        ],
        providers: [throttler_1.ThrottlerGuard],
        exports: [throttler_1.ThrottlerGuard],
    })
], CustomThrottlerModule);
//# sourceMappingURL=throttler.module.js.map