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

docker exec -it --user tpch dbt3_guide-tpch-postgres-1 /tcph/dbt3 build-dbgen pgsql "TPC-H V3.0.1"
docker exec -it --user tpch dbt3_guide-tpch-postgres-1 /tcph/dbt3 run --tpchtools="TPC-H V3.0.1" pgsql results
