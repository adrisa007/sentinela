#!/usr/bin/env python3
"""
Script de backup automatizado para PostgreSQL com upload para AWS S3.
Execução: python scripts/backup_s3.py
"""

import os
import sys
import subprocess
import gzip
import boto3
from datetime import datetime
from pathlib import Path

# Adicionar app ao path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.core.config import settings


def criar_backup_postgres():
    """
    Cria dump do banco PostgreSQL comprimido.
    
    Returns:
        Path do arquivo de backup criado
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_filename = f"sentinela_backup_{timestamp}.sql.gz"
    backup_path = f"/tmp/{backup_filename}"
    
    print(f"📦 Criando backup do banco de dados...")
    
    # Extrair componentes da URL do banco
    # Format: postgresql+asyncpg://user:pass@host:port/dbname
    db_url = settings.DATABASE_URL.replace("postgresql+asyncpg://", "")
    
    try:
        # Executar pg_dump e comprimir
        dump_cmd = f"pg_dump {settings.DATABASE_URL.replace('+asyncpg', '')} | gzip > {backup_path}"
        subprocess.run(dump_cmd, shell=True, check=True)
        
        print(f"✅ Backup criado: {backup_path}")
        
        # Verificar tamanho do arquivo
        tamanho = os.path.getsize(backup_path)
        tamanho_mb = tamanho / (1024 * 1024)
        print(f"📊 Tamanho: {tamanho_mb:.2f} MB")
        
        return backup_path, tamanho
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao criar backup: {e}")
        raise


def upload_para_s3(backup_path: str, tamanho: int):
    """
    Faz upload do backup para AWS S3.
    
    Args:
        backup_path: Caminho do arquivo de backup
        tamanho: Tamanho do arquivo em bytes
        
    Returns:
        URL S3 do backup
    """
    print(f"☁️  Fazendo upload para S3...")
    
    # Inicializar cliente S3
    s3_client = boto3.client(
        's3',
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_REGION
    )
    
    # Nome do objeto no S3 (organizado por data)
    hoje = datetime.now()
    s3_key = f"backups/{hoje.year}/{hoje.month:02d}/{os.path.basename(backup_path)}"
    
    try:
        # Upload do arquivo
        s3_client.upload_file(
            backup_path,
            settings.S3_BUCKET_NAME,
            s3_key,
            ExtraArgs={
                'StorageClass': 'STANDARD_IA',  # Infrequent Access (mais barato)
                'ServerSideEncryption': 'AES256'
            }
        )
        
        s3_url = f"s3://{settings.S3_BUCKET_NAME}/{s3_key}"
        print(f"✅ Upload concluído: {s3_url}")
        
        return s3_url
        
    except Exception as e:
        print(f"❌ Erro no upload para S3: {e}")
        raise


def limpar_backups_antigos_s3(dias_retencao: int = 30):
    """
    Remove backups mais antigos que X dias do S3.
    
    Args:
        dias_retencao: Número de dias para manter backups
    """
    print(f"🧹 Limpando backups com mais de {dias_retencao} dias...")
    
    s3_client = boto3.client(
        's3',
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_REGION
    )
    
    from datetime import timedelta
    cutoff_date = datetime.now() - timedelta(days=dias_retencao)
    
    try:
        # Listar objetos na pasta de backups
        response = s3_client.list_objects_v2(
            Bucket=settings.S3_BUCKET_NAME,
            Prefix='backups/'
        )
        
        if 'Contents' not in response:
            print("ℹ️  Nenhum backup encontrado no S3")
            return
        
        deletados = 0
        for obj in response['Contents']:
            if obj['LastModified'].replace(tzinfo=None) < cutoff_date:
                s3_client.delete_object(
                    Bucket=settings.S3_BUCKET_NAME,
                    Key=obj['Key']
                )
                deletados += 1
                print(f"🗑️  Removido: {obj['Key']}")
        
        print(f"✅ {deletados} backups antigos removidos")
        
    except Exception as e:
        print(f"❌ Erro ao limpar backups antigos: {e}")


def registrar_backup_no_banco(tamanho: int, s3_key: str, status: str = "sucesso"):
    """
    Registra informações do backup na tabela BackupLog.
    
    TODO: Implementar gravação no banco de dados
    """
    print(f"📝 Registrando backup no banco de dados...")
    # Implementar criação de registro em BackupLog
    pass


def main():
    """
    Função principal do script de backup.
    """
    print("=" * 60)
    print("🚀 SENTINELA - Backup Automatizado")
    print("=" * 60)
    
    inicio = datetime.now()
    
    try:
        # 1. Criar backup do PostgreSQL
        backup_path, tamanho = criar_backup_postgres()
        
        # 2. Upload para S3
        s3_url = upload_para_s3(backup_path, tamanho)
        
        # 3. Limpar backups antigos
        limpar_backups_antigos_s3(dias_retencao=30)
        
        # 4. Registrar no banco
        registrar_backup_no_banco(tamanho, s3_url, status="sucesso")
        
        # 5. Limpar arquivo local
        os.remove(backup_path)
        print(f"🧹 Arquivo local removido: {backup_path}")
        
        # Tempo total
        duracao = (datetime.now() - inicio).total_seconds()
        print("=" * 60)
        print(f"✅ Backup concluído com sucesso!")
        print(f"⏱️  Duração: {duracao:.2f} segundos")
        print("=" * 60)
        
    except Exception as e:
        print("=" * 60)
        print(f"❌ ERRO: Backup falhou!")
        print(f"Detalhes: {e}")
        print("=" * 60)
        sys.exit(1)


if __name__ == "__main__":
    main()
