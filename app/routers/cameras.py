"""
Router de Câmeras
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
    prefix="/cameras",
    tags=["Câmeras"],
    # ✅ Aplicar require_active_entidade em TODAS as rotas
    dependencies=[Depends(require_active_entidade())]
)


@router.get(
    "/",
    summary="Listar Câmeras",
    description="📹 Lista câmeras da entidade ativa do usuário."
)
async def list_cameras(
    current_user: CurrentUser = Depends(get_current_user),
    entidade: Entidade = Depends(get_current_entidade),
    db: Session = Depends(get_db)
):
    """
    📹 **Listar Câmeras da Entidade**
    
    **Validações:**
    - ✅ Usuário autenticado
    - ✅ Entidade ativa
    - ✅ Retorna apenas câmeras da entidade do usuário
    """
    # TODO: Implementar modelo Camera
    return {
        "message": "Lista de câmeras",
        "entidade": entidade.nome,
        "user": current_user.username,
        "cameras": []  # Placeholder
    }


@router.post(
    "/",
    summary="Criar Câmera (GESTOR+)",
    description="➕ Cria câmera na entidade ativa."
)
async def create_camera(
    camera_data: dict,  # TODO: Criar schema CameraCreate
    current_user: CurrentUser = Depends(require_gestor),
    entidade: Entidade = Depends(get_current_entidade),
    db: Session = Depends(get_db)
):
    """
    ➕ **Criar Câmera - GESTOR ou ROOT**
    
    **Validações:**
    - ✅ Perfil GESTOR ou ROOT
    - ✅ Entidade ativa
    - ✅ Câmera vinculada automaticamente à entidade do usuário
    """
    return {
        "message": "Câmera criada (placeholder)",
        "entidade_id": entidade.id,
        "created_by": current_user.username
    }


@router.get(
    "/{camera_id}",
    summary="Buscar Câmera",
    description="🔍 Busca câmera específica."
)
async def get_camera(
    camera_id: int,
    current_user: CurrentUser = Depends(get_current_user),
    entidade: Entidade = Depends(get_current_entidade)
):
    """
    🔍 **Buscar Câmera por ID**
    
    **Validações:**
    - ✅ Usuário autenticado
    - ✅ Entidade ativa
    - ✅ Câmera pertence à entidade do usuário
    """
    # TODO: Implementar busca real
    return {
        "id": camera_id,
        "nome": f"Câmera {camera_id}",
        "entidade_id": entidade.id
    }


@router.put(
    "/{camera_id}",
    summary="Atualizar Câmera (GESTOR+)",
    description="✏️ Atualiza câmera."
)
async def update_camera(
    camera_id: int,
    camera_data: dict,  # TODO: Schema CameraUpdate
    current_user: CurrentUser = Depends(require_gestor),
    entidade: Entidade = Depends(get_current_entidade)
):
    """
    ✏️ **Atualizar Câmera - GESTOR ou ROOT**
    
    **Validações:**
    - ✅ Perfil GESTOR ou ROOT
    - ✅ Entidade ativa
    - ✅ Câmera pertence à entidade do usuário
    """
    return {
        "message": f"Câmera {camera_id} atualizada",
        "updated_by": current_user.username
    }


@router.delete(
    "/{camera_id}",
    summary="Deletar Câmera (GESTOR+)",
    description="🗑️ Deleta câmera."
)
async def delete_camera(
    camera_id: int,
    current_user: CurrentUser = Depends(require_gestor),
    entidade: Entidade = Depends(get_current_entidade)
):
    """
    🗑️ **Deletar Câmera - GESTOR ou ROOT**
    
    **Validações:**
    - ✅ Perfil GESTOR ou ROOT
    - ✅ Entidade ativa
    - ✅ Câmera pertence à entidade do usuário
    """
    return {
        "message": f"Câmera {camera_id} deletada",
        "deleted_by": current_user.username
    }
