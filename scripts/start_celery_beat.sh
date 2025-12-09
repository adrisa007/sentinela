#!/bin/bash
echo "📅 Iniciando Celery Beat..."
celery -A app.tasks beat --loglevel=info
