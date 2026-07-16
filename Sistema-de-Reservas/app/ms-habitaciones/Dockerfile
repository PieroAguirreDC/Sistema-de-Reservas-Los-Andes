FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
COPY libs/common/package.json libs/common/
COPY ms-habitaciones/package.json ms-habitaciones/package-lock.json* ms-habitaciones/
RUN cd libs/common && npm install
RUN cd ms-habitaciones && npm install
COPY libs/common/ libs/common/
COPY ms-habitaciones/ ms-habitaciones/
RUN cd libs/common && npm run build
RUN cd ms-habitaciones && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-habitaciones/package.json ms-habitaciones/package-lock.json* ms-habitaciones/
RUN cd ms-habitaciones && npm install --omit=dev && npm cache clean --force
COPY --from=builder /app/ms-habitaciones/dist ms-habitaciones/dist
WORKDIR /app/ms-habitaciones
EXPOSE 3000
CMD ["node", "dist/main.js"]
