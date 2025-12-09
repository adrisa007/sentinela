"""
Router de Health Check para o projeto Sentinela
"""
from fastapi import APIRouter, status, Response
from typing import Dict
from datetime import datetime
import sys
import platform

router = APIRouter(prefix="/health", tags=["health"])

@router.get("", response_model=Dict)
async def health_check() -> Dict:
    return {
        "status": "ok",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "sentinela",
        "version": "1.0.0",
        "python_version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
        "platform": platform.system()
    }

@router.get("/ready")
async def readiness_check(response: Response) -> Dict:
    try:
        from app.database import check_database_connection
        if check_database_connection():
            return {"status": "ready", "database": "connected", "timestamp": datetime.utcnow().isoformat()}
        else:
            response.status_code = 503
            return {"status": "not ready", "database": "disconnected", "timestamp": datetime.utcnow().isoformat()}
    except Exception as e:
        response.status_code = 503
        return {"status": "not ready", "database": "error", "error": str(e), "timestamp": datetime.utcnow().isoformat()}

@router.get("/live")
async def liveness_check(response: Response) -> Dict:
    try:
        from app.redis_client import check_redis_connection, get_redis_info
        redis_healthy = check_redis_connection()
        redis_info = get_redis_info()
        if redis_healthy:
            return {
                "status": "alive",
                "redis": "connected",
                "redis_info": {
                    "version": redis_info.get("version", "unknown"),
                    "uptime_seconds": redis_info.get("uptime_seconds", 0),
                    "connected_clients": redis_info.get("connected_clients", 0)
                },
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            response.status_code = 503
            return {"status": "not alive", "redis": "disconnected", "error": redis_info.get("error", "Unknown"), "timestamp": datetime.utcnow().isoformat()}
    except Exception as e:
        response.status_code = 503
        return {"status": "not alive", "redis": "error", "error": str(e), "timestamp": datetime.utcnow().isoformat()}
