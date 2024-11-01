#!/bin/bash

# This script sets up the IoT stack using Docker Compose.

# Update package list and upgrade all packages
echo "Updating package list..."
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker if not already installed
if ! command -v docker &> /dev/null
then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
else
    echo "Docker is already installed."
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null
then
    echo "Installing Docker Compose..."
    sudo apt-get install -y libffi-dev libssl-dev python3-dev
    sudo apt-get install -y python3-pip
    sudo pip3 install docker-compose
else
    echo "Docker Compose is already installed."
fi

# Create a directory for the IoT Stack project
mkdir -p ~/iot-stack
cd ~/iot-stack

# Create the docker-compose.yml file
cat <<EOF > docker-compose.yml
version: '3'

services:
  mqtt:
    image: eclipse-mosquitto
    container_name: mqtt
    ports:
      - "1883:1883"
    volumes:
      - mosquitto-data:/mosquitto/data
      - mosquitto-config:/mosquitto/config

  influxdb:
    image: influxdb:2.0
    container_name: influxdb
    ports:
      - "8086:8086"
    environment:
      INFLUXDB_DB: "iot_data"
      INFLUXDB_ADMIN_USER: "admin"
      INFLUXDB_ADMIN_PASSWORD: "password"
      INFLUXDB_USER: "user"
      INFLUXDB_USER_PASSWORD: "password"
    volumes:
      - influxdb-data:/var/lib/influxdb2

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: "admin" # Set admin password for Grafana
    depends_on:
      - influxdb
    volumes:
      - grafana-data:/var/lib/grafana

  nodered:
    image: nodered/node-red
    container_name: nodered
    ports:
      - "1880:1880"
    depends_on:
      - mqtt
    volumes:
      - node-red-data:/data

  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    ports:
      - "9000:9000"
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer-data:/data

volumes:
  mosquitto-data:
  mosquitto-config:
  influxdb-data:
  grafana-data:
  node-red-data:
  portainer-data:
EOF

# Start the Docker containers
echo "Starting IoT stack using Docker Compose..."
docker-compose up -d

echo "IoT stack setup completed successfully!"
echo "Access the following services:"
echo " - Mosquitto: mqtt://localhost:1883"
echo " - InfluxDB: http://localhost:8086"
echo " - Grafana: http://localhost:3000 (Admin password: admin)"
echo " - Node-RED: http://localhost:1880"
echo " - Portainer: http://localhost:9000"
