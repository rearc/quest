#!/bin/bash -e

DOCKER_IMAGE=$1
SECRET_WORD=$2

if [ -z "$DOCKER_IMAGE" ]; then
  echo "Must specify Docker image as the first argument"
  exit 1
fi

if [ -z "$SECRET_WORD" ]; then
  echo "Must specify SECRET_WORD as the second argument"
  exit 1
fi

echo "Provisioning Docker image: $DOCKER_IMAGE"
echo "Using SECRET_WORD: $SECRET_WORD"

# Stop and remove any existing container
sudo docker stop front_end || true
sudo docker rm front_end || true

# Pull the image from Docker Hub
sudo docker pull "$DOCKER_IMAGE"

# Run the container with SECRET_WORD env variable
sudo docker run -d \
  --name front_end \
  --restart always \
  -e SECRET_WORD="$SECRET_WORD" \
  -p 3000:3000 \
  "$DOCKER_IMAGE"

echo "Container 'front_end' is now running with SECRET_WORD"


echo "Installing NGINX..."
sudo apt-get update -y
sudo apt-get install -y nginx

echo "Configuring NGINX reverse proxy..."
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name codexplorer.tech www.codexplorer.tech;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo systemctl restart nginx