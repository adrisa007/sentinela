"""
Rotas para integração com o Portal Nacional de Contratações Públicas (PNCP).
"""

from fastapi import APIRouter, Depends, Query, BackgroundTasks
from sqlmodel.ext.asyncio.session import AsyncSession

from app.core.dependencies import get_db, get_current_user


router = APIRouter()


@router.get("/contratos")
async def buscar_contratos_pncp(
    cnpj: str | None = Query(None, description="CNPJ da entidade ou fornecedor"),
    data_inicial: str | None = Query(None, description="Data inicial (YYYY-MM-DD)"),
    data_final: str | None = Query(None, description="Data final (YYYY-MM-DD)"),
    pagina: int = Query(1, ge=1),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Busca contratos no PNCP (Portal Nacional de Contratações Públicas).
    
    Parâmetros de busca:
    - cnpj: CNPJ da entidade ou fornecedor
    - data_inicial/data_final: Período de publicação
    - pagina: Paginação dos resultados
    
    Retorna dados do PNCP sem salvar no banco local.
    Use /pncp/importar para importar contratos.
    
    TODO: Implementar client HTTP para API do PNCP.
    """
    return {
        "contratos": [],
        "total": 0,
        "pagina": pagina,
        "fonte": "PNCP"
    }


@router.post("/importar")
async def importar_contratos_pncp(
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Importa contratos do PNCP para o banco local.
    
    Fluxo:
    1. Usuário fornece filtros (CNPJ, período, etc.)
    2. Sistema agenda task Celery para importação em background
    3. Task busca contratos no PNCP
    4. Contratos são salvos/atualizados no banco local
    5. Alertas são gerados automaticamente
    
    TODO: Implementar task Celery de importação.
    """
    # background_tasks.add_task(importar_contratos_task, params)
    
    return {
        "message": "Importação agendada com sucesso",
        "status": "processing",
        "task_id": "task-uuid-aqui"
    }


@router.get("/sincronizacao/status")
async def status_sincronizacao(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Verifica status da última sincronização com o PNCP.
    
    Retorna:
    - data_ultima_sync
    - total_contratos_importados
    - total_alertas_gerados
    - status (success, running, failed)
    
    TODO: Implementar tracking de jobs de sincronização.
    """
    return {
        "ultima_sincronizacao": "2024-12-08T10:00:00Z",
        "status": "success",
        "contratos_importados": 150,
        "alertas_gerados": 12
    }


@router.post("/webhook")
async def pncp_webhook(
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint para receber webhooks do PNCP (se disponível no futuro).
    
    Permite sincronização em tempo real quando houver atualizações
    de contratos no portal.
    
    TODO: Implementar validação de assinatura do webhook.
    """
    return {"message": "Webhook recebido"}


@router.get("/entidades")
async def buscar_entidades_pncp(
    uf: str | None = Query(None, max_length=2),
    tipo: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Busca entidades cadastradas no PNCP.
    
    Útil para descobrir CNPJs de órgãos públicos e
    facilitar importação de contratos.
    
    TODO: Implementar busca de entidades via API PNCP.
    """
    return {"entidades": [], "total": 0}
