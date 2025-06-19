FROM node:22-alpine

WORKDIR /app
COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3000

ENV SECRET_WORD="test"

CMD ["npm", "start"]
