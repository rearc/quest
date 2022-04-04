FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY ./src/*.js ./
COPY ./bin/* ./bin/

EXPOSE 3000

CMD [ "node", "000.js" ]
