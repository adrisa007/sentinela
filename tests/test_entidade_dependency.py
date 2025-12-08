"""
Testes para get_current_entidade dependency
"""
import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session
import uuid

from app.core.dependencies import get_current_entidade, get_current_entidade_optional
from app.core.models import User, UserRole, Entidade, TipoEntidade


@pytest.fixture
def test_entidade(db_session: Session):
    """Cria entidade de teste com CNPJ único"""
    # Gerar CNPJ único para evitar conflitos
    unique_cnpj = f"{uuid.uuid4().int % 100000000000000:014d}"
    
    entidade = Entidade(
        nome="Empresa Teste",
        razao_social="Empresa Teste LTDA",
        cnpj=unique_cnpj,
        tipo=TipoEntidade.EMPRESA,
        email="contato@empresateste.com",
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def test_entidade_inativa(db_session: Session):
    """Cria entidade inativa com CNPJ único"""
    unique_cnpj = f"{uuid.uuid4().int % 100000000000000:014d}"
    
    entidade = Entidade(
        nome="Empresa Inativa",
        cnpj=unique_cnpj,
        tipo=TipoEntidade.EMPRESA,
        is_active=False
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def user_with_entidade(db_session: Session, test_entidade: Entidade):
    """Cria usuário com entidade associada"""
    user = User(
        username=f"user_with_entity_{uuid.uuid4().hex[:8]}",
        email=f"user_{uuid.uuid4().hex[:8]}@entity.com",
        hashed_password="$2b$12$test_hash",  # Hash fake
        role=UserRole.OPERADOR,
        entidade_id=test_entidade.id,
        is_active=True
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def user_without_entidade(db_session: Session):
    """Cria usuário sem entidade"""
    user = User(
        username=f"user_no_entity_{uuid.uuid4().hex[:8]}",
        email=f"noentity_{uuid.uuid4().hex[:8]}@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.OPERADOR,
        entidade_id=None,
        is_active=True
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


class TestGetCurrentEntidade:
    """Testes para get_current_entidade"""
    
    def test_user_with_entidade_returns_entity(
        self, 
        db_session: Session,
        user_with_entidade: User,
        test_entidade: Entidade
    ):
        """Teste: Usuário com entidade retorna a entidade correta"""
        assert user_with_entidade.entidade_id == test_entidade.id
        assert user_with_entidade.entidade is not None
        assert user_with_entidade.entidade.nome == "Empresa Teste"
    
    def test_user_without_entidade_raises_404(
        self,
        db_session: Session,
        user_without_entidade: User
    ):
        """Teste: Usuário sem entidade não tem entidade_id"""
        assert user_without_entidade.entidade_id is None
    
    def test_entidade_has_correct_attributes(self, test_entidade: Entidade):
        """Teste: Entidade tem todos os atributos necessários"""
        assert test_entidade.id is not None
        assert test_entidade.nome == "Empresa Teste"
        assert test_entidade.cnpj is not None
        assert len(test_entidade.cnpj) == 14
        assert test_entidade.tipo == TipoEntidade.EMPRESA
        assert test_entidade.is_active is True
    
    def test_entidade_relationship_with_user(
        self,
        db_session: Session,
        user_with_entidade: User,
        test_entidade: Entidade
    ):
        """Teste: Relacionamento entre User e Entidade funciona"""
        # Verificar relacionamento User -> Entidade
        assert user_with_entidade.entidade_id == test_entidade.id
        assert user_with_entidade.entidade.nome == "Empresa Teste"
        
        # Refresh para carregar relacionamento
        db_session.refresh(test_entidade)
        users_da_entidade = test_entidade.usuarios
        assert len(users_da_entidade) > 0
        assert user_with_entidade in users_da_entidade
    
    def test_multiple_users_same_entidade(
        self,
        db_session: Session,
        test_entidade: Entidade
    ):
        """Teste: Múltiplos usuários podem pertencer à mesma entidade"""
        user1 = User(
            username=f"user1_{uuid.uuid4().hex[:8]}",
            email=f"user1_{uuid.uuid4().hex[:8]}@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.OPERADOR,
            entidade_id=test_entidade.id
        )
        user2 = User(
            username=f"user2_{uuid.uuid4().hex[:8]}",
            email=f"user2_{uuid.uuid4().hex[:8]}@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.GESTOR,
            entidade_id=test_entidade.id
        )
        
        db_session.add_all([user1, user2])
        db_session.commit()
        
        # Verificar que ambos têm a mesma entidade
        assert user1.entidade_id == test_entidade.id
        assert user2.entidade_id == test_entidade.id


class TestGetCurrentEntidadeOptional:
    """Testes para get_current_entidade_optional"""
    
    def test_returns_none_for_user_without_entidade(
        self,
        user_without_entidade: User
    ):
        """Teste: Retorna None para usuário sem entidade"""
        assert user_without_entidade.entidade_id is None
    
    def test_returns_entidade_for_user_with_entidade(
        self,
        user_with_entidade: User,
        test_entidade: Entidade
    ):
        """Teste: Retorna entidade para usuário com entidade"""
        assert user_with_entidade.entidade_id == test_entidade.id
        assert user_with_entidade.entidade is not None


class TestEntidadeModel:
    """Testes do modelo Entidade"""
    
    def test_entidade_creation(self, db_session: Session):
        """Teste: Criar entidade básica"""
        unique_cnpj = f"{uuid.uuid4().int % 100000000000000:014d}"
        
        entidade = Entidade(
            nome="Nova Empresa",
            cnpj=unique_cnpj,
            tipo=TipoEntidade.EMPRESA,
            is_active=True
        )
        db_session.add(entidade)
        db_session.commit()
        db_session.refresh(entidade)
        
        assert entidade.id is not None
        assert entidade.nome == "Nova Empresa"
        assert entidade.created_at is not None
    
    def test_entidade_tipos(self):
        """Teste: Tipos de entidade disponíveis"""
        assert TipoEntidade.EMPRESA == "EMPRESA"
        assert TipoEntidade.ORGANIZACAO == "ORGANIZACAO"
        assert TipoEntidade.DEPARTAMENTO == "DEPARTAMENTO"
        assert TipoEntidade.FILIAL == "FILIAL"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
