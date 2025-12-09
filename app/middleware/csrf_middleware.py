# app/middleware/csrf_middleware.py
from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware
from typing import List

class CSRFProtectionMiddleware(BaseHTTPMiddleware):
    """
    Middleware para proteção contra ataques CSRF
    """
    
    def __init__(self, app, allowed_origins: List[str] = None):
        super().__init__(app)
        self.allowed_origins = allowed_origins or [
            "http://localhost",
            "http://localhost:8000",
            "http://127.0.0.1",
            "http://127.0.0.1:8000"
        ]
    
    async def dispatch(self, request: Request, call_next):
        # Verifica apenas métodos que modificam dados
        if request.method in ["POST", "PUT", "DELETE", "PATCH"]:
            origin = request.headers.get("Origin")
            referer = request.headers.get("Referer")
            
            # Verifica se tem origem
            if not origin and not referer:
                raise HTTPException(
                    status_code=403,
                    detail="CSRF validation failed: Missing Origin or Referer header"
                )
            
            # Verifica se a origem está permitida
            check_header = origin or referer
            if not any(check_header.startswith(allowed) for allowed in self.allowed_origins):
                raise HTTPException(
                    status_code=403,
                    detail=f"CSRF validation failed: Origin {check_header} not allowed"
                )
        
        response = await call_next(request)
        return response