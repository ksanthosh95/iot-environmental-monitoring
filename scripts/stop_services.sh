#!/bin/bash

# Navigate to the directory containing the docker-compose.yml
cd /path/to/your/project

# Stop Docker containers
echo "Stopping services..."
docker-compose down

echo "All services have been stopped."
