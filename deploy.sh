#!/bin/bash

# 1-Click Deployment Script for tgcf on Ubuntu

set -e

echo "Starting tgcf deployment..."

# 1. Update system packages
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# 2. Install Docker and Docker Compose if not present
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
    # If standard docker-compose is needed as a standalone binary (optional for newer docker versions which use 'docker compose')
    # sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    # sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose plugin installed."
else
    echo "Docker Compose is already installed."
fi

# 3. Setup configuration files
echo "Setting up configuration files..."

# Create empty config files if they don't exist to prevent Docker from creating them as directories
if [ ! -f tgcf.config.json ]; then
    echo "{}" > tgcf.config.json
fi

if [ ! -f tgcf.live.json ]; then
    echo "{}" > tgcf.live.json
fi

# 4. Prompt for Password
if [ ! -f .env ]; then
    echo "Enter a password for the tgcf Web UI:"
    read -s PASSWORD
    echo "PASSWORD=$PASSWORD" > .env
    echo "Password saved to .env file."
else
    echo ".env file already exists. Skipping password prompt."
fi

# 5. Build and Run
echo "Building and starting tgcf container..."
sudo docker compose up -d --build

# 6. Final Output
PUBLIC_IP=$(curl -s ifconfig.me)
echo "---------------------------------------------------"
echo "tgcf deployed successfully!"
echo "Access the Web UI at: http://$PUBLIC_IP:8501"
echo "---------------------------------------------------"
