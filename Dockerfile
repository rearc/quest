FROM node:10

WORKDIR /code

ENV NODE_ENV=development

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "node", "src/000.js"]