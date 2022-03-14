# Use Node LTS
FROM node:16

# Create directory for app to live
WORKDIR /usr/src/app

# Install our NPM packages
# To install only production packages,
# set $NODE_ENV to production
COPY package*.json ./
RUN npm install

# Copy our code into the Docker container
COPY . .

# TODO: Make this utilize an env variable
# Make our port that our app uses accessible
EXPOSE 80

# Pass a command to the container to start our application
CMD [ "node", "server.js" ]
