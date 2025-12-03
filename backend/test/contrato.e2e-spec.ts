import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Contrato (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('Contrato endpoints', () => {
    it('should require authentication for contrato operations', () => {
      // Testa que endpoints de contrato requerem autenticação
      // Quando os endpoints forem implementados, atualizar esses testes
      return request(app.getHttpServer())
        .get('/contratos')
        .expect(404); // 404 porque a rota ainda não existe
    });

    it('should return 404 for non-existent contract', () => {
      return request(app.getHttpServer())
        .get('/contratos/999999')
        .expect(404);
    });
  });
});
