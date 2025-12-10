"""
PNCP Router - Integração com Portal Nacional de Contratações Públicas
adrisa007/sentinela (ID: 1112237272)
"""
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
import httpx
from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel

from app.core.database import get_db
from app.core.dependencies import get_current_user, CurrentUser

router = APIRouter(
    prefix="/pncp",
    tags=["PNCP"]
)

# URL base da API do PNCP
PNCP_API_URL = "https://pncp.gov.br/api"


class ContratosPNCP(BaseModel):
    """Modelo de contrato do PNCP"""
    numero: str
    objeto: str
    valor: float
    data_assinatura: str
    vigencia: str


class FornecedorPNCPResponse(BaseModel):
    """Resposta com dados do fornecedor no PNCP"""
    success: bool
    cnpj: str
    razao_social: str
    nome_fantasia: Optional[str] = None
    situacao_cadastral: str
    data_abertura: str
    porte: str
    natureza_juridica: str
    logradouro: str
    numero: str
    complemento: Optional[str] = None
    bairro: str
    municipio: str
    uf: str
    cep: str
    telefone: Optional[str] = None
    email: Optional[str] = None
    contratos_pncp: List[ContratosPNCP]
    total_contratos: int
    valor_total: float
    ultima_atualizacao: str


@router.get("/fornecedor/{cnpj}", response_model=FornecedorPNCPResponse)
async def consultar_fornecedor_pncp(
    cnpj: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Consulta dados de um fornecedor no Portal Nacional de Contratações Públicas (PNCP)
    
    Args:
        cnpj: CNPJ do fornecedor (apenas números)
        current_user: Usuário autenticado
        db: Sessão do banco de dados
        
    Returns:
        Dados do fornecedor incluindo contratos no PNCP
        
    Raises:
        HTTPException: Se houver erro na consulta
    """
    try:
        # Limpar CNPJ (remover formatação)
        cnpj_limpo = ''.join(filter(str.isdigit, cnpj))
        
        if len(cnpj_limpo) != 14:
            raise HTTPException(
                status_code=400,
                detail="CNPJ inválido. Deve conter 14 dígitos."
            )
        
        # TODO: Implementar consulta real à API do PNCP
        # Por enquanto, retornar dados simulados para desenvolvimento
        
        """
        # Exemplo de consulta real (quando a API do PNCP estiver disponível):
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Consultar dados cadastrais
            response_cadastro = await client.get(
                f"{PNCP_API_URL}/fornecedor/{cnpj_limpo}",
                headers={"Accept": "application/json"}
            )
            
            if response_cadastro.status_code == 404:
                raise HTTPException(
                    status_code=404,
                    detail="Fornecedor não encontrado no PNCP"
                )
            
            response_cadastro.raise_for_status()
            dados_cadastro = response_cadastro.json()
            
            # Consultar contratos
            response_contratos = await client.get(
                f"{PNCP_API_URL}/contratos/fornecedor/{cnpj_limpo}",
                headers={"Accept": "application/json"}
            )
            
            contratos = []
            valor_total = 0.0
            
            if response_contratos.status_code == 200:
                dados_contratos = response_contratos.json()
                for contrato in dados_contratos.get('contratos', []):
                    contratos.append(ContratosPNCP(
                        numero=contrato['numero'],
                        objeto=contrato['objeto'],
                        valor=contrato['valor'],
                        data_assinatura=contrato['dataAssinatura'],
                        vigencia=contrato['vigencia']
                    ))
                    valor_total += contrato['valor']
        """
        
        # Dados simulados para desenvolvimento
        contratos_mock = [
            ContratosPNCP(
                numero="001/2024",
                objeto="Fornecimento de materiais de escritório",
                valor=50000.00,
                data_assinatura="2024-01-15",
                vigencia="2024-12-31"
            ),
            ContratosPNCP(
                numero="045/2023",
                objeto="Prestação de serviços de manutenção",
                valor=120000.00,
                data_assinatura="2023-06-20",
                vigencia="2024-06-20"
            ),
            ContratosPNCP(
                numero="078/2024",
                objeto="Locação de equipamentos",
                valor=85000.00,
                data_assinatura="2024-03-10",
                vigencia="2025-03-10"
            )
        ]
        
        valor_total = sum(c.valor for c in contratos_mock)
        
        return FornecedorPNCPResponse(
            success=True,
            cnpj=cnpj_limpo,
            razao_social="EMPRESA EXEMPLO LTDA",
            nome_fantasia="Empresa Exemplo",
            situacao_cadastral="ATIVA",
            data_abertura="2015-03-15",
            porte="MEDIO",
            natureza_juridica="Sociedade Empresária Limitada",
            logradouro="Av. Paulista",
            numero="1000",
            complemento="Sala 500",
            bairro="Bela Vista",
            municipio="São Paulo",
            uf="SP",
            cep="01310-100",
            telefone="(11) 3000-0000",
            email="contato@empresa.com.br",
            contratos_pncp=contratos_mock,
            total_contratos=len(contratos_mock),
            valor_total=valor_total,
            ultima_atualizacao=datetime.now().isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao consultar PNCP: {str(e)}"
        )


@router.get("/contratos/fornecedor/{cnpj}")
async def listar_contratos_fornecedor(
    cnpj: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
    ano: Optional[int] = None,
    status: Optional[str] = None
):
    """
    Lista todos os contratos de um fornecedor no PNCP
    
    Args:
        cnpj: CNPJ do fornecedor
        ano: Filtrar por ano (opcional)
        status: Filtrar por status (opcional)
        current_user: Usuário autenticado
        db: Sessão do banco de dados
        
    Returns:
        Lista de contratos do fornecedor
    """
    try:
        cnpj_limpo = ''.join(filter(str.isdigit, cnpj))
        
        if len(cnpj_limpo) != 14:
            raise HTTPException(
                status_code=400,
                detail="CNPJ inválido"
            )
        
        # TODO: Implementar consulta real
        # Dados simulados
        contratos = [
            {
                "numero": "001/2024",
                "objeto": "Fornecimento de materiais de escritório",
                "valor": 50000.00,
                "data_assinatura": "2024-01-15",
                "vigencia": "2024-12-31",
                "status": "VIGENTE",
                "orgao": "Prefeitura Municipal"
            },
            {
                "numero": "045/2023",
                "objeto": "Prestação de serviços de manutenção",
                "valor": 120000.00,
                "data_assinatura": "2023-06-20",
                "vigencia": "2024-06-20",
                "status": "ENCERRADO",
                "orgao": "Secretaria de Obras"
            }
        ]
        
        # Aplicar filtros
        if ano:
            contratos = [c for c in contratos if str(ano) in c['numero']]
        
        if status:
            contratos = [c for c in contratos if c['status'] == status.upper()]
        
        return {
            "success": True,
            "cnpj": cnpj_limpo,
            "total": len(contratos),
            "contratos": contratos
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao listar contratos: {str(e)}"
        )
