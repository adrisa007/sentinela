#!/bin/bash
echo "🛑 Parando todos os serviços do Sentinela..."
docker-compose -f docker-compose.dev.yml down
echo "✅ Todos os serviços parados"
