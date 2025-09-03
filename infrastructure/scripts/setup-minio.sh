#!/bin/bash
set -e

echo "🔧 Setting up MinIO buckets and policies..."

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
until curl -s http://minio:9000/minio/health/live > /dev/null; do
    sleep 2
done

echo "MinIO is ready. Setting up buckets..."

# Configure MinIO client
docker compose -f ../docker-composes/docker-compose.data.yml exec minio \
    mc alias set minio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# Create buckets
buckets=("dvc-storage" "ml-data" "label-studio-data" "models" "datasets" "artifacts")

for bucket in "${buckets[@]}"; do
    echo "Creating bucket: $bucket"
    docker compose -f ../docker-composes/docker-compose.data.yml exec minio \
        mc mb minio/$bucket || true
    
    # Set public read policy for some buckets
    if [[ "$bucket" == "datasets" || "$bucket" == "models" ]]; then
        docker compose -f ../docker-composes/docker-compose.data.yml exec minio \
            mc anonymous set download minio/$bucket
    fi
done

# Create bucket policies
echo "Configuring bucket policies..."

# DVC bucket policy
docker compose -f ../docker-composes/docker-compose.data.yml exec minio \
    mc anonymous set download minio/dvc-storage

# ML data bucket policy
docker compose -f ../docker-composes/docker-compose.data.yml exec minio \
    mc anonymous set upload minio/ml-data

echo "✅ MinIO setup completed! Buckets created:"
docker compose -f ../docker-composes/docker-compose.data.yml exec minio \
    mc ls minio