# Scripts de Desenvolvimento

Este diretório contém scripts úteis para desenvolvimento e operação do projeto Sentinela.

## 🐳 Docker

### `docker-start.sh`
Inicia todos os serviços em containers Docker (PostgreSQL, Redis, aplicação)
```bash
./scripts/docker-start.sh
```

### `docker-stop.sh`
Para e remove todos os containers Docker
```bash
./scripts/docker-stop.sh
```

## 🔧 Instalação e Configuração

### `install_dependencies.sh`
Instala todas as dependências Python do projeto
```bash
./scripts/install_dependencies.sh
```

## 🧪 Testes

### `run_tests.sh`
Executa a suite completa de testes com pytest
```bash
./scripts/run_tests.sh
```

## ⚙️ Serviços

### `start-services.sh`
Inicia todos os serviços necessários (aplicação, Celery worker e beat)
```bash
./scripts/start-services.sh
```

### `start_celery_worker.sh`
Inicia apenas o Celery worker
```bash
./scripts/start_celery_worker.sh
```

### `start_celery_beat.sh`
Inicia apenas o Celery beat scheduler
```bash
./scripts/start_celery_beat.sh
```

## 🏥 Health Check

### `healthcheck.py`
Script Python para verificar a saúde da aplicação
```bash
python scripts/healthcheck.py
```

## 📝 Notas

- Todos os scripts shell devem ser executados a partir do diretório raiz do projeto
- Certifique-se de ter permissões de execução: `chmod +x scripts/*.sh`
- Configure as variáveis de ambiente em `.env` antes de executar os scripts
