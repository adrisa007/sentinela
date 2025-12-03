import { NestFactory } from '@nestjs/core';
import { ConfigModule } from '@nestjs/config';
import { validationSchema } from './config/validation.schema';

// Placeholder AppModule to allow ConfigModule.forRoot; replace with real AppModule when present
import { Module } from '@nestjs/common';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema,
      validationOptions: { abortEarly: false },
    }),
  ],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}

bootstrap();
