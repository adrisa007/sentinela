#!/bin/bash
# Script para testar os endpoints de health check

echo "🧪 Testando endpoints de health check do Sentinela"
echo "=================================================="
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# URL base
BASE_URL="http://localhost:8000"

echo -e "${BLUE}1. Testando GET /health${NC}"
echo "   Endpoint principal de health check"
response=$(curl -s -w "\n%{http_code}" $BASE_URL/health)
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$status_code" = "200" ]; then
    echo -e "   ${GREEN}✓ Status: $status_code${NC}"
    echo "   Resposta: $body" | python3 -m json.tool 2>/dev/null || echo "   $body"
else
    echo -e "   ${RED}✗ Status: $status_code${NC}"
fi
echo ""

echo -e "${BLUE}2. Testando GET /health/ready${NC}"
echo "   Endpoint com verificação de banco de dados (SELECT 1)"
response=$(curl -s -w "\n%{http_code}" $BASE_URL/health/ready)
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$status_code" = "200" ]; then
    echo -e "   ${GREEN}✓ Status: $status_code (Banco conectado)${NC}"
    echo "   Resposta: $body"
elif [ "$status_code" = "503" ]; then
    echo -e "   ${RED}✗ Status: $status_code (Banco desconectado)${NC}"
    echo "   Resposta: $body"
else
    echo -e "   ${RED}✗ Status: $status_code${NC}"
fi
echo ""

echo -e "${BLUE}3. Testando GET /health/live${NC}"
echo "   Endpoint de liveness check (Kubernetes)"
response=$(curl -s -w "\n%{http_code}" $BASE_URL/health/live)
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$status_code" = "200" ]; then
    echo -e "   ${GREEN}✓ Status: $status_code${NC}"
    echo "   Resposta: $body"
else
    echo -e "   ${RED}✗ Status: $status_code${NC}"
fi
echo ""

echo "=================================================="
echo "✅ Testes concluídos!"
echo ""
echo "📚 Documentação dos endpoints:"
echo "   - GET /health       : Status geral da aplicação"
echo "   - GET /health/ready : Verifica conexão com banco (200 OK / 503 Error)"
echo "   - GET /health/live  : Verifica se app está viva"
echo ""
echo "🔗 Documentação interativa: http://localhost:8000/docs"
