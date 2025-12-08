#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🛡️  Iniciando Sentinela...${NC}"
echo ""

# Verifica se o ambiente virtual existe
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}⚠️  Ambiente virtual não encontrado!${NC}"
    echo "Execute primeiro: ./install-chromeos.sh"
    exit 1
fi

# Ativa ambiente virtual
source venv/bin/activate

# Verifica se o banco de dados existe
if [ ! -f "sentinela.db" ]; then
    echo -e "${BLUE}🗄️  Criando banco de dados...${NC}"
fi

# Obtém o hostname do Codespace
if [ ! -z "$CODESPACE_NAME" ]; then
    CODESPACE_URL="https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    echo -e "${GREEN}🌐 Rodando no GitHub Codespace${NC}"
    echo -e "${GREEN}📚 Documentação: ${CODESPACE_URL}/docs${NC}"
else
    echo -e "${GREEN}📚 Documentação: http://localhost:8000/docs${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Iniciando servidor...${NC}"
echo -e "${YELLOW}💡 Pressione Ctrl+C para parar${NC}"
echo ""

# Inicia o servidor
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000