FROM --platform=linux/amd64 node:25



ENV NODE_ENV=production
ENV PORT=3000

# group, user
RUN useradd -s /bin/bash -U -d /quest -m quest
USER quest

WORKDIR /quest

COPY package*json ./
COPY bin bin
COPY src src

RUN npm ci --omit=dev

EXPOSE $PORT
ENTRYPOINT ["npm", "start"]
