"""
Modelos de dados completos do sistema Sentinela usando SQLModel.
Total de 12 tabelas principais.
"""

from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field, Relationship
from enum import Enum


# ==================== ENUMS ====================

class TipoEntidade(str, Enum):
    """Tipos de entidades públicas"""
    MUNICIPAL = "municipal"
    ESTADUAL = "estadual"
    FEDERAL = "federal"


class StatusContrato(str, Enum):
    """Status possíveis de um contrato"""
    ATIVO = "ativo"
    ENCERRADO = "encerrado"
    SUSPENSO = "suspenso"
    CANCELADO = "cancelado"


class TipoAlerta(str, Enum):
    """Tipos de alertas do sistema"""
    PRAZO_VENCIMENTO = "prazo_vencimento"
    FORNECEDOR_IRREGULAR = "fornecedor_irregular"
    VALOR_SUSPEITO = "valor_suspeito"
    ADITIVOS_EXCESSIVOS = "aditivos_excessivos"
    LICITACAO_FRACIONADA = "licitacao_fracionada"


class TipoAcao(str, Enum):
    """Tipos de ações auditadas"""
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"
    LOGIN = "login"
    LOGOUT = "logout"


# ==================== TABELA 1: Entidade ====================

class Entidade(SQLModel, table=True):
    """
    Representa um órgão público (município, estado, união).
    """
    __tablename__ = "entidades"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    cnpj: str = Field(unique=True, index=True, max_length=14)
    nome: str = Field(max_length=255)
    nome_fantasia: Optional[str] = Field(default=None, max_length=255)
    tipo_entidade: TipoEntidade
    uf: str = Field(max_length=2)
    municipio: Optional[str] = Field(default=None, max_length=100)
    esfera: str = Field(max_length=50)  # municipal, estadual, federal
    
    ativo: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relacionamentos
    # usuarios: list["Usuario"] = Relationship(back_populates="entidade")
    # contratos: list["Contrato"] = Relationship(back_populates="entidade")


# ==================== TABELA 2: Usuario ====================

class Usuario(SQLModel, table=True):
    """
    Usuários do sistema (servidores públicos com acesso ao Sentinela).
    """
    __tablename__ = "usuarios"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    email: str = Field(unique=True, index=True, max_length=255)
    nome_completo: str = Field(max_length=255)
    senha_hash: str = Field(max_length=255)
    
    entidade_id: Optional[str] = Field(default=None, foreign_key="entidades.id")
    
    is_superuser: bool = Field(default=False)
    is_active: bool = Field(default=True)
    
    # MFA/TOTP
    mfa_habilitado: bool = Field(default=False)
    mfa_secret: Optional[str] = Field(default=None, max_length=32)
    
    ultimo_login: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relacionamentos
    # entidade: Optional["Entidade"] = Relationship(back_populates="usuarios")


# ==================== TABELA 3: Fornecedor ====================

class Fornecedor(SQLModel, table=True):
    """
    Empresas fornecedoras que possuem contratos com entidades públicas.
    """
    __tablename__ = "fornecedores"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    cnpj: str = Field(unique=True, index=True, max_length=14)
    razao_social: str = Field(max_length=255)
    nome_fantasia: Optional[str] = Field(default=None, max_length=255)
    
    # Dados da Receita Federal
    situacao_receita: Optional[str] = Field(default=None, max_length=50)
    data_situacao_receita: Optional[datetime] = None
    natureza_juridica: Optional[str] = Field(default=None, max_length=100)
    porte: Optional[str] = Field(default=None, max_length=50)
    
    # Endereço
    cep: Optional[str] = Field(default=None, max_length=8)
    logradouro: Optional[str] = Field(default=None, max_length=255)
    numero: Optional[str] = Field(default=None, max_length=20)
    complemento: Optional[str] = Field(default=None, max_length=100)
    bairro: Optional[str] = Field(default=None, max_length=100)
    municipio: Optional[str] = Field(default=None, max_length=100)
    uf: Optional[str] = Field(default=None, max_length=2)
    
    # Score de risco (calculado por ML)
    score_risco: Optional[float] = Field(default=None)
    
    ativo: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relacionamentos
    # contratos: list["Contrato"] = Relationship(back_populates="fornecedor")


# ==================== TABELA 4: Contrato ====================

class Contrato(SQLModel, table=True):
    """
    Contratos públicos celebrados entre entidades e fornecedores.
    """
    __tablename__ = "contratos"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    numero_contrato: str = Field(index=True, max_length=100)
    ano_contrato: int
    
    entidade_id: str = Field(foreign_key="entidades.id")
    fornecedor_id: str = Field(foreign_key="fornecedores.id")
    
    objeto: str  # Descrição do objeto contratado
    valor_global: float
    valor_executado: float = Field(default=0.0)
    
    data_assinatura: datetime
    data_inicio: datetime
    data_fim: datetime
    data_publicacao: Optional[datetime] = None
    
    status: StatusContrato = Field(default=StatusContrato.ATIVO)
    
    # Modalidade de licitação
    modalidade: Optional[str] = Field(default=None, max_length=100)
    numero_processo: Optional[str] = Field(default=None, max_length=100)
    
    # Integração PNCP
    pncp_id: Optional[str] = Field(default=None, unique=True, max_length=100)
    ultima_sync_pncp: Optional[datetime] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relacionamentos
    # entidade: Optional["Entidade"] = Relationship(back_populates="contratos")
    # fornecedor: Optional["Fornecedor"] = Relationship(back_populates="contratos")
    # aditivos: list["Aditivo"] = Relationship(back_populates="contrato")
    # alertas: list["Alerta"] = Relationship(back_populates="contrato")


# ==================== TABELA 5: Aditivo ====================

class Aditivo(SQLModel, table=True):
    """
    Aditivos contratuais (prorrogações, acréscimos, supressões).
    """
    __tablename__ = "aditivos"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    contrato_id: str = Field(foreign_key="contratos.id", index=True)
    numero_aditivo: str = Field(max_length=50)
    
    tipo_aditivo: str = Field(max_length=100)  # prorrogacao, acrescimo, supressao, etc.
    descricao: str
    
    valor_aditivo: Optional[float] = None
    nova_data_fim: Optional[datetime] = None
    
    data_assinatura: datetime
    justificativa: Optional[str] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relacionamentos
    # contrato: Optional["Contrato"] = Relationship(back_populates="aditivos")


# ==================== TABELA 6: Alerta ====================

class Alerta(SQLModel, table=True):
    """
    Alertas automáticos de risco e anomalias em contratos.
    """
    __tablename__ = "alertas"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    contrato_id: str = Field(foreign_key="contratos.id", index=True)
    
    tipo_alerta: TipoAlerta
    severidade: str = Field(max_length=20)  # baixa, media, alta, critica
    
    titulo: str = Field(max_length=255)
    descricao: str
    
    # ML Score
    score_confianca: Optional[float] = None  # 0-1
    
    resolvido: bool = Field(default=False)
    resolvido_por: Optional[str] = None
    resolvido_em: Optional[datetime] = None
    observacoes_resolucao: Optional[str] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relacionamentos
    # contrato: Optional["Contrato"] = Relationship(back_populates="alertas")


# ==================== TABELA 7: LogAuditoria ====================

class LogAuditoria(SQLModel, table=True):
    """
    Registro de todas as ações realizadas no sistema (auditoria completa).
    """
    __tablename__ = "logs_auditoria"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    usuario_id: Optional[str] = Field(default=None, foreign_key="usuarios.id")
    
    tipo_acao: TipoAcao
    tabela: str = Field(max_length=100)  # nome da tabela afetada
    registro_id: Optional[str] = None  # ID do registro afetado
    
    dados_antes: Optional[str] = None  # JSON dos dados antes da alteração
    dados_depois: Optional[str] = None  # JSON dos dados depois da alteração
    
    ip_address: Optional[str] = Field(default=None, max_length=45)
    user_agent: Optional[str] = None
    
    timestamp: datetime = Field(default_factory=datetime.utcnow, index=True)


# ==================== TABELA 8: Notificacao ====================

class Notificacao(SQLModel, table=True):
    """
    Notificações para usuários (alertas, vencimentos, etc.).
    """
    __tablename__ = "notificacoes"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    usuario_id: str = Field(foreign_key="usuarios.id", index=True)
    
    titulo: str = Field(max_length=255)
    mensagem: str
    tipo: str = Field(max_length=50)  # info, warning, error, success
    
    lida: bool = Field(default=False)
    lida_em: Optional[datetime] = None
    
    link_referencia: Optional[str] = None  # URL para o recurso relacionado
    
    created_at: datetime = Field(default_factory=datetime.utcnow)


# ==================== TABELA 9: ConfiguracaoEntidade ====================

class ConfiguracaoEntidade(SQLModel, table=True):
    """
    Configurações específicas de cada entidade.
    """
    __tablename__ = "configuracoes_entidade"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    entidade_id: str = Field(foreign_key="entidades.id", unique=True)
    
    # Alertas
    alertas_habilitados: bool = Field(default=True)
    dias_alerta_vencimento: int = Field(default=30)  # alertar X dias antes do vencimento
    
    # Sincronização PNCP
    sync_pncp_automatica: bool = Field(default=True)
    frequencia_sync_dias: int = Field(default=7)
    
    # Notificações
    notificacoes_email: bool = Field(default=True)
    email_notificacoes: Optional[str] = Field(default=None, max_length=255)
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


# ==================== TABELA 10: ImportacaoPNCP ====================

class ImportacaoPNCP(SQLModel, table=True):
    """
    Histórico de importações do PNCP.
    """
    __tablename__ = "importacoes_pncp"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    entidade_id: Optional[str] = Field(default=None, foreign_key="entidades.id")
    usuario_id: str = Field(foreign_key="usuarios.id")
    
    data_inicio: datetime = Field(default_factory=datetime.utcnow)
    data_fim: Optional[datetime] = None
    
    status: str = Field(max_length=50)  # iniciado, processando, concluido, erro
    
    total_contratos_encontrados: int = Field(default=0)
    total_contratos_importados: int = Field(default=0)
    total_contratos_atualizados: int = Field(default=0)
    total_alertas_gerados: int = Field(default=0)
    
    parametros_busca: Optional[str] = None  # JSON com filtros usados
    mensagem_erro: Optional[str] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)


# ==================== TABELA 11: Dashboard ====================

class Dashboard(SQLModel, table=True):
    """
    Configurações de dashboards personalizados dos usuários.
    """
    __tablename__ = "dashboards"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    usuario_id: str = Field(foreign_key="usuarios.id")
    entidade_id: Optional[str] = Field(default=None, foreign_key="entidades.id")
    
    nome: str = Field(max_length=255)
    descricao: Optional[str] = None
    
    # Configuração dos widgets (JSON)
    layout: str  # JSON com configuração de widgets e posições
    
    is_default: bool = Field(default=False)
    is_publico: bool = Field(default=False)
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


# ==================== TABELA 12: BackupLog ====================

class BackupLog(SQLModel, table=True):
    """
    Log de backups realizados no S3.
    """
    __tablename__ = "backup_logs"
    
    id: Optional[str] = Field(default=None, primary_key=True)
    
    data_backup: datetime = Field(default_factory=datetime.utcnow)
    tipo_backup: str = Field(max_length=50)  # completo, incremental
    
    s3_bucket: str = Field(max_length=255)
    s3_key: str = Field(max_length=500)
    
    tamanho_bytes: int
    status: str = Field(max_length=50)  # sucesso, falha
    
    mensagem_erro: Optional[str] = None
    duracao_segundos: Optional[float] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
