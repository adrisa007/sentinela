#!/bin/bash
# Script para iniciar os serviços do Sentinela

set -e

echo "�� Iniciando serviços do Sentinela..."

# Verificar se docker-compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose não está instalado"
    exit 1
fi

# Escolher ambiente
ENV=${1:-dev}

if [ "$ENV" = "dev" ]; then
    echo "📦 Iniciando ambiente de desenvolvimento..."
    docker-compose -f docker-compose.dev.yml up -d
    echo ""
    echo "✅ Redis iniciado!"
    echo "   Redis: localhost:6379"
    echo "   Redis Commander: http://localhost:8081"
else
    echo "📦 Iniciando ambiente completo..."
    docker-compose up -d
    echo ""
    echo "✅ Todos os serviços iniciados!"
    echo "   App: http://localhost:8000"
    echo "   Redis: localhost:6379"
    echo "   PostgreSQL: localhost:5432"
    echo "   Redis Commander: http://localhost:8081"
fi

echo ""
echo "🔍 Status dos containers:"
docker-compose ps

echo ""
echo "💡 Comandos úteis:"
echo "   Ver logs: docker-compose logs -f"
echo "   Parar: docker-compose down"
echo "   Reiniciar: docker-compose restart"
