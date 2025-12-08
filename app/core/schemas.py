from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict
from typing import Optional, List
from datetime import datetime
from app.core.models import UserRole

class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    full_name: Optional[str] = Field(None, max_length=100)
    
    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v):
        if not v.replace('_', '').isalnum():
            raise ValueError('Username deve conter apenas letras, números e underscore')
        return v

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)
    role: UserRole = Field(UserRole.OPERADOR)
    
    @field_validator('password')
    @classmethod
    def password_strength(cls, v):
        if not any(char.isdigit() for char in v):
            raise ValueError('Senha deve conter ao menos um número')
        if not any(char.isupper() for char in v):
            raise ValueError('Senha deve conter ao menos uma letra maiúscula')
        if not any(char.islower() for char in v):
            raise ValueError('Senha deve conter ao menos uma letra minúscula')
        return v

class UserResponse(UserBase):
    id: int
    role: UserRole
    is_active: bool
    mfa_enabled: bool
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    mfa_required: bool = False
    expires_in: Optional[int] = None

class LoginRequest(BaseModel):
    username: str
    password: str
    totp_code: Optional[str] = Field(None, min_length=6, max_length=6)

class MFASetupResponse(BaseModel):
    secret: str
    qr_code: str
    backup_codes: List[str]
    manual_entry_key: str

class MFAVerifyRequest(BaseModel):
    totp_code: str = Field(..., min_length=6, max_length=6)

class MessageResponse(BaseModel):
    message: str
    detail: Optional[str] = None


# ============ Entidade Schemas ============

from app.core.models import TipoEntidade


class EntidadeBase(BaseModel):
    """Schema base de Entidade"""
    nome: str = Field(..., min_length=3, max_length=200)
    razao_social: Optional[str] = Field(None, max_length=255)
    cnpj: Optional[str] = Field(None, pattern=r'^\d{14}$')
    tipo: TipoEntidade = Field(TipoEntidade.EMPRESA)
    email: Optional[EmailStr] = None
    telefone: Optional[str] = Field(None, max_length=20)
    endereco: Optional[str] = None
    cidade: Optional[str] = None
    estado: Optional[str] = Field(None, max_length=2)
    cep: Optional[str] = Field(None, pattern=r'^\d{8}$')
    observacoes: Optional[str] = None


class EntidadeCreate(EntidadeBase):
    """Schema para criação de Entidade"""
    pass


class EntidadeUpdate(BaseModel):
    """Schema para atualização de Entidade"""
    nome: Optional[str] = Field(None, min_length=3, max_length=200)
    razao_social: Optional[str] = None
    cnpj: Optional[str] = None
    tipo: Optional[TipoEntidade] = None
    email: Optional[EmailStr] = None
    telefone: Optional[str] = None
    endereco: Optional[str] = None
    cidade: Optional[str] = None
    estado: Optional[str] = None
    cep: Optional[str] = None
    is_active: Optional[bool] = None
    observacoes: Optional[str] = None


class EntidadeResponse(EntidadeBase):
    """Schema de resposta de Entidade"""
    id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)


class EntidadeSimple(BaseModel):
    """Schema simplificado de Entidade (para relacionamentos)"""
    id: int
    nome: str
    tipo: TipoEntidade
    
    model_config = ConfigDict(from_attributes=True)


# ============ Status Entidade ============

from app.core.models import StatusEntidade


class EntidadeStatusUpdate(BaseModel):
    """Schema para atualização de status de entidade"""
    status: StatusEntidade = Field(..., description="Novo status da entidade")
    motivo: Optional[str] = Field(None, description="Motivo da mudança de status")
    
    model_config = ConfigDict(use_enum_values=True)


class EntidadeStatusResponse(BaseModel):
    """Schema de resposta de status de entidade"""
    id: int
    nome: str
    status: StatusEntidade
    motivo_status: Optional[str] = None
    data_mudanca_status: Optional[datetime] = None
    is_ativa: bool
    is_acessivel: bool
    
    model_config = ConfigDict(from_attributes=True)


# Atualizar EntidadeResponse para incluir status
class EntidadeResponseComplete(EntidadeResponse):
    """Schema completo de resposta de Entidade com status"""
    status: StatusEntidade
    motivo_status: Optional[str] = None
    data_mudanca_status: Optional[datetime] = None
