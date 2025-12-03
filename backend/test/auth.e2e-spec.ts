import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Auth (e2e)', () => {
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

  describe('POST /auth/totp/setup', () => {
    it('should return 401 without authentication', () => {
      return request(app.getHttpServer())
        .post('/auth/totp/setup')
        .expect(401);
    });
  });

  describe('POST /auth/totp/verify', () => {
    it('should return 401 without authentication', () => {
      return request(app.getHttpServer())
        .post('/auth/totp/verify')
        .send({ token: '123456' })
        .expect(401);
    });
  });

  describe('GET /api/csrf-token', () => {
    it('should return CSRF token', () => {
      return request(app.getHttpServer())
        .get('/api/csrf-token')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('csrfToken');
        });
    });
  });
});
