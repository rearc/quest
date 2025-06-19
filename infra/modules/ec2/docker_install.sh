#!/bin/bash -e

echo "Installing Docker from Ubuntu's default repositories..."

# Update package list
sudo apt-get update -y

# Install docker.io (from Ubuntu package repo)
sudo apt-get install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add current user (ubuntu) to docker group
sudo usermod -aG docker ubuntu

echo "Docker (docker.io) installed successfully"
