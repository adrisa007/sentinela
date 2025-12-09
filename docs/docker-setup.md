
### Iniciar todos os serviços
```bash
docker-compose up -d
```

### Ver logs
```bash
docker-compose logs -f redis
```

### Parar serviços
```bash
docker-compose -f docker-compose.dev.yml down
```

## Testar Redis
```bash
docker exec sentinela-redis-dev redis-cli ping
curl http://localhost:8000/health/live
```

