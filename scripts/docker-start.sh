#!/bin/bash
# Script para iniciar todos os serviços do Sentinela com Docker

echo "🚀 Iniciando todos os serviços do Sentinela..."
echo ""

# Parar containers antigos se existirem
echo "🛑 Parando containers antigos..."
docker-compose -f docker-compose.dev.yml down

# Build das imagens
echo ""
echo "🔨 Fazendo build das imagens..."
docker-compose -f docker-compose.dev.yml build

# Iniciar serviços
echo ""
echo "▶️  Iniciando serviços..."
docker-compose -f docker-compose.dev.yml up -d

# Aguardar serviços iniciarem
echo ""
echo "⏳ Aguardando serviços iniciarem..."
sleep 10

# Verificar status
echo ""
echo "📊 Status dos serviços:"
docker-compose -f docker-compose.dev.yml ps

# Verificar logs
echo ""
echo "📝 Últimas linhas dos logs:"
docker-compose -f docker-compose.dev.yml logs --tail=5

echo ""
echo "================================================"
echo "✅ TODOS OS SERVIÇOS INICIADOS!"
echo "================================================"
echo ""
echo "🔗 URLs disponíveis:"
echo "   API Web:          http://localhost:8000"
echo "   API Docs:         http://localhost:8000/docs"
echo "   Health Check:     http://localhost:8000/health"
echo "   Redis Commander:  http://localhost:8081"
echo "   Flower (Celery):  http://localhost:5555"
echo ""
echo "📊 Serviços rodando:"
echo "   • web            - API FastAPI (porta 8000)"
echo "   • redis          - Cache e broker (porta 6379)"
echo "   • celery-worker  - Processador de tasks"
echo "   • celery-beat    - Agendador periódico"
echo "   • flower         - Monitor Celery (porta 5555)"
echo "   • redis-ui       - Interface Redis (porta 8081)"
echo ""
echo "📝 Comandos úteis:"
echo "   Ver logs:        docker-compose -f docker-compose.dev.yml logs -f [serviço]"
echo "   Parar tudo:      docker-compose -f docker-compose.dev.yml down"
echo "   Reiniciar:       docker-compose -f docker-compose.dev.yml restart [serviço]"
echo "   Shell no web:    docker exec -it sentinela-web bash"
echo ""
echo "🧪 Testar endpoints:"
echo "   curl http://localhost:8000/health"
echo "   curl http://localhost:8000/health/live"
echo "   curl http://localhost:8000/health/ready"
echo ""
