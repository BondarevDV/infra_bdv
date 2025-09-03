#!/bin/bash
set -e

echo "🔧 Setting up Label Studio..."

# Wait for Label Studio to be ready
echo "Waiting for Label Studio to be ready..."
until curl -s http://localhost:8080 > /dev/null; do
    sleep 5
done

echo "Label Studio is ready. Setting up configuration..."

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
until curl -s http://minio:9000/minio/health/live > /dev/null; do
    sleep 2
done

# Create Label Studio S3 storage configuration
cat > ../config/label-studio/s3-storage.json << EOL
{
    "type": "s3",
    "presign": true,
    "prefix": "media",
    "bucket": "label-studio-data",
    "aws_access_key_id": "${MINIO_ROOT_USER}",
    "aws_secret_access_key": "${MINIO_ROOT_PASSWORD}",
    "aws_s3_endpoint": "http://minio:9000",
    "region_name": "us-east-1",
    "s3_client_config": {
        "endpoint_url": "http://minio:9000",
        "aws_access_key_id": "${MINIO_ROOT_USER}",
        "aws_secret_access_key": "${MINIO_ROOT_PASSWORD}"
    }
}
EOL

echo "✅ Label Studio S3 configuration created!"

# Create sample project template
cat > ../config/label-studio/sample-project.json << EOL
{
    "title": "Image Classification Project",
    "description": "Sample project for image classification tasks",
    "label_config": "<View>\\n  <Image name=\\"image\\" value=\\"\\$image\\"/>\\n  <Choices name=\\"label\\" toName=\\"image\\">\\n    <Choice value=\\"Cat\\"/>\\n    <Choice value=\\"Dog\\"/>\\n    <Choice value=\\"Other\\"/>\\n  </Choices>\\n</View>",
    "expert_instruction": "Please classify the image as Cat, Dog or Other animal.",
    "show_instruction": true,
    "show_skip_button": true,
    "enable_empty_annotation": false,
    "show_annotation_history": true,
    "model_version": "1.0"
}
EOL

echo "✅ Sample project template created!"

# Test Label Studio connection
echo "Testing Label Studio connection..."
if curl -s http://localhost:8080 | grep -q "Label Studio"; then
    echo "✅ Label Studio is running successfully!"
else
    echo "❌ Label Studio is not responding correctly"
    exit 1
fi

echo "✅ Label Studio setup completed!"