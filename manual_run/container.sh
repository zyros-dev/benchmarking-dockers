#!/bin/bash

# Build the Docker image without removing existing containers
echo "Building Docker image..."
docker compose build --no-cache=false

# Remove existing container (only if necessary)
echo "Removing existing container (if exists)..."
docker compose rm -f --stop --volumes

# Run the Docker container in detached mode
echo "Running Docker container..."
docker compose up -d

# Wait for PostgreSQL to initialize (add a 10-second delay)
echo "Waiting for PostgreSQL to initialize..."
sleep 3

# Check if the container is running
echo "Checking container status..."
while ! docker compose exec tpch-postgres pg_isready; do
  echo "PostgreSQL container not ready, waiting..."
  sleep 2
done

# Run the TPC-H benchmark
echo "Running TPC-H benchmark..."
docker compose exec tpch-postgres /tpch/run-tpch.sh

# Copy the results file from the container
echo "Copying results file..."
docker compose exec tpch-postgres cat /tmp/results.txt >./results.txt

echo "Benchmark complete. Results saved to results.txt"
