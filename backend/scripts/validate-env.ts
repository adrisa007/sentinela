import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { validationSchema } from '../src/config/validation.schema';

const envExamplePath = path.resolve(__dirname, '../.env.example');

if (!fs.existsSync(envExamplePath)) {
  console.error(`Arquivo .env.example não encontrado em: ${envExamplePath}`);
  process.exit(1);
}

const envContent = fs.readFileSync(envExamplePath, 'utf-8');
const parsed = dotenv.parse(envContent);

const { error } = validationSchema.validate(parsed, { abortEarly: false, allowUnknown: true });

if (error) {
  console.error('\nValidação .env.example falhou:');
  error.details.forEach((d) => {
    console.error(`- ${d.message}`);
  });
  process.exit(1);
}

console.log('Validação .env.example OK.');
