#!/bin/bash
echo "Setting up Label Studio environment..."

# Wait for services to be ready
echo "Waiting for PostgreSQL, Redis and MinIO..."
sleep 20

# Create MinIO bucket for Label Studio
docker-compose -f docker-composes/docker-compose.data.yml exec minio \
  mc alias set minio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

docker-compose -f docker-composes/docker-compose.data.yml exec minio \
  mc mb minio/${LABEL_STUDIO_S3_BUCKET} || true

docker-compose -f docker-composes/docker-compose.data.yml exec minio \
  mc anonymous set download minio/${LABEL_STUDIO_S3_BUCKET}

echo "MinIO bucket '${LABEL_STUDIO_S3_BUCKET}' created and configured"

# Create default project structure in Label Studio data volume
docker run --rm -v label_studio_data:/data alpine \
  mkdir -p /data/projects /data/export /data/import

echo "Label Studio directories created"

# Create sample configuration
mkdir -p ./config/label-studio
cat > ./config/label-studio/sample_project.json << 'EOL'
{
  "title": "Image Classification Project",
  "description": "Sample project for image classification",
  "label_config": "<View>\n  <Image name=\"image\" value=\"$image\"/>\n  <Choices name=\"label\" toName=\"image\">\n    <Choice value=\"Cat\"/>\n    <Choice value=\"Dog\"/>\n    <Choice value=\"Other\"/>\n  </Choices>\n</View>",
  "expert_instruction": "Please classify the image as Cat, Dog or Other",
  "show_instruction": true,
  "show_skip_button": true,
  "enable_empty_annotation": false,
  "show_annotation_history": true
}
EOL

echo "Label Studio setup completed!"