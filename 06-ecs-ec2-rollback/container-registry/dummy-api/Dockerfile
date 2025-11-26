FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

EXPOSE 3000

ARG CRASH=false

ENV CRASH=${CRASH}

CMD ["node", "index.js"]