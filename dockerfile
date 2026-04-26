FROM node:20.20.1-alpine AS builder
WORKDIR /app

RUN apk add --no-cache git
RUN git clone https://github.com/charlesaugust44/TorznabScrapper.git .

RUN npm ci
RUN npm run build

FROM node:20.20.1-alpine
WORKDIR /app

COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist

EXPOSE 9118

CMD ["node", "dist/index.js"]