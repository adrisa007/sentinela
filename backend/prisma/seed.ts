import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // 1. Criar usuário ROOT (acesso total de governança)
  const rootPassword = await bcrypt.hash('SentinelaRoot2025!', 12);

  const rootUser = await prisma.usuario.upsert({
    where: { email: 'root@sentinela.app' },
    update: {},
    create: {
      nome: 'Administrador Master',
      cpf: '00000000000',
      email: 'root@sentinela.app',
      senhaHash: rootPassword,
      perfil: 'ROOT',
      ativo: true,
      totpEnabled: false,
    },
  });

  console.log('ROOT criado →', rootUser.email);

  // 2. Tipos de certidão obrigatórias (Lei 14.133/2021)
  const tiposCertidao = [
    { codigo: 'CND_FEDERAL', nome: 'Certidão Negativa Federal (RFB + PGFN)', prazoValidadeDias: 180, apiDisponivel: true },
    { codigo: 'CRT_TRABALHISTA', nome: 'Certidão Negativa Trabalhista (TST)', prazoValidadeDias: 180, apiDisponivel: true },
    { codigo: 'CRF_FGTS', nome: 'Certidão Regularidade FGTS (CAIXA)', prazoValidadeDias: 180, apiDisponivel: true },
    { codigo: 'CND_ESTADUAL', nome: 'Certidão Estadual (SEFAZ)', prazoValidadeDias: 120, apiDisponivel: false },
    { codigo: 'CND_MUNICIPAL', nome: 'Certidão Municipal', prazoValidadeDias: 90, apiDisponivel: false },
    { codigo: 'CERT_FALENCIA', nome: 'Certidão de Falência/Recuperação', prazoValidadeDias: 30, apiDisponivel: false },
    { codigo: 'CEIS', nome: 'Cadastro de Expulsos (CEIS)', prazoValidadeDias: 0, apiDisponivel: true },
    { codigo: 'CNEP', nome: 'Cadastro Nacional Empresas Punidas', prazoValidadeDias: 0, apiDisponivel: true },
    { codigo: 'CADE', nome: 'Cadastro de Inidôneos (CADE)', prazoValidadeDias: 0, apiDisponivel: true },
    { codigo: 'CND_INSS', nome: 'Certidão Negativa INSS', prazoValidadeDias: 180, apiDisponivel: true },
    { codigo: 'CND_DIVIDA_ATIVA', nome: 'Certidão Dívida Ativa União', prazoValidadeDias: 180, apiDisponivel: true },
    { codigo: 'FGTS_FG', nome: 'Certidão FGTS (Fundo Garantia)', prazoValidadeDias: 30, apiDisponivel: true },
  ];

  for (const tipo of tiposCertidao) {
    await prisma.tipoCertidao.upsert({
      where: { codigo: tipo.codigo },
      update: {},
      create: tipo,
    });
  }

  console.log(`${tiposCertidao.length} tipos de certidão criados com sucesso!`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });