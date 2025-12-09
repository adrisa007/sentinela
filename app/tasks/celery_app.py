from celery import Celery
from celery.schedules import crontab
import os

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = os.getenv("REDIS_PORT", "6379")
REDIS_DB = os.getenv("CELERY_REDIS_DB", "1")

CELERY_BROKER_URL = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}"

celery_app = Celery("sentinela", broker=CELERY_BROKER_URL, backend=CELERY_BROKER_URL)

celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='America/Sao_Paulo',
    enable_utc=True,
)

celery_app.conf.beat_schedule = {
    'health-check-5min': {
        'task': 'sentinela.periodic.health_check',
        'schedule': 300.0,
    },
    'cleanup-2am': {
        'task': 'sentinela.periodic.cleanup',
        'schedule': crontab(hour=2, minute=0),
    },
    'report-8am': {
        'task': 'sentinela.periodic.report',
        'schedule': crontab(hour=8, minute=0),
    },
}
