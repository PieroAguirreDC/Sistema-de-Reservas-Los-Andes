FROM node:22-alpine AS builder
# Force rebuild 1
WORKDIR /app
COPY libs/common/package.json libs/common/
COPY ms-reservas/package.json ms-reservas/package-lock.json* ms-reservas/
RUN cd libs/common && npm install
RUN cd ms-reservas && npm install
COPY libs/common/ libs/common/
COPY ms-reservas/ ms-reservas/
RUN cd libs/common && npm run build
RUN cd ms-reservas && npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/libs/common/ libs/common/
COPY ms-reservas/package.json ms-reservas/package-lock.json* ms-reservas/
RUN cd ms-reservas && npm install --omit=dev && npm cache clean --force
COPY --from=builder /app/ms-reservas/dist ms-reservas/dist
WORKDIR /app/ms-reservas
EXPOSE 3000
CMD ["node", "dist/main.js"]
