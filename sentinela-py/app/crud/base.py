"""
CRUD base genérico para operações comuns de banco de dados.
Reutilizável para todos os modelos SQLModel.
"""

from typing import Generic, TypeVar, Type, Optional, List, Any
from sqlmodel import SQLModel, select
from sqlmodel.ext.asyncio.session import AsyncSession
from fastapi import HTTPException, status


ModelType = TypeVar("ModelType", bound=SQLModel)


class CRUDBase(Generic[ModelType]):
    """
    Classe base para operações CRUD genéricas.
    
    Uso:
        class EntidadeCRUD(CRUDBase[Entidade]):
            pass
        
        entidade_crud = EntidadeCRUD(Entidade)
    """
    
    def __init__(self, model: Type[ModelType]):
        """
        Args:
            model: Modelo SQLModel para operações CRUD
        """
        self.model = model
    
    async def get(self, db: AsyncSession, id: str) -> Optional[ModelType]:
        """
        Busca um registro por ID.
        
        Args:
            db: Sessão do banco de dados
            id: ID do registro
            
        Returns:
            Registro encontrado ou None
        """
        result = await db.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()
    
    async def get_or_404(self, db: AsyncSession, id: str) -> ModelType:
        """
        Busca um registro por ID ou retorna 404.
        
        Args:
            db: Sessão do banco de dados
            id: ID do registro
            
        Returns:
            Registro encontrado
            
        Raises:
            HTTPException: 404 se não encontrado
        """
        obj = await self.get(db, id)
        if not obj:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"{self.model.__name__} não encontrado"
            )
        return obj
    
    async def get_multi(
        self,
        db: AsyncSession,
        *,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[dict] = None
    ) -> List[ModelType]:
        """
        Busca múltiplos registros com paginação e filtros.
        
        Args:
            db: Sessão do banco de dados
            skip: Número de registros a pular
            limit: Número máximo de registros a retornar
            filters: Dicionário com filtros adicionais
            
        Returns:
            Lista de registros
        """
        query = select(self.model).offset(skip).limit(limit)
        
        # Aplicar filtros se fornecidos
        if filters:
            for field, value in filters.items():
                if hasattr(self.model, field) and value is not None:
                    query = query.where(getattr(self.model, field) == value)
        
        result = await db.execute(query)
        return result.scalars().all()
    
    async def create(
        self,
        db: AsyncSession,
        *,
        obj_in: dict | SQLModel
    ) -> ModelType:
        """
        Cria um novo registro.
        
        Args:
            db: Sessão do banco de dados
            obj_in: Dados para criar o registro (dict ou SQLModel)
            
        Returns:
            Registro criado
        """
        if isinstance(obj_in, dict):
            db_obj = self.model(**obj_in)
        else:
            db_obj = self.model.model_validate(obj_in)
        
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj
    
    async def update(
        self,
        db: AsyncSession,
        *,
        db_obj: ModelType,
        obj_in: dict | SQLModel
    ) -> ModelType:
        """
        Atualiza um registro existente.
        
        Args:
            db: Sessão do banco de dados
            db_obj: Registro existente a ser atualizado
            obj_in: Novos dados (apenas campos não-None serão atualizados)
            
        Returns:
            Registro atualizado
        """
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.model_dump(exclude_unset=True)
        
        for field, value in update_data.items():
            if hasattr(db_obj, field) and value is not None:
                setattr(db_obj, field, value)
        
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj
    
    async def delete(self, db: AsyncSession, *, id: str) -> ModelType:
        """
        Remove um registro (hard delete).
        
        Args:
            db: Sessão do banco de dados
            id: ID do registro a ser removido
            
        Returns:
            Registro removido
        """
        obj = await self.get_or_404(db, id)
        await db.delete(obj)
        await db.commit()
        return obj
    
    async def soft_delete(self, db: AsyncSession, *, id: str) -> ModelType:
        """
        Desativa um registro (soft delete).
        Apenas para modelos que possuem campo 'ativo'.
        
        Args:
            db: Sessão do banco de dados
            id: ID do registro
            
        Returns:
            Registro desativado
        """
        obj = await self.get_or_404(db, id)
        
        if not hasattr(obj, 'ativo'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{self.model.__name__} não suporta soft delete"
            )
        
        setattr(obj, 'ativo', False)
        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj
    
    async def count(self, db: AsyncSession, filters: Optional[dict] = None) -> int:
        """
        Conta o total de registros.
        
        Args:
            db: Sessão do banco de dados
            filters: Filtros opcionais
            
        Returns:
            Total de registros
        """
        query = select(self.model)
        
        if filters:
            for field, value in filters.items():
                if hasattr(self.model, field) and value is not None:
                    query = query.where(getattr(self.model, field) == value)
        
        result = await db.execute(query)
        return len(result.scalars().all())
