"""
Configuração de banco de dados para o Sentinela
"""
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# URL do banco de dados
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./sentinela.db"  # SQLite por padrão para desenvolvimento
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    """Dependency para obter sessão do banco"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def check_database_connection() -> bool:
    """
    Verifica conexão com o banco de dados executando SELECT 1
    
    Returns:
        bool: True se conectado, False caso contrário
    """
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
            conn.commit()
        return True
    except Exception as e:
        print(f"Erro ao conectar ao banco: {e}")
        return False
