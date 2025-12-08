"""
Worker Celery para execução de tarefas assíncronas.
Execução: celery -A celery_worker.celery_app worker --loglevel=info
"""

from app.tasks.celery_app import celery_app

# Importar todas as tasks para registro
from app.tasks.celery_app import (
    example_task,
    send_notification,
    sincronizar_pncp_entidade,
    sincronizar_pncp_todas_entidades,
    verificar_contratos_vencendo,
    recalcular_scores_risco,
    realizar_backup_s3,
    atualizar_dados_receita,
    atualizar_dados_receita_todos,
)

if __name__ == "__main__":
    celery_app.start()
