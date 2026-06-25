# Sistema de Reservas de Habitaciones — Hotel Los Andes

Curso: Infraestructura como Código

## Integrantes

- Piero Aguirre
- Rodrigo Baldeon
- Grezia

---

## Descripción

Sistema de reservas de habitaciones para una cadena hotelera, desarrollado con infraestructura como código (Terraform) en AWS y una API REST con NestJS + TypeORM, frontend con Next.js, y contenedores Docker desplegados en ECS Fargate.

---

## Estructura del Proyecto

```
Sistema-de-Reservas/
├── iac/
│   ├── vpc/
│   ├── security/
│   ├── api-gateway/
│   ├── alb/
│   ├── ecs-fargate/
│   ├── messaging/
│   ├── rds/
│   ├── elasticache/
│   ├── monitoring/
│   └── environments/
│       ├── dev/
│       └── prod/
└── app/
    ├── api/              # NestJS + TypeORM
    │   └── src/
    │       ├── ms-reservas/
    │       ├── ms-habitaciones/
    │       ├── ms-usuarios/
    │       ├── ms-pagos/
    │       ├── ms-notificaciones/
    │       └── common/
    └── web/              # Next.js + Tailwind
        └── src/
            ├── pages/
            ├── components/
            ├── services/
            └── store/
```

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| IaC | Terraform >= 1.6.0 |
| Cloud | AWS (VPC, ECS Fargate, RDS Aurora, ElastiCache Redis, SQS/SNS, API Gateway, ALB) |
| API | NestJS 11 + TypeORM + PostgreSQL |
| Frontend | Next.js + TypeScript + Tailwind CSS |
| Contenedores | Docker + ECR |
| Base de datos | Aurora PostgreSQL 15 |
| Caché | Redis 7 (ElastiCache) |
| Mensajería | SQS + SNS |

---

## Módulos IaC

### VPC
Red principal del proyecto. Define subnets públicas, privadas de app y privadas de DB, tablas de enrutamiento y VPC Endpoints.

### Security
Security Groups, KMS y Secrets Manager para cifrado y gestión de credenciales.

### RDS
Aurora PostgreSQL Multi-AZ con instancia primary (escritura) y standby (lectura), RDS Proxy para pool de conexiones y AWS Backup.

### ElastiCache
Redis 7 con replication group (primary + 1 replica) para failover automático sin duplicar costos.

### Messaging
SQS + SNS para comunicación asíncrona entre microservicios, incluyendo Dead Letter Queues (DLQ) para manejo de mensajes fallidos.

### ALB
Application Load Balancer que distribuye tráfico hacia los servicios ECS Fargate.

### ECS Fargate
Cómputo serverless para los contenedores Docker de la API y el frontend.

### API Gateway
Exposición de servicios al exterior.

### Monitoring
CloudWatch con alarmas y logs para observabilidad.

---

## Flujo de Ramas Git

```
feature/iac/<modulo>  →  developer  →  main
feature/app/<modulo>  →  developer  →  main
```

---

## Comandos Importantes

### Git — Flujo de trabajo

```bash
# Crear rama de trabajo
git checkout developer
git pull origin developer
git checkout -b feature/<tipo>/<modulo>

# Subir rama al repo
git push origin feature/<tipo>/<modulo>

# Merge a developer
git checkout developer
git pull origin developer
git merge feature/<tipo>/<modulo>
git push origin developer

# Merge a main
git checkout main
git pull origin main
git merge developer
git push origin main

# Renombrar rama
git branch -m nombre-viejo nombre-nuevo
git push origin nombre-nuevo
git push origin --delete nombre-viejo

# Jalar cambios del compañero
git checkout developer
git pull origin developer

# Descartar cambios locales antes de merge
git checkout -- .
git merge developer
```

### Git — Mantenimiento

```bash
# Quitar node_modules y dist del tracking
git rm -r --cached node_modules
git rm -r --cached dist
git commit -m "chore: remove node_modules and dist from tracking"

# Guardar cambios temporalmente
git stash
```

### Terraform — Por módulo

```bash
cd iac/<modulo>
terraform init
terraform validate
terraform fmt -check
terraform plan -var-file="test.tfvars"

# Borrar test.tfvars antes de commitear
Remove-Item test.tfvars
```

### Terraform — Entorno completo

```bash
cd iac/environments/dev
terraform plan -var-file="terraform.tfvars"
```

### NestJS — API

```bash
# Instalar NestJS CLI
npm install -g @nestjs/cli

# Crear proyecto
nest new api --skip-git

# Instalar dependencias
npm install @nestjs/typeorm typeorm pg
npm install @nestjs/config

# Compilar
npm run build

# Correr en desarrollo en local
npm run start:dev
```

### NestJS — API - Ejecución en otro entorno local

```bash
# Instalar NestJS CLI
npm install -g @nestjs/cli

# Compilar
npm run build

# Levantar la imagen de la API con la BD
docker compose up --build
```

### Next.js — Frontend

```bash
# Crear proyecto
npx create-next-app@latest web --typescript --tailwind --eslint
```

### Docker

```bash
# Build imagen API
docker build -t api .

# Build imagen Web
docker build -t web .

# Levantar todo en local
docker-compose up
```

---

## Variables de Entorno

### API (`app/api/.env`)

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=reservas_db
NODE_ENV=development
PORT=3000
```

### Web (`app/web/.env.local`)

```env
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1
NEXT_PUBLIC_USE_MOCK=true
```

---

## Módulos API (NestJS)

| Módulo | Ruta base | Descripción |
|---|---|---|
| ms-reservas | `/api/v1/reservas` | CRUD de reservas |
| ms-habitaciones | `/api/v1/habitaciones` | CRUD de habitaciones |
| ms-usuarios | `/api/v1/usuarios` | CRUD de usuarios |
| ms-pagos | `/api/v1/pagos` | CRUD de pagos |
| ms-notificaciones | `/api/v1/notificaciones` | Notificaciones a usuarios |

---

## Fases de Despliegue

**Fase 1 — Infraestructura Base:** VPC → Security → RDS → ElastiCache → Messaging

**Fase 2 — Desarrollo Local:** API NestJS + Frontend Next.js + docker-compose

**Fase 3 — Cómputo:** ECS Fargate → ALB → API Gateway → Monitoring

**Fase 4 — Entornos:** environments/dev → environments/prod

---

## Notas Importantes

- El campo `password` en `aws_secretsmanager_secret_version` debe cambiarse antes del `terraform apply` en producción.
- El puerto 3000 en el SG de ECS corresponde al puerto de los microservicios NestJS.
- `synchronize: true` en TypeORM solo debe usarse en desarrollo, nunca en producción.
- Los archivos `dist/` y `node_modules/` no se suben al repositorio (ver `.gitignore`).
- Los archivos `test.tfvars` y `.terraform/` no se suben al repositorio.
