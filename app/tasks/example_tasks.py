from .celery_app import celery_app
from celery.utils.log import get_task_logger

logger = get_task_logger(__name__)

@celery_app.task(name="sentinela.tasks.add")
def add(x: int, y: int) -> int:
    logger.info(f"Executando soma: {x} + {y}")
    return x + y

@celery_app.task(name="sentinela.tasks.process_data")
def process_data(data: dict) -> dict:
    logger.info(f"Processando: {data}")
    return {"status": "processed", "data": data}
