#!/bin/bash

echo "🧹 Limpeza Completa da Estrutura"
echo "================================="

# 1. Backup do que existe em app/core/
echo "💾 Fazendo backup de app/core/..."
cp -r app/core /tmp/core_backup 2>/dev/null || true

# 2. Remover TUDO exceto app/core/ e app/routers/
echo "🗑️  Removendo arquivos antigos..."
find app/ -maxdepth 1 -type f -name "*.py" ! -name "__init__.py" ! -name "main.py" | while read file; do
    echo "  Removendo: $file"
    rm -f "$file"
done

# 3. Remover app/models/ se existir
if [ -d "app/models" ]; then
    echo "  Removendo: app/models/"
    rm -rf app/models
fi

# 4. Limpar cache
echo "🧹 Limpando cache Python..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
rm -rf .pytest_cache 2>/dev/null || true

# 5. Verificar o que sobrou
echo ""
echo "================================="
echo "✅ Limpeza concluída!"
echo "================================="
echo ""
echo "📂 Arquivos em app/ (raiz):"
ls -la app/*.py 2>/dev/null || echo "Nenhum arquivo .py na raiz de app/"

echo ""
echo "📂 Arquivos em app/core/:"
ls -la app/core/*.py 2>/dev/null || echo "Nenhum arquivo em app/core/"

echo ""
echo "📂 Estrutura completa:"
tree app/ -I '__pycache__|*.pyc' -L 3 2>/dev/null || find app/ -name "*.py" -type f

