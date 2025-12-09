#!/bin/bash
echo "⚙️  Iniciando Celery Worker..."
celery -A app.tasks worker --loglevel=info --concurrency=2
