"""
Testes para require_active_entidade dependency
"""
import pytest
from fastapi import HTTPException, Depends
from sqlalchemy.orm import Session
import uuid

from app.core.dependencies import require_active_entidade, require_entidade_status
from app.core.models import User, UserRole, Entidade, TipoEntidade, StatusEntidade


@pytest.fixture
def entidade_ativa(db_session: Session):
    """Cria entidade com status ATIVA"""
    entidade = Entidade(
        nome="Entidade Ativa",
        cnpj=f"{uuid.uuid4().int % 100000000000000:014d}",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.ATIVA,
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def entidade_inativa(db_session: Session):
    """Cria entidade com status INATIVA"""
    entidade = Entidade(
        nome="Entidade Inativa",
        cnpj=f"{uuid.uuid4().int % 100000000000000:014d}",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.INATIVA,
        is_active=False,
        motivo_status="Desativada temporariamente"
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def entidade_suspensa(db_session: Session):
    """Cria entidade com status SUSPENSA"""
    entidade = Entidade(
        nome="Entidade Suspensa",
        cnpj=f"{uuid.uuid4().int % 100000000000000:014d}",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.SUSPENSA,
        is_active=False,
        motivo_status="Inadimplência"
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def entidade_bloqueada(db_session: Session):
    """Cria entidade com status BLOQUEADA"""
    entidade = Entidade(
        nome="Entidade Bloqueada",
        cnpj=f"{uuid.uuid4().int % 100000000000000:014d}",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.BLOQUEADA,
        is_active=False,
        motivo_status="Violação de termos"
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def entidade_em_analise(db_session: Session):
    """Cria entidade com status EM_ANALISE"""
    entidade = Entidade(
        nome="Entidade Em Análise",
        cnpj=f"{uuid.uuid4().int % 100000000000000:014d}",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.EM_ANALISE,
        is_active=False
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


class TestRequireActiveEntidade:
    """Testes para require_active_entidade"""
    
    def test_entidade_ativa_allows_access(self, entidade_ativa: Entidade):
        """Teste: Entidade ATIVA permite acesso"""
        assert entidade_ativa.status == StatusEntidade.ATIVA
        assert entidade_ativa.is_ativa is True
    
    def test_entidade_inativa_denies_access(self, entidade_inativa: Entidade):
        """Teste: Entidade INATIVA nega acesso"""
        assert entidade_inativa.status == StatusEntidade.INATIVA
        assert entidade_inativa.is_ativa is False
    
    def test_entidade_suspensa_denies_access(self, entidade_suspensa: Entidade):
        """Teste: Entidade SUSPENSA nega acesso"""
        assert entidade_suspensa.status == StatusEntidade.SUSPENSA
        assert entidade_suspensa.is_ativa is False
        assert "Inadimplência" in entidade_suspensa.motivo_status
    
    def test_entidade_bloqueada_denies_access(self, entidade_bloqueada: Entidade):
        """Teste: Entidade BLOQUEADA nega acesso"""
        assert entidade_bloqueada.status == StatusEntidade.BLOQUEADA
        assert entidade_bloqueada.is_ativa is False
    
    def test_entidade_em_analise_denies_access(self, entidade_em_analise: Entidade):
        """Teste: Entidade EM_ANALISE nega acesso por padrão"""
        assert entidade_em_analise.status == StatusEntidade.EM_ANALISE
        assert entidade_em_analise.is_ativa is False
    
    def test_entidade_is_acessivel_property(
        self, 
        entidade_ativa: Entidade,
        entidade_em_analise: Entidade,
        entidade_inativa: Entidade
    ):
        """Teste: Propriedade is_acessivel"""
        assert entidade_ativa.is_acessivel is True  # ATIVA
        assert entidade_em_analise.is_acessivel is True  # EM_ANALISE
        assert entidade_inativa.is_acessivel is False  # INATIVA


class TestStatusEntidadeEnum:
    """Testes do Enum StatusEntidade"""
    
    def test_all_status_values(self):
        """Teste: Todos os valores de status disponíveis"""
        assert StatusEntidade.ATIVA == "ATIVA"
        assert StatusEntidade.INATIVA == "INATIVA"
        assert StatusEntidade.SUSPENSA == "SUSPENSA"
        assert StatusEntidade.BLOQUEADA == "BLOQUEADA"
        assert StatusEntidade.EM_ANALISE == "EM_ANALISE"
    
    def test_status_count(self):
        """Teste: Número total de status"""
        all_statuses = list(StatusEntidade)
        assert len(all_statuses) == 5


class TestEntidadeStatusTransitions:
    """Testes de transições de status"""
    
    def test_change_status_from_ativa_to_inativa(
        self, 
        db_session: Session,
        entidade_ativa: Entidade
    ):
        """Teste: Mudar status de ATIVA para INATIVA"""
        assert entidade_ativa.status == StatusEntidade.ATIVA
        
        # Mudar status
        entidade_ativa.status = StatusEntidade.INATIVA
        entidade_ativa.motivo_status = "Manutenção programada"
        db_session.commit()
        
        assert entidade_ativa.status == StatusEntidade.INATIVA
        assert entidade_ativa.motivo_status == "Manutenção programada"
    
    def test_reactivate_inactive_entidade(
        self,
        db_session: Session,
        entidade_inativa: Entidade
    ):
        """Teste: Reativar entidade inativa"""
        assert entidade_inativa.status == StatusEntidade.INATIVA
        
        # Reativar
        entidade_inativa.status = StatusEntidade.ATIVA
        entidade_inativa.motivo_status = "Reativação após manutenção"
        db_session.commit()
        
        assert entidade_inativa.status == StatusEntidade.ATIVA
        assert entidade_inativa.is_ativa is True


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
