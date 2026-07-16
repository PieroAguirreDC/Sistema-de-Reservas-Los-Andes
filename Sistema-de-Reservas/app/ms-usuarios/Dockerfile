FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
# Copiar libs/common primero para aprovechar cache de Docker
COPY libs/common/package.json libs/common/
COPY ms-usuarios/package.json ms-usuarios/package-lock.json* ms-usuarios/
RUN cd libs/common && npm install
RUN cd ms-usuarios && npm install
COPY libs/common/ libs/common/
COPY ms-usuarios/ ms-usuarios/
RUN cd libs/common && npm run build
RUN cd ms-usuarios && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-usuarios/package.json ms-usuarios/package-lock.json* ms-usuarios/
RUN cd ms-usuarios && npm install --omit=dev && npm cache clean --force
COPY --from=builder /app/ms-usuarios/dist ms-usuarios/dist
WORKDIR /app/ms-usuarios
EXPOSE 3000
CMD ["node", "dist/main.js"]
