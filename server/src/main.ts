import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  app.enableCors();

  const preferredPort = parseInt(process.env.PORT ?? '3000', 10);

  for (let port = preferredPort; port < preferredPort + 10; port++) {
    try {
      await app.listen(port);
      logger.log(`Server running on http://localhost:${port}`);
      return;
    } catch (err: any) {
      if (err.code === 'EADDRINUSE') {
        logger.warn(`Port ${port} in use, trying ${port + 1}...`);
        continue;
      }
      throw err;
    }
  }
}
bootstrap();
