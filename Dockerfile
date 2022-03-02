# BASE IMAGE - REARC: Use node as the base image. Version node:10 or later should work.
FROM node:16
LABEL org.opencontainers.image.source="https://github.com/jonfinley/quest"
# APP DIRECTORY
#WORKDIR /usr/src/app

ENV SECRET_WORD=TwelveFactor 
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production
# Bundle app source
COPY . .
# EXPOSE PORT, only use for dev
EXPOSE 3000
# RUN APP
CMD ["npm", "start"]