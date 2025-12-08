#!/bin/bash

echo "🛡️  Instalando Sentinela no ChromeOS..."
echo "========================================="

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verifica se está no diretório correto
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}❌ Erro: requirements.txt não encontrado!${NC}"
    echo "Execute este script no diretório raiz do projeto."
    exit 1
fi

# Remove ambiente virtual anterior se existir
if [ -d "venv" ]; then
    echo -e "${BLUE}🗑️  Removendo ambiente virtual anterior...${NC}"
    rm -rf venv
fi

# Cria ambiente virtual
echo -e "${BLUE}📦 Criando ambiente virtual...${NC}"
python3 -m venv venv

# Ativa ambiente virtual
echo -e "${BLUE}⚡ Ativando ambiente virtual...${NC}"
source venv/bin/activate

# Atualiza pip
echo -e "${BLUE}🔄 Atualizando pip...${NC}"
pip install --upgrade pip setuptools wheel

# Instala dependências
echo -e "${BLUE}📚 Instalando dependências...${NC}"
pip install -r requirements.txt

# Verifica se .env existe
if [ ! -f ".env" ]; then
    echo -e "${BLUE}📝 Criando arquivo .env...${NC}"
    cat > .env << 'EOF'
# JWT Configuration
JWT_SECRET_KEY=sentinela-super-secret-key-change-in-production-min-32-characters-long
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# Database
DATABASE_URL=sqlite:///./sentinela.db

# App
APP_NAME=Sentinela
DEBUG=True
EOF
    echo -e "${GREEN}✅ Arquivo .env criado!${NC}"
else
    echo -e "${GREEN}✅ Arquivo .env já existe!${NC}"
fi

# Cria diretórios necessários
echo -e "${BLUE}📁 Criando estrutura de diretórios...${NC}"
mkdir -p logs
mkdir -p backups

# Testa a instalação
echo -e "${BLUE}🧪 Testando instalação...${NC}"
python3 -c "import fastapi, uvicorn, sqlalchemy, jose, passlib, pyotp" && \
    echo -e "${GREEN}✅ Todas as dependências instaladas com sucesso!${NC}" || \
    echo -e "${RED}❌ Erro ao importar dependências!${NC}"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}Para iniciar o servidor:${NC}"
echo -e "  ${GREEN}source venv/bin/activate${NC}"
echo -e "  ${GREEN}python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000${NC}"
echo ""
echo -e "${BLUE}Ou use o script de execução:${NC}"
echo -e "  ${GREEN}./run-chromeos.sh${NC}"
echo ""