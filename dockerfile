FROM node:12

WORKDIR /app 

ENV SECRET_WORD=Debug

COPY package.json ./

RUN npm install

COPY . /app

EXPOSE 3000

CMD ["node","src/000.js"]


# docker build -t imagename .
# docker build -f /path/to/a/Dockerfile .
# docker images
# docker run -dp 3000:3000 Imagename
# docker exec -it containerID bash
# docker run -v %c%\src:/app/src -d -p 3000:30000 imagename
# docker run -e CHOKIDAR_USEPOLLING=true -v %c%\src:/app/src -d -p 3000:30000 imagename
# docker container run --rm -e SECRET_WORD="Debug" imagequest
