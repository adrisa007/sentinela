"""
Schemas Pydantic para validação de dados
=========================================

Repositório: adrisa007/sentinela (ID: 1112237272)
"""
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional
from datetime import datetime
from enum import Enum


# ============ Enums ============

class UserRoleEnum(str, Enum):
    """Enum de perfis de usuário"""
    ROOT = "ROOT"
    GESTOR = "GESTOR"
    OPERADOR = "OPERADOR"


class TipoEntidadeEnum(str, Enum):
    """Enum de tipos de entidade"""
    EMPRESA = "EMPRESA"
    ORGANIZACAO = "ORGANIZACAO"
    DEPARTAMENTO = "DEPARTAMENTO"
    FILIAL = "FILIAL"


class StatusEntidadeEnum(str, Enum):
    """Enum de status de entidade"""
    ATIVA = "ATIVA"
    INATIVA = "INATIVA"
    SUSPENSA = "SUSPENSA"
    BLOQUEADA = "BLOQUEADA"
    EM_ANALISE = "EM_ANALISE"


# ============ Schemas de Usuário ============

class UserBase(BaseModel):
    """Schema base de usuário"""
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    full_name: Optional[str] = None


class UserCreate(UserBase):
    """Schema para criação de usuário"""
    password: str = Field(..., min_length=6)
    role: UserRoleEnum = Field(default=UserRoleEnum.OPERADOR)


class UserResponse(UserBase):
    """Schema de resposta de usuário"""
    id: int
    role: str
    is_active: bool
    mfa_enabled: bool
    entidade_id: Optional[int] = None
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


# ============ Schemas de Autenticação ============

class UserLogin(BaseModel):
    """Schema para login de usuário"""
    username: str = Field(..., min_length=3, max_length=50, description="Username do usuário")
    password: str = Field(..., min_length=6, description="Senha do usuário")
    totp_code: Optional[str] = Field(None, min_length=6, max_length=6, description="Código TOTP (se MFA habilitado)")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "username": "usuario_teste",
                "password": "senha_secreta123",
                "totp_code": "123456"
            }
        }
    )


class Token(BaseModel):
    """Schema de resposta de token JWT"""
    access_token: str = Field(..., description="Token JWT de acesso")
    token_type: str = Field(default="bearer", description="Tipo de token")
    user: dict = Field(..., description="Informações básicas do usuário")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                "token_type": "bearer",
                "user": {
                    "id": 1,
                    "username": "usuario",
                    "role": "GESTOR",
                    "mfa_enabled": True
                }
            }
        }
    )


class MFASetup(BaseModel):
    """Schema para configuração de MFA"""
    secret: str = Field(..., description="Secret TOTP para configuração")
    qr_code: str = Field(..., description="QR Code em base64 para scan")
    username: str = Field(..., description="Username do usuário")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "secret": "JBSWY3DPEHPK3PXP",
                "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANS...",
                "username": "usuario_teste"
            }
        }
    )


class MFAVerify(BaseModel):
    """Schema para verificação de código TOTP"""
    totp_code: str = Field(..., min_length=6, max_length=6, description="Código TOTP de 6 dígitos")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "totp_code": "123456"
            }
        }
    )


class MessageResponse(BaseModel):
    """Schema de resposta genérica com mensagem"""
    message: str = Field(..., description="Mensagem principal")
    detail: Optional[str] = Field(None, description="Detalhes adicionais")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "message": "Operação realizada com sucesso",
                "detail": "Detalhes sobre a operação"
            }
        }
    )


# ============ Schemas de Entidade ============

class EntidadeBase(BaseModel):
    """Schema base de entidade"""
    nome: str = Field(..., min_length=3, max_length=200)
    razao_social: Optional[str] = None
    cnpj: Optional[str] = Field(None, min_length=14, max_length=14)
    tipo: TipoEntidadeEnum
    email: Optional[EmailStr] = None
    telefone: Optional[str] = None
    endereco: Optional[str] = None
    cidade: Optional[str] = None
    estado: Optional[str] = Field(None, max_length=2)
    cep: Optional[str] = Field(None, max_length=8)


class EntidadeCreate(EntidadeBase):
    """Schema para criação de entidade"""
    pass


class EntidadeUpdate(BaseModel):
    """Schema para atualização de entidade (campos opcionais)"""
    nome: Optional[str] = Field(None, min_length=3, max_length=200)
    razao_social: Optional[str] = None
    email: Optional[EmailStr] = None
    telefone: Optional[str] = None
    endereco: Optional[str] = None
    cidade: Optional[str] = None
    estado: Optional[str] = Field(None, max_length=2)
    cep: Optional[str] = Field(None, max_length=8)


class EntidadeResponse(EntidadeBase):
    """Schema de resposta de entidade"""
    id: int
    status: StatusEntidadeEnum
    is_active: bool
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class EntidadeResponseComplete(EntidadeResponse):
    """Schema de resposta completa de entidade com relacionamentos"""
    usuarios: Optional[list] = []
    
    model_config = ConfigDict(from_attributes=True)


class EntidadeStatusUpdate(BaseModel):
    """Schema para atualização de status de entidade"""
    status: StatusEntidadeEnum
    motivo: Optional[str] = Field(None, max_length=500, description="Motivo da mudança de status")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "status": "SUSPENSA",
                "motivo": "Inadimplência - Pagamento em atraso há 30 dias"
            }
        }
    )
