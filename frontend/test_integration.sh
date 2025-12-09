#!/bin/bash
echo "🔗 Teste de Integração Backend + Frontend"
echo "========================================="
echo ""

# Testar login via API
echo "🔐 Testando Login API..."
curl -X POST http://0.0.0.0:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' \
  -s | jq '.'

echo ""
echo "🌐 Testar no browser:"
echo "  Backend Docs: http://0.0.0.0:8080/docs"
echo "  Frontend: http://localhost:3000/login"
echo ""
