#!/bin/bash

echo "🧪 Executando Suite de Testes - Sentinela"
echo "=========================================="
echo ""

# Limpar
echo "🧹 Limpando cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
rm -rf .pytest_cache
rm -f test.db

# Executar testes básicos (que devem passar)
echo ""
echo "✅ Testes de Dependencies (12 testes):"
python -m pytest tests/test_dependencies.py -v --tb=line

# Executar testes de MFA
echo ""
echo "🔐 Testes de MFA (6 testes):"
python -m pytest tests/test_dependencies_mfa.py -v --tb=line

# Executar testes de Entidade
echo ""
echo "🏢 Testes de Entidade (9 testes):"
python -m pytest tests/test_entidade_dependency.py -v --tb=line

# Sumário
echo ""
echo "=========================================="
echo "📊 Resumo dos Testes"
echo "=========================================="
python -m pytest tests/ -v --tb=no | tail -20

