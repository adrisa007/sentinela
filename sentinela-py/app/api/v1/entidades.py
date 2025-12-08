"""
Rotas para gerenciamento de Entidades (órgãos públicos).
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel.ext.asyncio.session import AsyncSession

from app.core.dependencies import get_db, get_current_user


router = APIRouter()


@router.get("/")
async def list_entidades(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Lista todas as entidades (órgãos públicos) cadastradas.
    
    Filtros disponíveis:
    - cnpj
    - nome
    - uf
    - ativo
    
    TODO: Implementar busca no banco de dados com filtros e paginação.
    """
    return {"entidades": [], "total": 0}


@router.post("/")
async def create_entidade(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Cria uma nova entidade no sistema.
    
    Campos obrigatórios:
    - cnpj (único)
    - nome
    - tipo_entidade (municipal, estadual, federal)
    - uf
    
    TODO: Implementar validação de CNPJ e criação no banco.
    """
    return {"message": "Entidade criada com sucesso", "id": "uuid-aqui"}


@router.get("/{entidade_id}")
async def get_entidade(
    entidade_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Obtém detalhes de uma entidade específica.
    
    TODO: Implementar busca por ID no banco.
    """
    return {"id": entidade_id, "nome": "Entidade Exemplo"}


@router.put("/{entidade_id}")
async def update_entidade(
    entidade_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Atualiza dados de uma entidade.
    
    TODO: Implementar atualização com validação de permissões.
    """
    return {"message": "Entidade atualizada com sucesso"}


@router.delete("/{entidade_id}")
async def delete_entidade(
    entidade_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Desativa uma entidade (soft delete).
    
    TODO: Implementar soft delete mantendo histórico.
    """
    return {"message": "Entidade desativada com sucesso"}
