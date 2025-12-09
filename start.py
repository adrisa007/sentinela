#!/usr/bin/env python3
"""
Script de inicialização para Railway
Lê a variável PORT do ambiente e inicia uvicorn
Repo: adrisa007/sentinela (ID: 1112237272)
"""
import os
import sys

def main():
    # Obter porta do ambiente (Railway injeta PORT)
    port = os.getenv("PORT", "8000")
    
    print(f"🚀 Iniciando Sentinela no Railway")
    print(f"📍 Porta: {port}")
    print(f"🆔 Repo ID: 1112237272")
    
    # Importar e rodar uvicorn programaticamente
    try:
        import uvicorn
        uvicorn.run(
            "app.main:app",
            host="0.0.0.0",
            port=int(port),
            log_level="info",
            access_log=True
        )
    except Exception as e:
        print(f"❌ Erro ao iniciar: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
