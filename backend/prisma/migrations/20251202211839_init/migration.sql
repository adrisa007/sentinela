-- CreateEnum
CREATE TYPE "StatusEntidade" AS ENUM ('ATIVA', 'INATIVA', 'SUSPENSA');

-- CreateEnum
CREATE TYPE "PerfilUsuario" AS ENUM ('ROOT', 'GESTOR', 'FISCAL_TECNICO', 'FISCAL_ADM', 'APOIO', 'AUDITOR');

-- CreateTable
CREATE TABLE "Entidade" (
    "id" BIGSERIAL NOT NULL,
    "cnpj" VARCHAR(14) NOT NULL,
    "razaoSocial" VARCHAR(255) NOT NULL,
    "nomeFantasia" VARCHAR(255),
    "ugCodigo" VARCHAR(20),
    "status" "StatusEntidade" NOT NULL DEFAULT 'ATIVA',
    "dataStatus" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "motivoStatus" TEXT,
    "rootUserId" BIGINT,
    "logoUrl" VARCHAR(500),
    "configJson" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Entidade_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Usuario" (
    "id" BIGSERIAL NOT NULL,
    "entidadeId" BIGINT,
    "nome" VARCHAR(150) NOT NULL,
    "cpf" VARCHAR(11) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "senhaHash" VARCHAR(255) NOT NULL,
    "perfil" "PerfilUsuario" NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "certificadoDigital" VARCHAR(255),
    "totpSecret" TEXT,
    "totpEnabled" BOOLEAN NOT NULL DEFAULT false,
    "ultimoLogin" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Usuario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Fornecedor" (
    "id" BIGSERIAL NOT NULL,
    "entidadeId" BIGINT NOT NULL,
    "cnpj" VARCHAR(14),
    "cpf" VARCHAR(11),
    "razaoSocial" VARCHAR(255) NOT NULL,
    "nomeFantasia" VARCHAR(255),
    "situacaoCadastral" VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    "regularidadeGeral" VARCHAR(20) NOT NULL DEFAULT 'REGULAR',
    "dataUltimaVerificacao" TIMESTAMP(3),
    "totalCertidoesVencidas" INTEGER NOT NULL DEFAULT 0,
    "dataImpedimento" TIMESTAMP(3),
    "motivoImpedimento" TEXT,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "createdBy" BIGINT,
    "updatedBy" BIGINT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Fornecedor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_certidao" (
    "id" SERIAL NOT NULL,
    "codigo" VARCHAR(30) NOT NULL,
    "nome" VARCHAR(150) NOT NULL,
    "obrigatoriaLicitacao" BOOLEAN NOT NULL DEFAULT true,
    "obrigatoriaContratacao" BOOLEAN NOT NULL DEFAULT true,
    "prazoValidadeDias" INTEGER NOT NULL DEFAULT 180,
    "apiDisponivel" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "tipo_certidao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CertidaoFornecedor" (
    "id" BIGSERIAL NOT NULL,
    "fornecedorId" BIGINT NOT NULL,
    "tipoCertidaoId" INTEGER NOT NULL,
    "numeroProtocolo" VARCHAR(100),
    "dataEmissao" TIMESTAMP(3) NOT NULL,
    "dataValidade" TIMESTAMP(3) NOT NULL,
    "situacao" VARCHAR(20) NOT NULL DEFAULT 'VÁLIDA',
    "origem" VARCHAR(30),
    "arquivoPdf" VARCHAR(500),
    "hashArquivo" VARCHAR(64),
    "createdBy" BIGINT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CertidaoFornecedor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Contrato" (
    "id" BIGSERIAL NOT NULL,
    "entidadeId" BIGINT NOT NULL,
    "numeroContrato" VARCHAR(50) NOT NULL,
    "numeroProcesso" VARCHAR(50),
    "objeto" TEXT NOT NULL,
    "fornecedorId" BIGINT NOT NULL,
    "valorGlobal" DECIMAL(18,2) NOT NULL,
    "valorExecutado" DECIMAL(18,2) NOT NULL DEFAULT 0,
    "dataAssinatura" TIMESTAMP(3),
    "dataInicio" TIMESTAMP(3),
    "dataTermino" TIMESTAMP(3),
    "vigenciaMeses" INTEGER,
    "modalidade" VARCHAR(50),
    "tipoContrato" VARCHAR(50),
    "gestorId" BIGINT,
    "status" VARCHAR(30) NOT NULL DEFAULT 'VIGENTE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Contrato_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FiscalDesignado" (
    "id" BIGSERIAL NOT NULL,
    "contratoId" BIGINT NOT NULL,
    "usuarioId" BIGINT NOT NULL,
    "tipoFiscal" VARCHAR(20) NOT NULL,
    "dataDesignacao" TIMESTAMP(3) NOT NULL,
    "portaria" VARCHAR(100),
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "FiscalDesignado_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OcorrenciaFiscalizacao" (
    "id" BIGSERIAL NOT NULL,
    "contratoId" BIGINT NOT NULL,
    "usuarioId" BIGINT NOT NULL,
    "tipoOcorrencia" VARCHAR(100) NOT NULL,
    "descricao" TEXT NOT NULL,
    "dataOcorrencia" TIMESTAMP(3) NOT NULL,
    "statusOcorrencia" VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OcorrenciaFiscalizacao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CronogramaFisicoFin" (
    "id" BIGSERIAL NOT NULL,
    "contratoId" BIGINT NOT NULL,
    "etapa" VARCHAR(255) NOT NULL,
    "dataInicio" TIMESTAMP(3) NOT NULL,
    "dataFim" TIMESTAMP(3) NOT NULL,
    "percentualPrevisto" DECIMAL(5,2) NOT NULL,
    "percentualRealizado" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CronogramaFisicoFin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Penalidade" (
    "id" BIGSERIAL NOT NULL,
    "contratoId" BIGINT NOT NULL,
    "tipoPenalidade" VARCHAR(100) NOT NULL,
    "descricao" TEXT NOT NULL,
    "dataPenalidade" TIMESTAMP(3) NOT NULL,
    "valorPenalidade" DECIMAL(18,2) NOT NULL,
    "statusPenalidade" VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Penalidade_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatrizRiscos" (
    "id" BIGSERIAL NOT NULL,
    "contratoId" BIGINT NOT NULL,
    "usuarioId" BIGINT NOT NULL,
    "descricaoRisco" TEXT NOT NULL,
    "probabilidade" VARCHAR(20) NOT NULL,
    "impacto" VARCHAR(20) NOT NULL,
    "nivelRisco" VARCHAR(20) NOT NULL,
    "planoAcao" TEXT,
    "dataRisco" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MatrizRiscos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditoriaGlobal" (
    "id" BIGSERIAL NOT NULL,
    "entidadeId" BIGINT NOT NULL,
    "usuarioId" BIGINT NOT NULL,
    "tipoAuditoria" VARCHAR(100) NOT NULL,
    "descricao" TEXT NOT NULL,
    "dataAuditoria" TIMESTAMP(3) NOT NULL,
    "statusAuditoria" VARCHAR(20) NOT NULL DEFAULT 'PLANEJADA',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AuditoriaGlobal_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Entidade_cnpj_key" ON "Entidade"("cnpj");

-- CreateIndex
CREATE INDEX "Entidade_cnpj_idx" ON "Entidade"("cnpj");

-- CreateIndex
CREATE INDEX "Entidade_status_idx" ON "Entidade"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Usuario_cpf_key" ON "Usuario"("cpf");

-- CreateIndex
CREATE UNIQUE INDEX "Usuario_email_key" ON "Usuario"("email");

-- CreateIndex
CREATE INDEX "Usuario_entidadeId_perfil_idx" ON "Usuario"("entidadeId", "perfil");

-- CreateIndex
CREATE INDEX "Usuario_cpf_idx" ON "Usuario"("cpf");

-- CreateIndex
CREATE INDEX "Fornecedor_cnpj_idx" ON "Fornecedor"("cnpj");

-- CreateIndex
CREATE INDEX "Fornecedor_situacaoCadastral_idx" ON "Fornecedor"("situacaoCadastral");

-- CreateIndex
CREATE UNIQUE INDEX "Fornecedor_entidadeId_cnpj_key" ON "Fornecedor"("entidadeId", "cnpj");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_certidao_codigo_key" ON "tipo_certidao"("codigo");

-- CreateIndex
CREATE INDEX "CertidaoFornecedor_fornecedorId_dataValidade_idx" ON "CertidaoFornecedor"("fornecedorId", "dataValidade");

-- CreateIndex
CREATE INDEX "CertidaoFornecedor_situacao_idx" ON "CertidaoFornecedor"("situacao");

-- CreateIndex
CREATE INDEX "Contrato_entidadeId_status_idx" ON "Contrato"("entidadeId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Contrato_entidadeId_numeroContrato_key" ON "Contrato"("entidadeId", "numeroContrato");

-- CreateIndex
CREATE UNIQUE INDEX "FiscalDesignado_contratoId_usuarioId_key" ON "FiscalDesignado"("contratoId", "usuarioId");

-- CreateIndex
CREATE INDEX "OcorrenciaFiscalizacao_contratoId_statusOcorrencia_idx" ON "OcorrenciaFiscalizacao"("contratoId", "statusOcorrencia");

-- CreateIndex
CREATE INDEX "CronogramaFisicoFin_contratoId_idx" ON "CronogramaFisicoFin"("contratoId");

-- CreateIndex
CREATE INDEX "Penalidade_contratoId_statusPenalidade_idx" ON "Penalidade"("contratoId", "statusPenalidade");

-- CreateIndex
CREATE INDEX "MatrizRiscos_contratoId_nivelRisco_idx" ON "MatrizRiscos"("contratoId", "nivelRisco");

-- CreateIndex
CREATE INDEX "AuditoriaGlobal_entidadeId_statusAuditoria_idx" ON "AuditoriaGlobal"("entidadeId", "statusAuditoria");

-- AddForeignKey
ALTER TABLE "Usuario" ADD CONSTRAINT "Usuario_entidadeId_fkey" FOREIGN KEY ("entidadeId") REFERENCES "Entidade"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Fornecedor" ADD CONSTRAINT "Fornecedor_entidadeId_fkey" FOREIGN KEY ("entidadeId") REFERENCES "Entidade"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CertidaoFornecedor" ADD CONSTRAINT "CertidaoFornecedor_fornecedorId_fkey" FOREIGN KEY ("fornecedorId") REFERENCES "Fornecedor"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CertidaoFornecedor" ADD CONSTRAINT "CertidaoFornecedor_tipoCertidaoId_fkey" FOREIGN KEY ("tipoCertidaoId") REFERENCES "tipo_certidao"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contrato" ADD CONSTRAINT "Contrato_entidadeId_fkey" FOREIGN KEY ("entidadeId") REFERENCES "Entidade"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contrato" ADD CONSTRAINT "Contrato_fornecedorId_fkey" FOREIGN KEY ("fornecedorId") REFERENCES "Fornecedor"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contrato" ADD CONSTRAINT "Contrato_gestorId_fkey" FOREIGN KEY ("gestorId") REFERENCES "Usuario"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FiscalDesignado" ADD CONSTRAINT "FiscalDesignado_contratoId_fkey" FOREIGN KEY ("contratoId") REFERENCES "Contrato"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FiscalDesignado" ADD CONSTRAINT "FiscalDesignado_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OcorrenciaFiscalizacao" ADD CONSTRAINT "OcorrenciaFiscalizacao_contratoId_fkey" FOREIGN KEY ("contratoId") REFERENCES "Contrato"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OcorrenciaFiscalizacao" ADD CONSTRAINT "OcorrenciaFiscalizacao_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CronogramaFisicoFin" ADD CONSTRAINT "CronogramaFisicoFin_contratoId_fkey" FOREIGN KEY ("contratoId") REFERENCES "Contrato"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Penalidade" ADD CONSTRAINT "Penalidade_contratoId_fkey" FOREIGN KEY ("contratoId") REFERENCES "Contrato"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatrizRiscos" ADD CONSTRAINT "MatrizRiscos_contratoId_fkey" FOREIGN KEY ("contratoId") REFERENCES "Contrato"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatrizRiscos" ADD CONSTRAINT "MatrizRiscos_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditoriaGlobal" ADD CONSTRAINT "AuditoriaGlobal_entidadeId_fkey" FOREIGN KEY ("entidadeId") REFERENCES "Entidade"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditoriaGlobal" ADD CONSTRAINT "AuditoriaGlobal_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
