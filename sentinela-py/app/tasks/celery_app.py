"""
Configuração do Celery para tarefas assíncronas.
Workers para processamento em background de:
- Sincronização com PNCP
- Atualização de dados da Receita Federal
- Geração de alertas automáticos
- Backups periódicos no S3
"""

from celery import Celery
from celery.schedules import crontab

from app.core.config import settings


# Inicializar Celery
celery_app = Celery(
    "sentinela",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=["app.tasks.pncp_tasks", "app.tasks.alerta_tasks", "app.tasks.backup_tasks"]
)

# Configurações do Celery
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="America/Sao_Paulo",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutos
    task_soft_time_limit=25 * 60,  # 25 minutos
    worker_prefetch_multiplier=1,
    worker_max_tasks_per_child=1000,
)

# Configurar tarefas periódicas (Celery Beat)
celery_app.conf.beat_schedule = {
    # Sincronizar PNCP diariamente às 2h da manhã
    "sync-pncp-diario": {
        "task": "app.tasks.pncp_tasks.sincronizar_pncp_todas_entidades",
        "schedule": crontab(hour=2, minute=0),
    },
    
    # Verificar vencimentos de contratos diariamente às 8h
    "verificar-vencimentos": {
        "task": "app.tasks.alerta_tasks.verificar_contratos_vencendo",
        "schedule": crontab(hour=8, minute=0),
    },
    
    # Backup semanal aos domingos às 3h
    "backup-semanal": {
        "task": "app.tasks.backup_tasks.realizar_backup_s3",
        "schedule": crontab(hour=3, minute=0, day_of_week=0),
    },
    
    # Atualizar dados de fornecedores semanalmente
    "atualizar-fornecedores": {
        "task": "app.tasks.fornecedor_tasks.atualizar_dados_receita_todos",
        "schedule": crontab(hour=4, minute=0, day_of_week=1),
    },
    
    # Calcular scores de risco diariamente
    "calcular-scores": {
        "task": "app.tasks.alerta_tasks.recalcular_scores_risco",
        "schedule": crontab(hour=5, minute=0),
    },
}


# ==================== TASKS DE EXEMPLO ====================

@celery_app.task(name="app.tasks.example_task")
def example_task(x: int, y: int) -> int:
    """
    Exemplo de task simples.
    
    Uso:
        from app.tasks.celery_app import example_task
        result = example_task.delay(10, 20)
        print(result.get())  # 30
    """
    return x + y


@celery_app.task(name="app.tasks.send_notification")
def send_notification(user_id: str, mensagem: str):
    """
    Envia notificação para um usuário.
    
    TODO: Implementar envio real de notificação (email, push, etc.)
    """
    print(f"Enviando notificação para {user_id}: {mensagem}")
    return {"status": "sent", "user_id": user_id}


# ==================== TASKS PNCP ====================
# Criar arquivo separado: app/tasks/pncp_tasks.py

@celery_app.task(name="app.tasks.pncp_tasks.sincronizar_pncp_entidade")
def sincronizar_pncp_entidade(entidade_id: str):
    """
    Sincroniza contratos do PNCP para uma entidade específica.
    
    TODO: Implementar integração real com API PNCP.
    """
    print(f"Sincronizando PNCP para entidade {entidade_id}")
    # 1. Buscar configurações da entidade
    # 2. Chamar API PNCP
    # 3. Processar e salvar contratos
    # 4. Gerar alertas
    return {"entidade_id": entidade_id, "contratos_importados": 0}


@celery_app.task(name="app.tasks.pncp_tasks.sincronizar_pncp_todas_entidades")
def sincronizar_pncp_todas_entidades():
    """
    Sincroniza PNCP para todas as entidades ativas.
    
    Execução: Diariamente via Celery Beat
    """
    print("Iniciando sincronização PNCP para todas as entidades")
    # TODO: Buscar todas entidades ativas e chamar sincronizar_pncp_entidade
    return {"total_entidades": 0, "total_contratos": 0}


# ==================== TASKS ALERTAS ====================

@celery_app.task(name="app.tasks.alerta_tasks.verificar_contratos_vencendo")
def verificar_contratos_vencendo():
    """
    Verifica contratos próximos do vencimento e gera alertas.
    
    Execução: Diariamente às 8h
    """
    print("Verificando contratos próximos do vencimento")
    # TODO: Buscar contratos com data_fim próxima e criar alertas
    return {"alertas_gerados": 0}


@celery_app.task(name="app.tasks.alerta_tasks.recalcular_scores_risco")
def recalcular_scores_risco():
    """
    Recalcula scores de risco de todos os fornecedores usando ML.
    
    Execução: Diariamente às 5h
    """
    print("Recalculando scores de risco")
    # TODO: Implementar modelo ML para calcular scores
    return {"fornecedores_atualizados": 0}


# ==================== TASKS BACKUP ====================

@celery_app.task(name="app.tasks.backup_tasks.realizar_backup_s3")
def realizar_backup_s3():
    """
    Realiza backup completo do banco de dados no S3.
    
    Execução: Semanalmente aos domingos às 3h
    """
    print("Iniciando backup para S3")
    # TODO: Usar script de backup (scripts/backup_s3.py)
    return {"status": "success", "tamanho_bytes": 0}


# ==================== TASKS FORNECEDORES ====================

@celery_app.task(name="app.tasks.fornecedor_tasks.atualizar_dados_receita")
def atualizar_dados_receita(fornecedor_id: str):
    """
    Atualiza dados de um fornecedor consultando API da Receita Federal.
    
    TODO: Implementar integração com API da Receita.
    """
    print(f"Atualizando dados da Receita para fornecedor {fornecedor_id}")
    return {"fornecedor_id": fornecedor_id, "status": "updated"}


@celery_app.task(name="app.tasks.fornecedor_tasks.atualizar_dados_receita_todos")
def atualizar_dados_receita_todos():
    """
    Atualiza dados de todos os fornecedores ativos.
    
    Execução: Semanalmente às segundas-feiras às 4h
    """
    print("Atualizando dados da Receita para todos os fornecedores")
    return {"fornecedores_atualizados": 0}
