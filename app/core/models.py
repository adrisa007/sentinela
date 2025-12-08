from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum as SQLEnum, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum
from app.core.database import Base


class UserRole(str, Enum):
    """Roles de usuário no sistema"""
    ROOT = "ROOT"
    GESTOR = "GESTOR"
    OPERADOR = "OPERADOR"


class TipoEntidade(str, Enum):
    """Tipos de entidade"""
    EMPRESA = "EMPRESA"
    ORGANIZACAO = "ORGANIZACAO"
    DEPARTAMENTO = "DEPARTAMENTO"
    FILIAL = "FILIAL"


class StatusEntidade(str, Enum):
    """
    Status possíveis para uma Entidade
    
    - ATIVA: Entidade operacional e acessível
    - INATIVA: Entidade temporariamente desabilitada
    - SUSPENSA: Entidade suspensa por problemas (pagamento, compliance, etc)
    - BLOQUEADA: Entidade bloqueada permanentemente
    - EM_ANALISE: Entidade em processo de análise/aprovação
    """
    ATIVA = "ATIVA"
    INATIVA = "INATIVA"
    SUSPENSA = "SUSPENSA"
    BLOQUEADA = "BLOQUEADA"
    EM_ANALISE = "EM_ANALISE"


class Entidade(Base):
    """
    Modelo de Entidade - Representa empresas, organizações, departamentos, etc.
    """
    __tablename__ = "entidades"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nome = Column(String(200), nullable=False, index=True)
    razao_social = Column(String(255), nullable=True)
    cnpj = Column(String(14), unique=True, nullable=True, index=True)
    tipo = Column(SQLEnum(TipoEntidade), default=TipoEntidade.EMPRESA, nullable=False)
    
    # 🆕 Status da Entidade (substituindo is_active booleano)
    status = Column(
        SQLEnum(StatusEntidade), 
        default=StatusEntidade.ATIVA, 
        nullable=False,
        index=True
    )
    
    # Mantido para compatibilidade (derivado de status)
    is_active = Column(Boolean, default=True, nullable=False)
    
    # Contato
    email = Column(String(100), nullable=True)
    telefone = Column(String(20), nullable=True)
    
    # Endereço
    endereco = Column(String(255), nullable=True)
    cidade = Column(String(100), nullable=True)
    estado = Column(String(2), nullable=True)
    cep = Column(String(8), nullable=True)
    
    # Metadados de status
    motivo_status = Column(Text, nullable=True)  # Motivo da mudança de status
    data_mudanca_status = Column(DateTime(timezone=True), nullable=True)
    
    # Metadados gerais
    observacoes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relacionamento com usuários
    usuarios = relationship("User", back_populates="entidade")
    
    def __repr__(self):
        return f"<Entidade(id={self.id}, nome='{self.nome}', status='{self.status}')>"
    
    @property
    def is_ativa(self) -> bool:
        """Verifica se entidade está ativa"""
        return self.status == StatusEntidade.ATIVA
    
    @property
    def is_acessivel(self) -> bool:
        """Verifica se entidade é acessível (ativa ou em análise)"""
        return self.status in [StatusEntidade.ATIVA, StatusEntidade.EM_ANALISE]
    
    def to_dict(self):
        return {
            "id": self.id,
            "nome": self.nome,
            "razao_social": self.razao_social,
            "cnpj": self.cnpj,
            "tipo": self.tipo.value if self.tipo else None,
            "status": self.status.value if self.status else None,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }


class User(Base):
    """Modelo de usuário"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=True)
    role = Column(SQLEnum(UserRole), default=UserRole.OPERADOR, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    
    # MFA Fields
    mfa_enabled = Column(Boolean, default=False, nullable=False)
    mfa_secret = Column(String(32), nullable=True)
    mfa_backup_codes = Column(Text, nullable=True)
    
    # Relacionamento com Entidade
    entidade_id = Column(Integer, ForeignKey("entidades.id"), nullable=True, index=True)
    entidade = relationship("Entidade", back_populates="usuarios")
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)
    
    def __repr__(self):
        return f"<User(id={self.id}, username='{self.username}', role='{self.role.value}')>"
    
    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "full_name": self.full_name,
            "role": self.role.value,
            "is_active": self.is_active,
            "entidade_id": self.entidade_id,
            "mfa_enabled": self.mfa_enabled,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "last_login": self.last_login.isoformat() if self.last_login else None
        }
