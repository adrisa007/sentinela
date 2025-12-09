#!/usr/bin/env python3
"""
Script de healthcheck para Railway
"""
import sys
import os

try:
    # Verificar se consegue importar
    from app.main import app
    print("✓ App importado com sucesso")
    
    # Verificar variáveis críticas
    port = os.getenv("PORT", "8000")
    print(f"✓ PORT configurado: {port}")
    
    print("✓ Healthcheck passou")
    sys.exit(0)
except Exception as e:
    print(f"❌ Healthcheck falhou: {e}")
    sys.exit(1)
