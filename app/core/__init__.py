"""
Core module - Funcionalidades centrais do Sentinela
"""
from app.core.config import settings
from app.core.database import get_db, init_db
from app.core.models import User, UserRole

__all__ = ["settings", "get_db", "init_db", "User", "UserRole"]
