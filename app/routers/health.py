"""
Router de Health Check para o projeto Sentinela
Testa conexões com Neon Database e Redis
Repositório: adrisa007/sentinela (ID: 1112237272)
"""
from fastapi import APIRouter, status, Response
from typing import Dict
from datetime import datetime
import sys
import platform

router = APIRouter(
    prefix="/health",
    tags=["health"]
)

@router.get("", response_model=Dict)
async def health_check(response: Response) -> Dict:
    """
    Endpoint principal de health check
    
    Testa:
    - Conexão com Neon Database (PostgreSQL)
    - Status geral da aplicação
    
    Returns:
        Dict: Status da aplicação e conexão com banco
    """
    health_data = {
        "status": "ok",
        "service": "sentinela",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0",
        "python_version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
        "platform": platform.system()
    }
    
    # Testar conexão com Neon Database
    try:
        from app.database import check_database_connection
        
        db_connected = check_database_connection()
        
        if db_connected:
            health_data["database"] = "connected"
            health_data["database_type"] = "neon_postgres"
        else:
            health_data["database"] = "disconnected"
            health_data["status"] = "degraded"
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    except Exception as e:
        health_data["database"] = "error"
        health_data["database_error"] = str(e)
        health_data["status"] = "degraded"
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    
    return health_data

@router.get("/ready")
async def readiness_check(response: Response) -> Dict:
    """
    Endpoint de readiness check - Verifica Neon Database
    
    Executa SELECT 1 no Neon para verificar conectividade.
    Retorna 200 se conectado, 503 caso contrário.
    
    Returns:
        Dict: Status de prontidão com detalhes do banco
    """
    try:
        from app.database import check_database_connection
        
        db_healthy = check_database_connection()
        
        if db_healthy:
            return {
                "status": "ready",
                "database": "connected",
                "database_type": "neon_postgres",
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
            return {
                "status": "not ready",
                "database": "disconnected",
                "timestamp": datetime.utcnow().isoformat()
            }
    except Exception as e:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {
            "status": "not ready",
            "database": "error",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }

@router.get("/live")
async def liveness_check(response: Response) -> Dict:
    """
    Endpoint de liveness check - Verifica Redis
    
    Executa PING no Redis para verificar conectividade.
    Retorna 200 se conectado, 503 caso contrário.
    
    Returns:
        Dict: Status de vida com detalhes do Redis
    """
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
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
            return {
                "status": "not alive",
                "redis": "disconnected",
                "error": redis_info.get("error", "Unknown error"),
                "timestamp": datetime.utcnow().isoformat()
            }
    except Exception as e:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {
            "status": "not alive",
            "redis": "error",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }

@router.get("/neon")
async def neon_database_check(response: Response) -> Dict:
    """
    Endpoint específico para testar Neon Database
    
    Executa SELECT 1 e retorna informações detalhadas do banco.
    
    Returns:
        Dict: Status detalhado da conexão com Neon
    """
    try:
        from app.database import check_database_connection, engine
        from sqlalchemy import text
        
        # Testar conexão
        db_connected = check_database_connection()
        
        if not db_connected:
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
            return {
                "status": "error",
                "database": "disconnected",
                "message": "Não foi possível conectar ao Neon Database"
            }
        
        # Obter informações do banco
        with engine.connect() as conn:
            # Versão do PostgreSQL
            result = conn.execute(text("SELECT version()"))
            version = result.scalar()
            
            # Nome do banco
            result = conn.execute(text("SELECT current_database()"))
            db_name = result.scalar()
            
            # Usuário
            result = conn.execute(text("SELECT current_user"))
            db_user = result.scalar()
        
        return {
            "status": "ok",
            "database": "connected",
            "database_type": "neon_postgres",
            "details": {
                "database_name": db_name,
                "user": db_user,
                "version": version.split()[0] if version else "unknown",
                "host": "neon.tech"
            },
            "timestamp": datetime.utcnow().isoformat()
        }
    
    except Exception as e:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {
            "status": "error",
            "database": "error",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }
