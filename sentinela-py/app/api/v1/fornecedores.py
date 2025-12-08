"""
Rotas para gerenciamento de Fornecedores.
"""

from fastapi import APIRouter, Depends, Query
from sqlmodel.ext.asyncio.session import AsyncSession

from app.core.dependencies import get_db, get_current_user


router = APIRouter()


@router.get("/")
async def list_fornecedores(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=500),
    cnpj: str | None = None,
    nome: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Lista fornecedores cadastrados.
    
    Filtros disponíveis:
    - cnpj (busca exata)
    - nome (busca parcial)
    - situacao_receita
    - ativo
    
    Suporta paginação via skip/limit.
    
    TODO: Implementar busca com filtros e joins necessários.
    """
    return {"fornecedores": [], "total": 0, "skip": skip, "limit": limit}


@router.post("/")
async def create_fornecedor(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Cadastra novo fornecedor.
    
    Campos principais:
    - cnpj (único)
    - razao_social
    - nome_fantasia
    - situacao_receita
    
    TODO: Implementar validação de CNPJ e integração com API da Receita.
    """
    return {"message": "Fornecedor criado com sucesso", "id": "uuid-aqui"}


@router.get("/{fornecedor_id}")
async def get_fornecedor(
    fornecedor_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Obtém detalhes completos de um fornecedor.
    
    Inclui:
    - Dados cadastrais
    - Situação na Receita Federal
    - Histórico de contratos
    - Alertas e score de risco
    
    TODO: Implementar busca com relacionamentos.
    """
    return {"id": fornecedor_id, "razao_social": "Fornecedor Exemplo LTDA"}


@router.put("/{fornecedor_id}")
async def update_fornecedor(
    fornecedor_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Atualiza dados do fornecedor.
    
    TODO: Implementar atualização com auditoria.
    """
    return {"message": "Fornecedor atualizado com sucesso"}


@router.get("/{fornecedor_id}/contratos")
async def get_fornecedor_contratos(
    fornecedor_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Lista todos os contratos de um fornecedor específico.
    
    TODO: Implementar busca de contratos por fornecedor_id.
    """
    return {"contratos": [], "total": 0}


@router.post("/{fornecedor_id}/atualizar-receita")
async def atualizar_dados_receita(
    fornecedor_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Atualiza dados do fornecedor consultando API da Receita Federal.
    
    TODO: Implementar integração com API da Receita e task Celery.
    """
    return {"message": "Atualização agendada via Celery"}
