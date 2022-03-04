FROM node:12
#ENV NODE_ENV=SECRET_WORD
WORKDIR /app 
#Install app dependecies
COPY package.json ./
#Bundle app source
RUN npm install
#COPY . .
COPY . /app

ENV secret_word = Debug

EXPOSE 3000

CMD ["node","src/000.js"]


# docker build -t nodeimage .
# docker build -f /path/to/a/Dockerfile .
# docker images
# docker run -dp 3000:3000 nodeimage
# docker exec -it bash
# docker run -v %c%\src:/app/src -d -p 3000:30000 nodeimage
# docker run -e CHOKIDAR_USEPOLLING=true -v %c%\src:/app/src -d -p 3000:30000 nodeimage