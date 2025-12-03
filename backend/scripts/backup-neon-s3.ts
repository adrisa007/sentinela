/**
 * Sentinela – Backup Neon PostgreSQL → AWS S3
 * Lei nº 14.133/2021
 * 
 * Este script exporta um backup do banco de dados Neon e envia para AWS S3.
 * Pode ser executado via:
 * - GitHub Actions (cron diário)
 * - Cron externo
 * - Manualmente: npx ts-node scripts/backup-neon-s3.ts
 * 
 * Variáveis de ambiente necessárias:
 * - DATABASE_URL: URL de conexão com o Neon PostgreSQL
 * - AWS_ACCESS_KEY_ID: Credencial AWS
 * - AWS_SECRET_ACCESS_KEY: Credencial AWS
 * - AWS_REGION: Região da AWS (default: sa-east-1)
 * - S3_BUCKET_NAME: Nome do bucket S3
 */

import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { spawn } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

// Configuração
const config = {
  databaseUrl: process.env.DATABASE_URL || '',
  awsRegion: process.env.AWS_REGION || 'sa-east-1',
  s3BucketName: process.env.S3_BUCKET_NAME || 'sentinela-backups',
  backupRetentionDays: 30,
};

// Cliente S3
const s3Client = new S3Client({
  region: config.awsRegion,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
  },
});

/**
 * Gera nome do arquivo de backup com timestamp
 */
function generateBackupFileName(): string {
  const now = new Date();
  const timestamp = now.toISOString().replace(/[:.]/g, '-');
  return `sentinela-backup-${timestamp}.sql`;
}

/**
 * Executa pg_dump para exportar o banco usando spawn (seguro contra injection)
 */
async function createDatabaseBackup(outputPath: string): Promise<void> {
  console.log('📦 Iniciando backup do banco de dados Neon...');
  
  if (!config.databaseUrl) {
    throw new Error('DATABASE_URL não configurada');
  }

  return new Promise((resolve, reject) => {
    const outputStream = fs.createWriteStream(outputPath);
    
    // Usa spawn com array de argumentos para evitar command injection
    const pgDump = spawn('pg_dump', [
      config.databaseUrl,
      '--format=plain',
      '--no-owner',
      '--no-acl',
    ]);

    pgDump.stdout.pipe(outputStream);
    
    let stderrData = '';
    pgDump.stderr.on('data', (data) => {
      stderrData += data.toString();
    });

    pgDump.on('close', (code) => {
      if (code === 0) {
        if (stderrData && !stderrData.includes('pg_dump:')) {
          console.warn('⚠️ Warnings:', stderrData);
        }
        console.log('✅ Backup do banco criado com sucesso');
        resolve();
      } else {
        reject(new Error(`pg_dump exited with code ${code}: ${stderrData}`));
      }
    });

    pgDump.on('error', (err) => {
      reject(new Error(`Falha ao executar pg_dump: ${err.message}`));
    });
  });
}

/**
 * Faz upload do backup para S3
 */
async function uploadToS3(filePath: string, fileName: string): Promise<void> {
  console.log('☁️ Enviando backup para AWS S3...');
  
  const fileContent = fs.readFileSync(filePath);
  const s3Key = `backups/${fileName}`;

  const command = new PutObjectCommand({
    Bucket: config.s3BucketName,
    Key: s3Key,
    Body: fileContent,
    ContentType: 'application/sql',
    Metadata: {
      'backup-date': new Date().toISOString(),
      'source': 'neon-postgresql',
      'project': 'sentinela',
    },
  });

  try {
    await s3Client.send(command);
    console.log(`✅ Backup enviado para s3://${config.s3BucketName}/${s3Key}`);
  } catch (error) {
    throw new Error(`Falha ao enviar para S3: ${error.message}`);
  }
}

/**
 * Remove arquivo temporário local
 */
function cleanupLocalFile(filePath: string): void {
  try {
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      console.log('🧹 Arquivo temporário removido');
    }
  } catch (error) {
    console.warn('⚠️ Falha ao remover arquivo temporário:', error.message);
  }
}

/**
 * Execução principal do backup
 */
async function main(): Promise<void> {
  console.log('═══════════════════════════════════════════════════');
  console.log('🛡️  Sentinela – Backup Automático Neon → AWS S3');
  console.log('═══════════════════════════════════════════════════');
  console.log(`📅 Data/Hora: ${new Date().toISOString()}`);
  console.log(`🌍 Região AWS: ${config.awsRegion}`);
  console.log(`🪣 Bucket S3: ${config.s3BucketName}`);
  console.log('═══════════════════════════════════════════════════\n');

  const fileName = generateBackupFileName();
  const tempPath = path.join(os.tmpdir(), fileName);

  try {
    // 1. Criar backup
    await createDatabaseBackup(tempPath);

    // 2. Verificar tamanho do arquivo
    const stats = fs.statSync(tempPath);
    console.log(`📊 Tamanho do backup: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);

    // 3. Upload para S3
    await uploadToS3(tempPath, fileName);

    // 4. Cleanup
    cleanupLocalFile(tempPath);

    console.log('\n═══════════════════════════════════════════════════');
    console.log('✅ Backup concluído com sucesso!');
    console.log('═══════════════════════════════════════════════════\n');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Erro durante o backup:', error.message);
    cleanupLocalFile(tempPath);
    process.exit(1);
  }
}

// Executa o script
main();
