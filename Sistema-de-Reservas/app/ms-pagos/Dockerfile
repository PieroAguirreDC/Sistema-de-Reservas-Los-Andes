FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
COPY libs/common/ libs/common/
COPY ms-pagos/package.json ms-pagos/package-lock.json* ms-pagos/
RUN cd libs/common && npm install && npm run build
RUN cd ms-pagos && npm install
COPY ms-pagos/ ms-pagos/
RUN cd ms-pagos && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-pagos/package.json ms-pagos/package-lock.json* ms-pagos/
RUN cd ms-pagos && npm install --omit=dev && npm cache clean --force
RUN rm -rf ms-pagos/node_modules/@reservas/common && cp -r libs/common ms-pagos/node_modules/@reservas/common && rm -rf ms-pagos/node_modules/@reservas/common/node_modules
COPY --from=builder /app/ms-pagos/dist ms-pagos/dist
WORKDIR /app/ms-pagos
EXPOSE 3000
CMD ["node", "dist/main.js"]
