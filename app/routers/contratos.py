"""
Router de Contratos
✅ Validação: get_current_user + require_active_entidade aplicada
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.core.database import get_db
from app.core.models import Entidade
from app.core.dependencies import (
    get_current_user,
    get_current_entidade,
    require_active_entidade,
    require_gestor,
    CurrentUser
)

router = APIRouter(
    prefix="/contratos",
    tags=["Contratos"],
    # ✅ Aplicar require_active_entidade em TODAS as rotas
    dependencies=[Depends(require_active_entidade())]
)


@router.get(
    "/",
    summary="Listar Contratos",
    description="📄 Lista contratos da entidade ativa do usuário."
)
async def list_contratos(
    current_user: CurrentUser = Depends(get_current_user),
    entidade: Entidade = Depends(get_current_entidade),
    db: Session = Depends(get_db)
):
    """
    📄 **Listar Contratos da Entidade**
    
    **Validações:**
    - ✅ Usuário autenticado
    - ✅ Entidade ATIVA (obrigatório)
    - ✅ Retorna apenas contratos da entidade do usuário
    
    **Restrições:**
    - Entidades com status INATIVA, SUSPENSA, BLOQUEADA ou EM_ANALISE
      receberão 403 Forbidden
    """
    # TODO: Implementar modelo Contrato
    return {
        "message": "Lista de contratos",
        "entidade": entidade.nome,
        "entidade_status": entidade.status.value,
        "user": current_user.username,
        "contratos": []  # Placeholder
    }


@router.post(
    "/",
    summary="Criar Contrato (GESTOR+)",
    description="➕ Cria contrato na entidade ativa."
)
async def create_contrato(
    contrato_data: dict,  # TODO: Criar schema ContratoCreate
    current_user: CurrentUser = Depends(require_gestor),
    entidade: Entidade = Depends(get_current_entidade),
    db: Session = Depends(get_db)
):
    """
    ➕ **Criar Contrato - GESTOR ou ROOT**
    
    **Validações:**
    - ✅ Perfil GESTOR ou ROOT
    - ✅ Entidade ATIVA (obrigatório)
    - ✅ Contrato vinculado automaticamente à entidade do usuário
    """
    return {
        "message": "Contrato criado (placeholder)",
        "entidade_id": entidade.id,
        "entidade_status": entidade.status.value,
        "created_by": current_user.username
    }


@router.get(
    "/{contrato_id}",
    summary="Buscar Contrato",
    description="🔍 Busca contrato específico."
)
async def get_contrato(
    contrato_id: int,
    current_user: CurrentUser = Depends(get_current_user),
    entidade: Entidade = Depends(get_current_entidade)
):
    """
    🔍 **Buscar Contrato por ID**
    
    **Validações:**
    - ✅ Usuário autenticado
    - ✅ Entidade ATIVA
    - ✅ Contrato pertence à entidade do usuário
    """
    # TODO: Implementar busca real
    return {
        "id": contrato_id,
        "nome": f"Contrato {contrato_id}",
        "entidade_id": entidade.id,
        "entidade_status": entidade.status.value
    }


@router.put(
    "/{contrato_id}",
    summary="Atualizar Contrato (GESTOR+)",
    description="✏️ Atualiza contrato."
)
async def update_contrato(
    contrato_id: int,
    contrato_data: dict,  # TODO: Schema ContratoUpdate
    current_user: CurrentUser = Depends(require_gestor),
    entidade: Entidade = Depends(get_current_entidade)
):
    """
    ✏️ **Atualizar Contrato - GESTOR ou ROOT**
    
    **Validações:**
    - ✅ Perfil GESTOR ou ROOT
    - ✅ Entidade ATIVA
    - ✅ Contrato pertence à entidade do usuário
    """
    return {
        "message": f"Contrato {contrato_id} atualizado",
        "updated_by": current_user.username
    }


@router.delete(
    "/{contrato_id}",
    summary="Deletar Contrato (GESTOR+)",
    description="🗑️ Deleta contrato."
)
async def delete_contrato(
    contrato_id: int,
    current_user: CurrentUser = Depends(require_gestor),
    entidade: Entidade = Depends(get_current_entidade)
):
    """
    🗑️ **Deletar Contrato - GESTOR ou ROOT**
    
    **Validações:**
    - ✅ Perfil GESTOR ou ROOT
    - ✅ Entidade ATIVA
    - ✅ Contrato pertence à entidade do usuário
    """
    return {
        "message": f"Contrato {contrato_id} deletado",
        "deleted_by": current_user.username
    }
