"""
Schemas Pydantic para validação de requisições e respostas da API.
Separados dos models SQLModel para maior flexibilidade.
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator


# ==================== AUTH SCHEMAS ====================

class UserRegister(BaseModel):
    """Schema para registro de novo usuário"""
    email: EmailStr
    nome_completo: str = Field(min_length=3, max_length=255)
    senha: str = Field(min_length=8, max_length=100)
    entidade_id: Optional[str] = None


class UserLogin(BaseModel):
    """Schema para login"""
    email: EmailStr
    senha: str
    totp_code: Optional[str] = Field(default=None, min_length=6, max_length=6)


class TokenResponse(BaseModel):
    """Schema de resposta com tokens JWT"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class MFAEnableResponse(BaseModel):
    """Schema de resposta ao habilitar MFA"""
    secret: str
    qr_code_uri: str
    message: str


# ==================== ENTIDADE SCHEMAS ====================

class EntidadeCreate(BaseModel):
    """Schema para criação de entidade"""
    cnpj: str = Field(min_length=14, max_length=14)
    nome: str = Field(max_length=255)
    nome_fantasia: Optional[str] = None
    tipo_entidade: str  # municipal, estadual, federal
    uf: str = Field(min_length=2, max_length=2)
    municipio: Optional[str] = None
    esfera: str


class EntidadeResponse(BaseModel):
    """Schema de resposta de entidade"""
    id: str
    cnpj: str
    nome: str
    tipo_entidade: str
    uf: str
    ativo: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class EntidadeUpdate(BaseModel):
    """Schema para atualização de entidade"""
    nome: Optional[str] = None
    nome_fantasia: Optional[str] = None
    municipio: Optional[str] = None
    ativo: Optional[bool] = None


# ==================== FORNECEDOR SCHEMAS ====================

class FornecedorCreate(BaseModel):
    """Schema para criação de fornecedor"""
    cnpj: str = Field(min_length=14, max_length=14)
    razao_social: str = Field(max_length=255)
    nome_fantasia: Optional[str] = None


class FornecedorResponse(BaseModel):
    """Schema de resposta de fornecedor"""
    id: str
    cnpj: str
    razao_social: str
    nome_fantasia: Optional[str]
    situacao_receita: Optional[str]
    score_risco: Optional[float]
    ativo: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class FornecedorUpdate(BaseModel):
    """Schema para atualização de fornecedor"""
    razao_social: Optional[str] = None
    nome_fantasia: Optional[str] = None
    ativo: Optional[bool] = None


# ==================== CONTRATO SCHEMAS ====================

class ContratoCreate(BaseModel):
    """Schema para criação de contrato"""
    numero_contrato: str = Field(max_length=100)
    ano_contrato: int = Field(ge=2000, le=2100)
    fornecedor_id: str
    objeto: str
    valor_global: float = Field(gt=0)
    data_assinatura: datetime
    data_inicio: datetime
    data_fim: datetime
    modalidade: Optional[str] = None
    numero_processo: Optional[str] = None
    
    @field_validator('data_fim')
    @classmethod
    def validar_datas(cls, v, info):
        if 'data_inicio' in info.data and v <= info.data['data_inicio']:
            raise ValueError('data_fim deve ser posterior a data_inicio')
        return v


class ContratoResponse(BaseModel):
    """Schema de resposta de contrato"""
    id: str
    numero_contrato: str
    ano_contrato: int
    entidade_id: str
    fornecedor_id: str
    objeto: str
    valor_global: float
    valor_executado: float
    data_inicio: datetime
    data_fim: datetime
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class ContratoUpdate(BaseModel):
    """Schema para atualização de contrato"""
    objeto: Optional[str] = None
    valor_executado: Optional[float] = None
    status: Optional[str] = None
    data_fim: Optional[datetime] = None


# ==================== ADITIVO SCHEMAS ====================

class AditivoCreate(BaseModel):
    """Schema para criação de aditivo"""
    numero_aditivo: str
    tipo_aditivo: str
    descricao: str
    valor_aditivo: Optional[float] = None
    nova_data_fim: Optional[datetime] = None
    data_assinatura: datetime
    justificativa: Optional[str] = None


class AditivoResponse(BaseModel):
    """Schema de resposta de aditivo"""
    id: str
    contrato_id: str
    numero_aditivo: str
    tipo_aditivo: str
    descricao: str
    valor_aditivo: Optional[float]
    data_assinatura: datetime
    created_at: datetime
    
    class Config:
        from_attributes = True


# ==================== ALERTA SCHEMAS ====================

class AlertaResponse(BaseModel):
    """Schema de resposta de alerta"""
    id: str
    contrato_id: str
    tipo_alerta: str
    severidade: str
    titulo: str
    descricao: str
    score_confianca: Optional[float]
    resolvido: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class AlertaResolucao(BaseModel):
    """Schema para marcar alerta como resolvido"""
    observacoes_resolucao: Optional[str] = None


# ==================== PNCP SCHEMAS ====================

class PNCPBuscaParams(BaseModel):
    """Parâmetros de busca no PNCP"""
    cnpj: Optional[str] = None
    data_inicial: Optional[str] = None  # YYYY-MM-DD
    data_final: Optional[str] = None
    pagina: int = Field(default=1, ge=1)


class PNCPImportarParams(BaseModel):
    """Parâmetros para importação do PNCP"""
    cnpj: str = Field(min_length=14, max_length=14)
    data_inicial: str  # YYYY-MM-DD
    data_final: str
    entidade_id: Optional[str] = None


# ==================== GENERIC SCHEMAS ====================

class MessageResponse(BaseModel):
    """Schema genérico de resposta com mensagem"""
    message: str
    status: Optional[str] = "success"


class PaginatedResponse(BaseModel):
    """Schema genérico para respostas paginadas"""
    total: int
    skip: int
    limit: int
    items: list


class HealthCheckResponse(BaseModel):
    """Schema de health check"""
    status: str
    database: str
    cache: str
    version: str = "1.0.0"
