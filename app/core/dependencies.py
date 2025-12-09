"""
Dependencies para autenticação e autorização
Versão: 2.0 - MFA TOTP obrigatório para ROOT/GESTOR
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime
import logging

from app.core.database import get_db
from app.core.models import User, UserRole
from app.core.config import settings
from app.core.auth import verify_totp

# Configurar logging
logger = logging.getLogger(__name__)

# Security scheme
security = HTTPBearer()


class CurrentUser:
    """
    Representa o usuário autenticado atual
    
    Attributes:
        id: ID do usuário
        username: Nome de usuário
        email: Email do usuário
        role: Role/perfil do usuário (ROOT, GESTOR, OPERADOR)
        mfa_verified: Se o MFA foi verificado (obrigatório para ROOT/GESTOR)
        user: Objeto User completo do SQLAlchemy
    """
    def __init__(self, user: User, mfa_verified: bool = False):
        self.id = user.id
        self.username = user.username
        self.email = user.email
        self.role = user.role
        self.mfa_verified = mfa_verified
        self.user = user
        
        # Log de acesso bem-sucedido
        logger.info(
            f"Usuário autenticado: {self.username} (Role: {self.role}, MFA: {mfa_verified})"
        )
    
    def __repr__(self):
        return f"<CurrentUser(username='{self.username}', role='{self.role}', mfa={self.mfa_verified})>"


def decode_jwt_token(token: str) -> dict:
    """
    Decodifica e valida token JWT
    
    Args:
        token: Token JWT a ser decodificado
        
    Returns:
        dict: Payload do token decodificado
        
    Raises:
        HTTPException: Se token for inválido ou expirado
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        
        # Garantir que 'sub' seja string (compatibilidade)
        if "sub" in payload and isinstance(payload["sub"], int):
            payload["sub"] = str(payload["sub"])
        
        return payload
        
    except JWTError as e:
        logger.warning(f"Falha ao decodificar JWT: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido ou expirado",
            headers={"WWW-Authenticate": "Bearer"}
        )


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> CurrentUser:
    """
    🔐 ATUALIZADO: Obtém usuário autenticado com MFA OBRIGATÓRIO para ROOT/GESTOR
    
    Fluxo de Validação:
    1. ✅ Decodifica e valida JWT
    2. ✅ Verifica existência e status do usuário
    3. ✅ **EXIGE MFA TOTP para ROOT e GESTOR**
    4. ✅ Valida código TOTP com janela de tempo
    5. ✅ Retorna CurrentUser autenticado
    
    Args:
        credentials: Credenciais Bearer token do header Authorization
        db: Sessão do banco de dados (injetada)
        
    Returns:
        CurrentUser: Objeto com dados do usuário autenticado
        
    Raises:
        HTTPException 401: Token inválido ou usuário não encontrado
        HTTPException 403: MFA não configurado ou código TOTP inválido
        
    Security:
        - ROOT/GESTOR: MFA TOTP **OBRIGATÓRIO**
        - OPERADOR: Autenticação JWT apenas
    """
    
    # 1. Decodificar JWT
    token = credentials.credentials
    payload = decode_jwt_token(token)
    
    # 2. Extrair user_id
    user_id = payload.get("sub")
    if not user_id:
        logger.warning("Token sem 'sub' (user_id)")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido: identificador de usuário não encontrado",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # Converter para inteiro
    try:
        user_id = int(user_id)
    except (ValueError, TypeError):
        logger.warning(f"User ID inválido no token: {user_id}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido: identificador malformado",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # 3. Buscar usuário no banco de dados
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        logger.warning(f"Tentativa de acesso com user_id inexistente: {user_id}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário não encontrado",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # 4. Verificar se usuário está ativo
    if not user.is_active:
        logger.warning(f"Tentativa de acesso de usuário inativo: {user.username}")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuário inativo. Entre em contato com o administrador."
        )
    
    # 5. 🔐 VERIFICAÇÃO MFA OBRIGATÓRIA PARA ROOT E GESTOR
    mfa_verified = False
    
    if user.role in [UserRole.ROOT, UserRole.GESTOR]:
        logger.info(f"Validando MFA para usuário {user.username} (Role: {user.role})")
        
        # 5.1. Verificar se MFA está configurado
        if not user.mfa_enabled:
            logger.error(
                f"MFA não configurado para {user.username} (Role: {user.role})"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"🔒 MFA é OBRIGATÓRIO para usuários {user.role.value}. "
                    f"Configure o MFA usando /auth/mfa/setup antes de fazer login."
                ),
                headers={"X-MFA-Required": "true"}
            )
        
        if not user.mfa_secret:
            logger.error(
                f"MFA habilitado mas sem secret para {user.username}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Erro de configuração MFA. Entre em contato com o administrador.",
                headers={"X-MFA-Required": "true"}
            )
        
        # 5.2. Extrair código TOTP do payload
        totp_token: Optional[str] = payload.get("totp")
        if not totp_token:
            logger.warning(
                f"Token JWT sem código TOTP para {user.username} (Role: {user.role})"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"🔒 Código MFA (TOTP) não fornecido. "
                    f"Usuários {user.role.value} devem incluir código MFA no login."
                ),
                headers={
                    "X-MFA-Required": "true",
                    "X-MFA-Setup-URL": "/auth/mfa/setup"
                }
            )
        
        # 5.3. Validar código TOTP
        if not verify_totp(user.mfa_secret, totp_token):
            logger.warning(
                f"Código TOTP inválido para {user.username} - Código: {totp_token[:2]}***"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "🔒 Código MFA (TOTP) inválido ou expirado. "
                    "Gere um novo código no seu aplicativo autenticador."
                ),
                headers={"X-MFA-Failed": "true"}
            )
        
        # 5.4. MFA verificado com sucesso
        mfa_verified = True
        logger.info(
            f"✅ MFA verificado com sucesso para {user.username} (Role: {user.role})"
        )
    
    else:
        # OPERADOR: MFA opcional
        logger.info(
            f"Usuário {user.username} autenticado sem MFA (Role: {user.role})"
        )
    
    # 6. Retornar CurrentUser
    return CurrentUser(user=user, mfa_verified=mfa_verified)


def require_role(*allowed_roles: UserRole):
    """
    Factory function para criar dependency que verifica roles específicas
    
    Args:
        allowed_roles: Roles permitidas para acessar o endpoint
        
    Returns:
        Callable: Função async que verifica a role do usuário
        
    Usage:
        @app.get("/admin", dependencies=[Depends(require_role(UserRole.ROOT))])
        async def admin_endpoint():
            return {"message": "Acesso ROOT"}
    """
    async def role_checker(
        current_user: CurrentUser = Depends(get_current_user)
    ) -> CurrentUser:
        if current_user.role not in allowed_roles:
            logger.warning(
                f"Acesso negado: {current_user.username} (Role: {current_user.role}) "
                f"tentou acessar endpoint que requer: {[r.value for r in allowed_roles]}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Acesso negado. Permissões necessárias: "
                    f"{', '.join([role.value for role in allowed_roles])}"
                )
            )
        
        logger.info(
            f"✅ Acesso autorizado: {current_user.username} (Role: {current_user.role})"
        )
        return current_user
    
    return role_checker


def require_mfa_verified():
    """
    Dependency que exige MFA verificado (para endpoints sensíveis)
    
    Usage:
        @app.post("/critical-action", dependencies=[Depends(require_mfa_verified())])
        async def critical_action():
            return {"message": "Ação crítica executada"}
    """
    async def mfa_checker(
        current_user: CurrentUser = Depends(get_current_user)
    ) -> CurrentUser:
        if not current_user.mfa_verified:
            logger.warning(
                f"MFA não verificado para ação sensível: {current_user.username}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Esta ação requer verificação MFA"
            )
        return current_user
    
    return mfa_checker


# ============ Aliases convenientes ============

# Apenas ROOT pode acessar
require_root = require_role(UserRole.ROOT)

# ROOT e GESTOR podem acessar
require_gestor = require_role(UserRole.ROOT, UserRole.GESTOR)

# Qualquer usuário autenticado pode acessar
require_operador = require_role(UserRole.ROOT, UserRole.GESTOR, UserRole.OPERADOR)

# Qualquer usuário autenticado (alias)
require_authenticated = require_operador


# ============ Entidade Dependencies ============

from app.core.models import Entidade


async def get_current_entidade(
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> Entidade:
    """
    🏢 Obtém a entidade associada ao usuário logado
    
    Busca automaticamente a entidade vinculada ao usuário autenticado.
    Útil para operações que precisam do contexto organizacional do usuário.
    
    Args:
        current_user: Usuário autenticado (injetado)
        db: Sessão do banco de dados (injetada)
        
    Returns:
        Entidade: Objeto Entidade associado ao usuário
        
    Raises:
        HTTPException 404: Se usuário não tem entidade associada
        HTTPException 403: Se entidade está inativa
        
    Usage:
        @app.get("/my-entity")
        async def get_my_entity(entidade: Entidade = Depends(get_current_entidade)):
            return entidade
    """
    
    # Verificar se usuário tem entidade_id
    if not current_user.user.entidade_id:
        logger.warning(
            f"Usuário {current_user.username} não tem entidade associada"
        )
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Nenhuma entidade associada a este usuário. "
                "Entre em contato com o administrador para vincular uma entidade."
            )
        )
    
    # Buscar entidade no banco
    entidade = db.query(Entidade).filter(
        Entidade.id == current_user.user.entidade_id
    ).first()
    
    if not entidade:
        logger.error(
            f"Entidade ID {current_user.user.entidade_id} não encontrada para usuário {current_user.username}"
        )
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Entidade não encontrada no sistema"
        )
    
    # Verificar se entidade está ativa
    if not entidade.is_active:
        logger.warning(
            f"Tentativa de acesso à entidade inativa: {entidade.nome} (ID: {entidade.id})"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                f"A entidade '{entidade.nome}' está inativa. "
                f"Entre em contato com o administrador."
            )
        )
    
    logger.info(
        f"✅ Entidade '{entidade.nome}' (ID: {entidade.id}) acessada por {current_user.username}"
    )
    
    return entidade


async def get_current_entidade_optional(
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> Optional[Entidade]:
    """
    🏢 Obtém a entidade do usuário logado (opcional - não lança erro se não houver)
    
    Versão opcional de get_current_entidade que retorna None em vez de erro.
    Útil para endpoints que funcionam com ou sem entidade.
    
    Args:
        current_user: Usuário autenticado
        db: Sessão do banco de dados
        
    Returns:
        Entidade ou None: Entidade associada ou None se não houver
    """
    
    if not current_user.user.entidade_id:
        return None
    
    entidade = db.query(Entidade).filter(
        Entidade.id == current_user.user.entidade_id,
        Entidade.is_active == True
    ).first()
    
    return entidade


def require_entidade():
    """
    Decorator/Dependency que exige que o usuário tenha uma entidade ativa
    
    Usage:
        @app.get("/entity-required", dependencies=[Depends(require_entidade())])
        async def entity_required_endpoint():
            return {"message": "Usuário tem entidade"}
    """
    async def entidade_checker(
        entidade: Entidade = Depends(get_current_entidade)
    ) -> Entidade:
        # A validação já é feita por get_current_entidade
        return entidade
    
    return entidade_checker


# ============ Validação de Status de Entidade ============

def require_active_entidade():
    """
    🔒 Dependency que EXIGE que a entidade do usuário esteja com status ATIVA
    
    Valida:
    1. ✅ Usuário tem entidade associada
    2. ✅ Entidade existe no banco de dados
    3. ✅ Entidade tem status == ATIVA
    
    Levanta HTTPException 403 se:
    - Entidade está INATIVA
    - Entidade está SUSPENSA
    - Entidade está BLOQUEADA
    - Entidade está EM_ANALISE
    
    Args:
        None (usa Depends internamente)
        
    Returns:
        Entidade: Objeto Entidade com status ATIVA
        
    Raises:
        HTTPException 404: Se usuário não tem entidade associada
        HTTPException 403: Se entidade não está ATIVA
        
    Usage:
        @app.get("/sensitive-data", dependencies=[Depends(require_active_entidade())])
        async def get_sensitive_data():
            return {"data": "Dados sensíveis"}
            
        # Ou com acesso à entidade
        @app.post("/create-resource")
        async def create_resource(
            entidade: Entidade = Depends(require_active_entidade())
        ):
            return {"entidade_id": entidade.id}
    
    Security Level: 🔒🔒🔒 HIGH
    """
    async def check_entidade_active(
        entidade: Entidade = Depends(get_current_entidade)
    ) -> Entidade:
        from app.core.models import StatusEntidade
        
        # Verificar se entidade está ATIVA
        if entidade.status != StatusEntidade.ATIVA:
            # Log detalhado para auditoria
            logger.warning(
                f"🚫 Acesso negado: Entidade '{entidade.nome}' (ID: {entidade.id}) "
                f"com status '{entidade.status.value}' tentou acessar recurso protegido"
            )
            
            # Mensagens customizadas por status
            status_messages = {
                StatusEntidade.INATIVA: (
                    f"A entidade '{entidade.nome}' está INATIVA. "
                    "Entre em contato com o administrador para reativar."
                ),
                StatusEntidade.SUSPENSA: (
                    f"A entidade '{entidade.nome}' está SUSPENSA. "
                    f"Motivo: {entidade.motivo_status or 'Não especificado'}. "
                    "Entre em contato com o suporte para mais informações."
                ),
                StatusEntidade.BLOQUEADA: (
                    f"A entidade '{entidade.nome}' está BLOQUEADA. "
                    f"Motivo: {entidade.motivo_status or 'Violação de termos de uso'}. "
                    "Esta ação não pode ser revertida. Entre em contato com o suporte."
                ),
                StatusEntidade.EM_ANALISE: (
                    f"A entidade '{entidade.nome}' está EM ANÁLISE. "
                    "Aguarde a aprovação para acessar este recurso."
                )
            }
            
            detail = status_messages.get(
                entidade.status,
                f"Entidade com status '{entidade.status.value}' não pode acessar este recurso."
            )
            
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=detail,
                headers={
                    "X-Entidade-Status": entidade.status.value,
                    "X-Entidade-Id": str(entidade.id)
                }
            )
        
        # Log de sucesso
        logger.info(
            f"✅ Entidade '{entidade.nome}' (ID: {entidade.id}) "
            f"validada com status ATIVA"
        )
        
        return entidade
    
    return check_entidade_active


def require_entidade_status(*allowed_statuses: 'StatusEntidade'):
    """
    🔒 Dependency genérica que permite múltiplos status de entidade
    
    Args:
        allowed_statuses: Status permitidos para acessar o recurso
        
    Returns:
        Callable: Dependency que valida o status
        
    Usage:
        # Permitir ATIVA ou EM_ANALISE
        @app.get("/partial-access", dependencies=[
            Depends(require_entidade_status(StatusEntidade.ATIVA, StatusEntidade.EM_ANALISE))
        ])
        async def partial_access():
            return {"message": "Acesso permitido"}
    """
    async def check_entidade_status(
        entidade: Entidade = Depends(get_current_entidade)
    ) -> Entidade:
        if entidade.status not in allowed_statuses:
            logger.warning(
                f"🚫 Acesso negado: Entidade '{entidade.nome}' status '{entidade.status.value}' "
                f"não está em: {[s.value for s in allowed_statuses]}"
            )
            
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Entidade com status '{entidade.status.value}' não pode acessar este recurso. "
                    f"Status permitidos: {', '.join([s.value for s in allowed_statuses])}"
                ),
                headers={
                    "X-Entidade-Status": entidade.status.value,
                    "X-Required-Status": ",".join([s.value for s in allowed_statuses])
                }
            )
        
        return entidade
    
    return check_entidade_status


async def get_entidade_with_status_check(
    current_user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> Entidade:
    """
    🏢 Versão de get_current_entidade com validação automática de status ATIVA
    
    Combina get_current_entidade + require_active_entidade em uma única dependency.
    Use esta quando quiser sempre validar status ATIVA.
    
    Returns:
        Entidade: Entidade ATIVA do usuário
        
    Raises:
        HTTPException 404: Usuário sem entidade
        HTTPException 403: Entidade não ATIVA
    """
    from app.core.models import StatusEntidade
    
    # Buscar entidade
    entidade = await get_current_entidade(current_user, db)
    
    # Validar status
    if entidade.status != StatusEntidade.ATIVA:
        logger.warning(
            f"�� get_entidade_with_status_check: Entidade '{entidade.nome}' "
            f"não está ATIVA (status: {entidade.status.value})"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Entidade não está ativa (status: {entidade.status.value})"
        )
    
    return entidade


# ============ Validação Específica de Perfil ROOT ============

async def require_root_user(
    current_user: CurrentUser = Depends(get_current_user)
) -> CurrentUser:
    """
    🔒 Dependency que EXIGE perfil ROOT (validação específica)
    
    Valida rigorosamente que o usuário tem perfil ROOT.
    Levanta HTTPException 403 se o perfil for diferente de ROOT.
    
    Diferenças de `require_root`:
    - Mensagens de erro mais específicas para ROOT
    - Logging mais detalhado com contexto de tentativa de acesso
    - Headers customizados para auditoria
    - Validações adicionais de segurança
    
    Args:
        current_user: Usuário autenticado (injetado via get_current_user)
        
    Returns:
        CurrentUser: Objeto do usuário ROOT validado
        
    Raises:
        HTTPException 403: Se usuário não for ROOT
        
    Security Validations:
    - ✅ Perfil == ROOT
    - ✅ MFA verificado (obrigatório para ROOT)
    - ✅ Usuário ativo
    - ✅ Auditoria completa de tentativas
    
    Usage:
        @app.delete("/system/reset", dependencies=[Depends(require_root_user)])
        async def reset_system():
            return {"message": "Sistema resetado"}
        
        # Ou com acesso ao usuário ROOT
        @app.post("/admin/create-root")
        async def create_root_user(
            root_user: CurrentUser = Depends(require_root_user)
        ):
            return {"created_by": root_user.username}
    
    Security Level: 🔒🔒🔒🔒 MAXIMUM
    """
    from app.core.models import UserRole
    
    # Validação 1: Verificar perfil ROOT
    if current_user.role != UserRole.ROOT:
        # Log detalhado de tentativa de acesso não autorizado
        logger.warning(
            f"🚨 TENTATIVA DE ACESSO ROOT NEGADA: "
            f"Usuário '{current_user.username}' (ID: {current_user.id}) "
            f"com perfil '{current_user.role.value}' tentou acessar recurso ROOT"
        )
        
        # Mensagem específica baseada no perfil atual
        perfil_messages = {
            UserRole.GESTOR: (
                f"Acesso negado. O perfil GESTOR não tem permissão para esta operação. "
                f"Apenas usuários ROOT podem executar esta ação."
            ),
            UserRole.OPERADOR: (
                f"Acesso negado. O perfil OPERADOR não tem permissão para esta operação. "
                f"Esta é uma operação administrativa restrita a ROOT."
            )
        }
        
        detail = perfil_messages.get(
            current_user.role,
            f"Acesso negado. Perfil '{current_user.role.value}' não autorizado. "
            f"Apenas perfil ROOT pode executar esta operação."
        )
        
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail,
            headers={
                "X-Required-Role": "ROOT",
                "X-Current-Role": current_user.role.value,
                "X-User-Id": str(current_user.id),
                "X-Access-Denied-Reason": "INSUFFICIENT_PRIVILEGES"
            }
        )
    
    # Validação 2: Verificar se MFA foi validado (obrigatório para ROOT)
    if not current_user.mfa_verified:
        logger.error(
            f"🚨 ERRO DE SEGURANÇA: Usuário ROOT '{current_user.username}' "
            f"tentou acessar sem MFA verificado"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "🔒 MFA não verificado. Usuários ROOT devem ter MFA verificado "
                "para acessar operações administrativas."
            ),
            headers={
                "X-Required-MFA": "true",
                "X-MFA-Verified": "false"
            }
        )
    
    # Log de acesso autorizado
    logger.info(
        f"✅ ACESSO ROOT AUTORIZADO: "
        f"Usuário ROOT '{current_user.username}' (ID: {current_user.id}) "
        f"com MFA verificado acessou recurso protegido"
    )
    
    return current_user


def require_root_or_owner(resource_owner_id: int):
    """
    🔒 Dependency que permite acesso ROOT ou ao dono do recurso
    
    Útil para operações onde ROOT pode acessar tudo,
    mas usuários podem acessar apenas seus próprios recursos.
    
    Args:
        resource_owner_id: ID do dono do recurso
        
    Returns:
        Callable: Dependency que valida ROOT ou ownership
        
    Usage:
        @app.get("/users/{user_id}/data")
        async def get_user_data(
            user_id: int,
            _: CurrentUser = Depends(require_root_or_owner(user_id))
        ):
            return {"data": "user_data"}
    """
    async def check_root_or_owner(
        current_user: CurrentUser = Depends(get_current_user)
    ) -> CurrentUser:
        from app.core.models import UserRole
        
        is_root = current_user.role == UserRole.ROOT
        is_owner = current_user.id == resource_owner_id
        
        if not (is_root or is_owner):
            logger.warning(
                f"🚫 Acesso negado: Usuário '{current_user.username}' "
                f"(perfil: {current_user.role.value}) tentou acessar recurso "
                f"de propriedade do usuário ID {resource_owner_id}"
            )
            
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Acesso negado. Você só pode acessar seus próprios recursos, "
                    "a menos que seja ROOT."
                ),
                headers={
                    "X-Resource-Owner": str(resource_owner_id),
                    "X-Current-User": str(current_user.id)
                }
            )
        
        if is_root:
            logger.info(
                f"✅ ROOT '{current_user.username}' acessou recurso do usuário {resource_owner_id}"
            )
        else:
            logger.info(
                f"✅ Usuário '{current_user.username}' acessou próprio recurso"
            )
        
        return current_user
    
    return check_root_or_owner


async def require_root_with_reason(reason: str):
    """
    🔒 Dependency ROOT com logging de motivo de acesso
    
    Útil para operações críticas onde é importante auditar
    não apenas QUEM acessou, mas PARA QUÊ.
    
    Args:
        reason: Motivo/descrição da operação ROOT
        
    Returns:
        Callable: Dependency que valida ROOT e loga motivo
        
    Usage:
        @app.delete("/database/truncate")
        async def truncate_database(
            _: CurrentUser = Depends(require_root_with_reason("Truncar banco de dados"))
        ):
            # Operação crítica
            return {"message": "Banco truncado"}
    """
    async def check_root_with_reason(
        current_user: CurrentUser = Depends(require_root_user)
    ) -> CurrentUser:
        # Log com motivo específico
        logger.info(
            f"🔐 OPERAÇÃO ROOT: '{reason}' - "
            f"Executada por '{current_user.username}' (ID: {current_user.id})"
        )
        
        return current_user
    
    return check_root_with_reason


async def get_root_user_info(
    root_user: CurrentUser = Depends(require_root_user)
) -> dict:
    """
    🔒 Dependency que retorna informações do usuário ROOT
    
    Útil para endpoints que precisam logar ou auditar
    quem executou uma operação ROOT.
    
    Returns:
        dict: Informações do usuário ROOT
        
    Usage:
        @app.post("/admin/critical-action")
        async def critical_action(
            root_info: dict = Depends(get_root_user_info)
        ):
            return {
                "message": "Ação executada",
                "executed_by": root_info["username"],
                "timestamp": root_info["timestamp"]
            }
    """
    from datetime import datetime
    
    return {
        "id": root_user.id,
        "username": root_user.username,
        "email": root_user.email,
        "role": root_user.role.value,
        "mfa_verified": root_user.mfa_verified,
        "timestamp": datetime.utcnow().isoformat(),
        "access_type": "ROOT_ADMIN"
    }


class RootOperationContext:
    """
    🔒 Context manager para operações ROOT com auditoria completa
    
    Usage:
        async with RootOperationContext(current_user, "Deletar usuário 123"):
            # Operação crítica
            db.delete(user)
            db.commit()
    """
    def __init__(self, root_user: CurrentUser, operation: str):
        self.root_user = root_user
        self.operation = operation
        self.start_time = None
    
    async def __aenter__(self):
        from datetime import datetime
        self.start_time = datetime.utcnow()
        
        logger.info(
            f"🔐 INÍCIO OPERAÇÃO ROOT: '{self.operation}' - "
            f"Por: '{self.root_user.username}' (ID: {self.root_user.id})"
        )
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        from datetime import datetime
        duration = (datetime.utcnow() - self.start_time).total_seconds()
        
        if exc_type is None:
            logger.info(
                f"✅ SUCESSO OPERAÇÃO ROOT: '{self.operation}' - "
                f"Por: '{self.root_user.username}' - "
                f"Duração: {duration:.2f}s"
            )
        else:
            logger.error(
                f"❌ FALHA OPERAÇÃO ROOT: '{self.operation}' - "
                f"Por: '{self.root_user.username}' - "
                f"Erro: {exc_type.__name__}: {exc_val} - "
                f"Duração: {duration:.2f}s"
            )
        
        return False  # Não suprime exceções
