#!/bin/bash
set -e

echo "🚀 Iniciando Sentinela no Railway..."

# Verificar variáveis de ambiente
echo "PORT: ${PORT:-8000}"
echo "RAILWAY_ENVIRONMENT: ${RAILWAY_ENVIRONMENT:-local}"

# Executar healthcheck
python3 healthcheck.py || exit 1

# Iniciar aplicação
exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000} --log-level info
