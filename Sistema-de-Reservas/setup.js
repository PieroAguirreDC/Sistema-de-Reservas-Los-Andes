const fs = require('fs');
const path = require('path');

const services = ['ms-reservas', 'ms-pagos', 'ms-notificaciones'];
const baseDir = path.join(__dirname, 'app');

services.forEach(svc => {
  const svcDir = path.join(baseDir, svc);
  
  // package.json
  let dependencies = {
    '@nestjs/common': '^11.0.1',
    '@nestjs/config': '^4.0.4',
    '@nestjs/core': '^11.0.1',
    '@nestjs/passport': '^11.0.5',
    '@nestjs/platform-express': '^11.0.1',
    '@nestjs/typeorm': '^11.0.2',
    '@reservas/common': 'file:../libs/common',
    'jwks-rsa': '^3.1.0',
    'passport': '^0.7.0',
    'passport-jwt': '^4.0.1',
    'pg': '^8.22.0',
    'reflect-metadata': '^0.2.2',
    'rxjs': '^7.8.1',
    'typeorm': '^1.0.0'
  };

  if (svc === 'ms-reservas' || svc === 'ms-pagos') {
    dependencies['@aws-sdk/client-sns'] = '^3.1078.0';
  }
  if (svc === 'ms-notificaciones') {
    dependencies['@aws-sdk/client-sqs'] = '^3.1078.0';
  }

  const pkg = {
    name: svc,
    version: '1.0.0',
    private: true,
    scripts: {
      build: 'nest build',
      start: 'nest start',
      'start:dev': 'nest start --watch',
      'start:prod': 'node dist/main.js'
    },
    dependencies,
    devDependencies: {
      '@nestjs/cli': '^11.0.0',
      '@types/passport-jwt': '^4.0.1',
      '@types/node': '^24.0.0',
      typescript: '^5.7.3'
    }
  };
  fs.writeFileSync(path.join(svcDir, 'package.json'), JSON.stringify(pkg, null, 2));

  // tsconfig.json
  const tsconfig = {
    compilerOptions: {
      module: 'nodenext',
      moduleResolution: 'nodenext',
      resolvePackageJsonExports: true,
      esModuleInterop: true,
      isolatedModules: true,
      declaration: true,
      removeComments: true,
      emitDecoratorMetadata: true,
      experimentalDecorators: true,
      allowSyntheticDefaultImports: true,
      target: 'ES2023',
      sourceMap: true,
      outDir: './dist',
      incremental: true,
      skipLibCheck: true,
      strictNullChecks: true,
      noImplicitAny: false,
      strictBindCallApply: false,
      noFallthroughCasesInSwitch: false
    }
  };
  fs.writeFileSync(path.join(svcDir, 'tsconfig.json'), JSON.stringify(tsconfig, null, 2));

  // tsconfig.build.json
  const tsconfigBuild = {
    extends: './tsconfig.json',
    exclude: ['node_modules', 'dist', '**/*spec.ts']
  };
  fs.writeFileSync(path.join(svcDir, 'tsconfig.build.json'), JSON.stringify(tsconfigBuild, null, 2));

  // nest-cli.json
  const nestcli = {
    '$schema': 'https://json.schemastore.org/nest-cli',
    collection: '@nestjs/schematics',
    sourceRoot: 'src',
    compilerOptions: { deleteOutDir: true }
  };
  fs.writeFileSync(path.join(svcDir, 'nest-cli.json'), JSON.stringify(nestcli, null, 2));

  // Dockerfile
  const dockerfile = `FROM node:22-alpine AS builder
WORKDIR /app
COPY libs/common/package.json libs/common/
COPY ${svc}/package.json ${svc}/package-lock.json* ${svc}/
RUN cd libs/common && npm install
RUN cd ${svc} && npm install
COPY libs/common/ libs/common/
COPY ${svc}/ ${svc}/
RUN cd ${svc} && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ${svc}/package.json ${svc}/package-lock.json* ${svc}/
RUN cd ${svc} && npm install --omit=dev && npm cache clean --force
COPY --from=builder /app/${svc}/dist ${svc}/dist
WORKDIR /app/${svc}
EXPOSE 3000
CMD ["node", "dist/main.js"]
`;
  fs.writeFileSync(path.join(svcDir, 'Dockerfile'), dockerfile);

  // src/main.ts
  const mainTs = `import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');
  app.enableCors();
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
`;
  fs.writeFileSync(path.join(svcDir, 'src', 'main.ts'), mainTs);

  // src/health/health.controller.ts
  fs.mkdirSync(path.join(svcDir, 'src', 'health'), { recursive: true });
  const healthTs = `import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  check() { return { status: 'ok', service: '${svc}' }; }
}
`;
  fs.writeFileSync(path.join(svcDir, 'src', 'health', 'health.controller.ts'), healthTs);

  // src/app.module.ts
  const domainName = svc.replace('ms-', '');
  let domainNameTitle = domainName.charAt(0).toUpperCase() + domainName.slice(1);
  let entityName = domainNameTitle;
  if (domainName === 'habitaciones') entityName = 'Habitacion';
  if (domainName === 'notificaciones') entityName = 'Notificacion';
  if (domainName === 'reservas') entityName = 'Reserva';
  if (domainName === 'pagos') entityName = 'Pago';

  const appModuleTs = `import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PassportModule } from '@nestjs/passport';
import { ${domainNameTitle}Module } from './${domainName}/${domainName}.module.js';
import { HealthController } from './health/health.controller.js';
import { ${entityName} } from './${domainName}/entities/${domainName.slice(0, -1)}.entity.js';
import { JwtStrategy } from '@reservas/common';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME || 'reservas_db',
      entities: [${entityName}],
      synchronize: process.env.NODE_ENV !== 'production',
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    }),
    ${domainNameTitle}Module,
  ],
  controllers: [HealthController],
  providers: [JwtStrategy],
})
export class AppModule {}
`;
  fs.writeFileSync(path.join(svcDir, 'src', 'app.module.ts'), appModuleTs);
});
console.log('Archivos generados correctamente');
