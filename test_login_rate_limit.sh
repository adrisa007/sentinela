#!/bin/bash

echo "🧪 Testando Rate Limit de Login (10 req/min)"
echo "=============================================="
echo ""

# Fazer 12 tentativas de login
for i in {1..12}; do
    echo -n "Tentativa $i: "
    
    response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:8000/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "test", "password": "test"}')
    
    status_code=$(echo "$response" | tail -n 1)
    
    if [ "$status_code" == "401" ]; then
        echo "✅ 401 Unauthorized (credenciais inválidas)"
    elif [ "$status_code" == "429" ]; then
        echo "🚫 429 Too Many Requests (RATE LIMIT ATIVADO!)"
    else
        echo "❓ $status_code"
    fi
    
    sleep 0.5
done

echo ""
echo "✅ Teste concluído!"
echo "Esperado: Primeiras 10 tentativas = 401, depois 429"
