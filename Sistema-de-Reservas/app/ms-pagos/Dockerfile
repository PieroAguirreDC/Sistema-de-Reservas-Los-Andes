FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
COPY libs/common/package.json libs/common/
COPY ms-pagos/package.json ms-pagos/package-lock.json* ms-pagos/
RUN cd libs/common && npm install
RUN cd ms-pagos && npm install
COPY libs/common/ libs/common/
COPY ms-pagos/ ms-pagos/
RUN cd libs/common && npm run build
RUN cd ms-pagos && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-pagos/package.json ms-pagos/package-lock.json* ms-pagos/
RUN cd ms-pagos && npm install --omit=dev && npm cache clean --force
COPY --from=builder /app/ms-pagos/dist ms-pagos/dist
WORKDIR /app/ms-pagos
EXPOSE 3000
CMD ["node", "dist/main.js"]
