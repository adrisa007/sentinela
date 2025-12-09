#!/usr/bin/env python3
"""
Entrypoint para Railway - adrisa007/sentinela (ID: 1112237272)
"""
import os
import sys

if __name__ == "__main__":
    # Obter porta do ambiente
    port = int(os.getenv("PORT", "8000"))
    
    print(f"="*50)
    print(f"🚀 Sentinela - adrisa007/sentinela")
    print(f"🆔 Repo ID: 1112237272")
    print(f"📍 Porta: {port}")
    print(f"🌍 Ambiente: {os.getenv('RAILWAY_ENVIRONMENT', 'local')}")
    print(f"="*50)
    
    # Iniciar uvicorn
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
