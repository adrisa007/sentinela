import { CanActivate, ExecutionContext } from '@nestjs/common';
export declare class RootGuard implements CanActivate {
    canActivate(context: ExecutionContext): boolean;
}
