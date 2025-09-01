#!/bin/bash
echo "Running service setup scripts..."

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# Run individual setup scripts
./scripts/setup-minio.sh
./scripts/setup-lakefs.sh
./scripts/setup-clearml.sh
./scripts/setup-label-studio.sh

echo "All services setup completed!"