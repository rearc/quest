FROM node:10
ENV SECRET_WORD="SOCK_PUPPET"
COPY ./quest/ /
RUN chmod +x /bin/*
RUN npm install
EXPOSE 3000:3000
CMD ["npm","start"]