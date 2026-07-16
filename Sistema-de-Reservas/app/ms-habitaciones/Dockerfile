FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
COPY libs/common/ libs/common/
COPY ms-habitaciones/package.json ms-habitaciones/package-lock.json* ms-habitaciones/
RUN cd libs/common && npm install && npm run build
RUN cd ms-habitaciones && npm install
COPY ms-habitaciones/ ms-habitaciones/
RUN cd ms-habitaciones && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-habitaciones/package.json ms-habitaciones/package-lock.json* ms-habitaciones/
RUN cd ms-habitaciones && npm install --omit=dev && npm cache clean --force
RUN rm -rf ms-habitaciones/node_modules/@reservas/common && cp -r libs/common ms-habitaciones/node_modules/@reservas/common && rm -rf ms-habitaciones/node_modules/@reservas/common/node_modules
COPY --from=builder /app/ms-habitaciones/dist ms-habitaciones/dist
WORKDIR /app/ms-habitaciones
EXPOSE 3000
CMD ["node", "dist/main.js"]
