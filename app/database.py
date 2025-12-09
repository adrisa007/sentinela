"""
Configuração de banco de dados Neon PostgreSQL para o Sentinela
Repositório: adrisa007/sentinela (ID: 1112237272)
"""
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# URL do banco de dados Neon
# Formato: postgresql://user:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./sentinela.db"  # Fallback para desenvolvimento local
)

# Configurações para Neon (PostgreSQL)
engine_config = {
    "pool_pre_ping": True,  # Verifica conexão antes de usar
    "pool_recycle": 300,    # Recicla conexões a cada 5 min
    "pool_size": 5,         # Pool de 5 conexões
    "max_overflow": 10,     # Até 10 conexões extras
}

# Adicionar SSL se for Neon
if "neon.tech" in DATABASE_URL or "postgresql" in DATABASE_URL:
    engine_config["connect_args"] = {"sslmode": "require"}

engine = create_engine(DATABASE_URL, **engine_config)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    """
    Dependency para obter sessão do banco
    
    Yields:
        Session: Sessão do SQLAlchemy
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def check_database_connection() -> bool:
    """
    Verifica conexão com o banco de dados Neon executando SELECT 1
    
    Returns:
        bool: True se conectado, False caso contrário
    """
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            conn.commit()
            return result.scalar() == 1
    except Exception as e:
        print(f"❌ Erro ao conectar ao banco Neon: {e}")
        return False
