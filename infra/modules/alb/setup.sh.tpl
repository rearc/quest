#!/bin/bash -e

echo "Installing Docker"

sudo apt-get update -y
sudo apt-get install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo docker stop node-app || true
sudo docker rm node-app || true
sudo docker pull ${docker_image}

sudo docker run -d \
  --name node-app \
  -e SECRET_WORD="${secret_word}" \
  --restart always \
  -p 80:3000 \
  ${docker_image}


echo "Docker containers running:"
sudo docker ps
