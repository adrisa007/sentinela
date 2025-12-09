#!/bin/bash
set -e

echo "🚀 Iniciando Sentinela no Railway..."
echo "PORT: ${PORT}"
echo "RAILWAY_ENVIRONMENT: ${RAILWAY_ENVIRONMENT:-local}"

# Validar PORT
if [ -z "$PORT" ]; then
    echo "⚠️  PORT não definido, usando 8000"
    export PORT=8000
fi

echo "✓ Usando porta: $PORT"

# Executar healthcheck
python3 healthcheck.py || exit 1

# Iniciar aplicação com PORT expandido
exec uvicorn app.main:app --host 0.0.0.0 --port "$PORT" --log-level info
