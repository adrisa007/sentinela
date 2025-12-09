#!/usr/bin/env python3
"""
Script de inicialização que lê PORT do ambiente
"""
import os
import sys
import subprocess

# Obter porta do ambiente
port = os.getenv("PORT", "8000")

print(f"🚀 Iniciando Sentinela na porta {port}")

# Iniciar uvicorn
cmd = [
    "uvicorn",
    "app.main:app",
    "--host", "0.0.0.0",
    "--port", str(port),
    "--log-level", "info"
]

print(f"Comando: {' '.join(cmd)}")

try:
    subprocess.run(cmd, check=True)
except KeyboardInterrupt:
    print("\n🛑 Sentinela parado")
    sys.exit(0)
except Exception as e:
    print(f"❌ Erro ao iniciar: {e}")
    sys.exit(1)
