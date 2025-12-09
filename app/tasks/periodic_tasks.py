from .celery_app import celery_app
from celery.utils.log import get_task_logger
from datetime import datetime

logger = get_task_logger(__name__)

@celery_app.task(name="sentinela.periodic.health_check")
def periodic_health_check():
    logger.info("Health check periódico")
    return {"timestamp": datetime.utcnow().isoformat(), "status": "healthy"}

@celery_app.task(name="sentinela.periodic.cleanup")
def cleanup_old_tasks():
    logger.info("Limpeza de tasks antigas")
    return {"deleted": 0}

@celery_app.task(name="sentinela.periodic.report")
def generate_daily_report():
    logger.info("Gerando relatório")
    return {"date": datetime.utcnow().date().isoformat()}
