#!/bin/bash
# organize_repository.sh
# Organiza repositório com boas práticas
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🗂️  Organizando Repositório - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela

# 1. Analisar estrutura atual
echo "📊 Estrutura atual do repositório:"
tree -L 2 -I 'node_modules|__pycache__|.git|dist|build|.venv' || ls -la
echo ""

# 2. Criar estrutura de boas práticas
echo "📁 Criando estrutura organizada..."

# Estrutura recomendada
mkdir -p {docs,scripts,tests,.github/workflows}

# 3. Limpar arquivos temporários e desnecessários
echo "🧹 Removendo arquivos desnecessários..."

# Arquivos temporários
find . -name "*.pyc" -delete
find . -name "*.pyo" -delete
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null
find . -name ".coverage" -delete
find . -name "*.log" -delete
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete
find . -name "*.swp" -delete
find . -name "*.swo" -delete
find . -name "*~" -delete

# Node modules duplicados
find . -name "package-lock.json" -not -path "./frontend/*" -delete
find . -name "node_modules" -not -path "./frontend/*" -type d -exec rm -rf {} + 2>/dev/null

echo "✓ Arquivos temporários removidos"

# 4. Organizar scripts shell
echo "📜 Organizando scripts..."

mkdir -p scripts/{setup,deploy,test,utils}

# Mover scripts para pasta scripts/
find . -maxdepth 1 -name "*.sh" -not -name "organize_repository.sh" -exec mv {} scripts/utils/ \; 2>/dev/null

echo "✓ Scripts organizados"

# 5. Criar/Atualizar .gitignore completo
echo "🚫 Atualizando .gitignore..."

cat > .gitignore << 'GITIGNORE'
# ==========================================
# .gitignore - adrisa007/sentinela
# Repository ID: 1112237272
# ==========================================

# ==========================================
# Python
# ==========================================
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environments
venv/
env/
ENV/
.venv/
.ENV/

# PyCharm
.idea/

# VS Code
.vscode/
*.code-workspace

# Pytest
.pytest_cache/
.coverage
htmlcov/
.tox/
.hypothesis/

# MyPy
.mypy_cache/
.dmypy.json
dmypy.json

# Jupyter
.ipynb_checkpoints/
*.ipynb

# ==========================================
# Node.js / Frontend
# ==========================================
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Build outputs
dist/
build/
*.local

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Package lock (keep only in frontend/)
package-lock.json
yarn.lock

# ==========================================
# Database
# ==========================================
*.db
*.sqlite
*.sqlite3
*.db-journal

# PostgreSQL
*.sql
*.dump

# ==========================================
# Logs
# ==========================================
*.log
logs/
*.log.*

# ==========================================
# OS
# ==========================================
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini

# ==========================================
# Editor / IDE
# ==========================================
*.swp
*.swo
*~
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# ==========================================
# Testing
# ==========================================
coverage/
.nyc_output/
*.lcov

# ==========================================
# Temporary
# ==========================================
tmp/
temp/
*.tmp
*.bak
*.backup

# ==========================================
# Railway / Deploy
# ==========================================
.railway/

# ==========================================
# Secrets / Sensitive
# ==========================================
*.pem
*.key
*.cert
secrets.yml
.secrets/
credentials.json

# ==========================================
# Documentation Build
# ==========================================
docs/_build/
site/
GITIGNORE

echo "✓ .gitignore atualizado"

# 6. Criar README.md estruturado
echo "📝 Atualizando README.md..."

cat > README.md << 'README'
# 🛡️ Sentinela

**Vigilância Total, Risco Zero**

Sistema completo de monitoramento e gestão de contratos com integração PNCP.

[![Repository ID](https://img.shields.io/badge/Repository%20ID-1112237272-blue)](https://github.com/adrisa007/sentinela)
[![Python](https://img.shields.io/badge/Python-3.11+-green)](https://www.python.org/)
[![React](https://img.shields.io/badge/React-18.2-blue)](https://reactjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-teal)](https://fastapi.tiangolo.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## 📋 Índice

- [Sobre](#sobre)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Instalação](#instalação)
- [Uso](#uso)
- [API](#api)
- [Frontend](#frontend)
- [Testes](#testes)
- [Deploy](#deploy)
- [Contribuição](#contribuição)
- [Licença](#licença)

---

## 🎯 Sobre

Sentinela é um sistema completo de gestão e monitoramento de contratos públicos com integração ao Portal Nacional de Contratações Públicas (PNCP).

### Features

- ✅ **Autenticação** - JWT com MFA TOTP obrigatório (ROOT/GESTOR)
- ✅ **Gestão de Fornecedores** - CRUD completo com consulta PNCP
- ✅ **Gestão de Contratos** - Monitoramento e alertas
- ✅ **Dashboard** - Métricas em tempo real
- ✅ **Health Checks** - Monitoramento de sistema e banco
- ✅ **API RESTful** - Documentação Swagger/ReDoc
- ✅ **Frontend React** - Interface moderna e responsiva

---

## 🏗️ Arquitetura
