import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed...');

  const senhaHash = await bcrypt.hash('SentinelaRoot2025!', 10);
  
  const root = await prisma.usuario.upsert({
    where: { email: 'root@sentinela.app' },
    update: {},
    create: {
      nome: 'Administrador ROOT',
      email: 'root@sentinela.app',
      senha: senhaHash,
      perfil: 'ROOT',
      ativo: true,
      totpEnabled: false,
    },
  });

  console.log('✅ Usuário ROOT criado:', root.email);

  const certidoes = [
    { nome: 'Certidão Negativa de Débitos Trabalhistas (CNDT)', descricao: 'Certidão emitida pela Justiça do Trabalho', obrigatoriaLei: true, validadeDias: 180, urlVerificacao: 'https://www.tst.jus.br/certidao' },
    { nome: 'Certidão Negativa de Débitos Federais (CND)', descricao: 'Certidão emitida pela Receita Federal', obrigatoriaLei: true, validadeDias: 180, urlVerificacao: 'https://www.gov.br/receitafederal' },
    { nome: 'Certidão Negativa Estadual', descricao: 'Certidão de regularidade fiscal estadual', obrigatoriaLei: true, validadeDias: 90, urlVerificacao: null },
    { nome: 'Certidão Negativa Municipal', descricao: 'Certidão de regularidade fiscal municipal', obrigatoriaLei: true, validadeDias: 90, urlVerificacao: null },
    { nome: 'Certidão Negativa de Débitos com FGTS', descricao: 'Certificado de Regularidade do FGTS (CRF)', obrigatoriaLei: true, validadeDias: 180, urlVerificacao: 'https://www.caixa.gov.br' },
    { nome: 'Certidão Negativa de Falência e Recuperação Judicial', descricao: 'Certidão emitida pelo Tribunal de Justiça', obrigatoriaLei: true, validadeDias: 90, urlVerificacao: null },
    { nome: 'Certidão de Regularidade com a Seguridade Social', descricao: 'Certidão Negativa de Débitos Previdenciários', obrigatoriaLei: true, validadeDias: 180, urlVerificacao: 'https://www.gov.br/receitafederal' },
    { nome: 'Certidão de Inexistência de Débitos Ambientais', descricao: 'Certificado emitido pelo órgão ambiental competente', obrigatoriaLei: false, validadeDias: 180, urlVerificacao: null },
    { nome: 'Cadastro Nacional de Empresas Inidôneas e Suspensas (CEIS)', descricao: 'Consulta ao Portal da Transparência', obrigatoriaLei: true, validadeDias: 30, urlVerificacao: 'https://portaldatransparencia.gov.br/sancoes/ceis' },
    { nome: 'Cadastro Nacional de Empresas Punidas (CNEP)', descricao: 'Consulta ao cadastro de empresas punidas pela Lei Anticorrupção', obrigatoriaLei: true, validadeDias: 30, urlVerificacao: 'https://portaldatransparencia.gov.br/sancoes/cnep' },
    { nome: 'Certidão Negativa de Improbidade Administrativa', descricao: 'Consulta ao CNJ', obrigatoriaLei: true, validadeDias: 90, urlVerificacao: 'https://www.cnj.jus.br' },
    { nome: 'Certidão de Regularidade com o TCE/TCU', descricao: 'Certidão de regularidade perante Tribunal de Contas', obrigatoriaLei: false, validadeDias: 180, urlVerificacao: null },
  ];

  for (const certidao of certidoes) {
    await prisma.tipoCertidao.upsert({
      where: { nome: certidao.nome },
      update: {},
      create: certidao,
    });
  }

  console.log('✅ 12 tipos de certidão criados');
  console.log('🎉 Seed concluído!');
  console.log('\n📧 Credenciais ROOT:');
  console.log('   Email: root@sentinela.app');
  console.log('   Senha: SentinelaRoot2025!\n');
}

main()
  .catch((e) => {
    console.error('❌ Erro:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
