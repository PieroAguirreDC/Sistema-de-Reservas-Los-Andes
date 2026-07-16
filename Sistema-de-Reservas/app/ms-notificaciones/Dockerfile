FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
COPY libs/common/ libs/common/
RUN cd libs/common && npm install && npm run build && npm pack

COPY ms-notificaciones/package.json ms-notificaciones/package-lock.json* ms-notificaciones/
RUN cd ms-notificaciones && npm install && npm install ../libs/common/reservas-common-1.0.0.tgz
COPY ms-notificaciones/ ms-notificaciones/
RUN cd ms-notificaciones && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-notificaciones/package.json ms-notificaciones/package-lock.json* ms-notificaciones/
RUN cd ms-notificaciones && npm install --omit=dev && npm install ../libs/common/reservas-common-1.0.0.tgz --omit=dev && npm cache clean --force
COPY --from=builder /app/ms-notificaciones/dist ms-notificaciones/dist
WORKDIR /app/ms-notificaciones
EXPOSE 3000
CMD ["node", "dist/main.js"]
