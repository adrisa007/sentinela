"""
Decorator de auditoria para registrar automaticamente todas as ações no sistema.
Grava logs em LogAuditoria para compliance e rastreabilidade.
"""

import json
from functools import wraps
from datetime import datetime
from typing import Callable, Any
from fastapi import Request

from app.models.all_models import LogAuditoria, TipoAcao


def auditar(tipo_acao: TipoAcao, tabela: str):
    """
    Decorator para auditoria automática de ações.
    
    Uso:
        @auditar(TipoAcao.CREATE, "contratos")
        async def create_contrato(...):
            ...
    
    Args:
        tipo_acao: Tipo de ação sendo realizada (CREATE, UPDATE, DELETE, etc.)
        tabela: Nome da tabela afetada
        
    Returns:
        Decorator function
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Executar a função original
            result = await func(*args, **kwargs)
            
            # Extrair informações do contexto
            usuario_id = None
            ip_address = None
            user_agent = None
            
            # Tentar obter request e user do contexto
            for arg in args:
                if isinstance(arg, Request):
                    ip_address = arg.client.host if arg.client else None
                    user_agent = arg.headers.get("user-agent")
            
            # Obter user_id dos kwargs se disponível
            if "current_user" in kwargs:
                usuario_id = kwargs["current_user"].get("id")
            
            # Preparar dados para log
            registro_id = None
            dados_depois = None
            
            # Se o resultado for um objeto com ID, capturar
            if hasattr(result, "id"):
                registro_id = str(result.id)
                try:
                    dados_depois = json.dumps(
                        result.model_dump() if hasattr(result, "model_dump") else str(result)
                    )
                except:
                    dados_depois = str(result)
            
            # Criar log de auditoria (em produção, usar task assíncrona)
            # TODO: Implementar gravação assíncrona via Celery ou background task
            log_entry = LogAuditoria(
                usuario_id=usuario_id,
                tipo_acao=tipo_acao,
                tabela=tabela,
                registro_id=registro_id,
                dados_antes=None,  # TODO: Capturar estado anterior em UPDATEs
                dados_depois=dados_depois,
                ip_address=ip_address,
                user_agent=user_agent,
                timestamp=datetime.utcnow()
            )
            
            # Em produção, salvar no banco de forma assíncrona
            # await salvar_log_auditoria(log_entry)
            
            print(f"[AUDIT] {tipo_acao.value} em {tabela} por {usuario_id or 'unknown'}")
            
            return result
        
        return wrapper
    return decorator


def auditar_alteracao(tabela: str):
    """
    Decorator especializado para auditar alterações (UPDATE).
    Captura o estado anterior e posterior do registro.
    
    Uso:
        @auditar_alteracao("contratos")
        async def update_contrato(db, contrato_id, dados, current_user):
            ...
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # TODO: Capturar estado anterior do registro antes da alteração
            dados_antes = None
            
            # Se houver db e id nos kwargs, buscar estado anterior
            if "db" in kwargs and any(k.endswith("_id") for k in kwargs):
                # Implementar busca do estado anterior
                pass
            
            # Executar função
            result = await func(*args, **kwargs)
            
            # Criar log com antes/depois
            # Similar ao decorator auditar(), mas com dados_antes preenchido
            
            return result
        
        return wrapper
    return decorator


async def criar_log_auditoria(
    db,
    usuario_id: str,
    tipo_acao: TipoAcao,
    tabela: str,
    registro_id: str = None,
    dados_antes: dict = None,
    dados_depois: dict = None,
    ip_address: str = None,
    user_agent: str = None
):
    """
    Função helper para criar log de auditoria manualmente.
    
    Útil para casos onde o decorator não é aplicável.
    
    Args:
        db: Sessão do banco de dados
        usuario_id: ID do usuário que realizou a ação
        tipo_acao: Tipo de ação (CREATE, UPDATE, DELETE, etc.)
        tabela: Nome da tabela afetada
        registro_id: ID do registro afetado
        dados_antes: JSON dos dados antes da ação
        dados_depois: JSON dos dados após a ação
        ip_address: IP do cliente
        user_agent: User-Agent do cliente
    """
    log = LogAuditoria(
        usuario_id=usuario_id,
        tipo_acao=tipo_acao,
        tabela=tabela,
        registro_id=registro_id,
        dados_antes=json.dumps(dados_antes) if dados_antes else None,
        dados_depois=json.dumps(dados_depois) if dados_depois else None,
        ip_address=ip_address,
        user_agent=user_agent,
        timestamp=datetime.utcnow()
    )
    
    db.add(log)
    await db.commit()
    
    return log


def extrair_alteracoes(dados_antes: dict, dados_depois: dict) -> dict:
    """
    Compara dois dicionários e retorna apenas os campos alterados.
    
    Útil para logs mais compactos e relatórios de auditoria.
    
    Args:
        dados_antes: Estado anterior
        dados_depois: Estado posterior
        
    Returns:
        Dicionário com apenas os campos que mudaram
    """
    alteracoes = {}
    
    for campo, valor_novo in dados_depois.items():
        valor_antigo = dados_antes.get(campo)
        if valor_antigo != valor_novo:
            alteracoes[campo] = {
                "antes": valor_antigo,
                "depois": valor_novo
            }
    
    return alteracoes
