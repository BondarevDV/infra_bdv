#!/bin/bash
set -e

echo "🚀 Starting full service setup..."
echo "=========================================="

# Load environment variables
if [ -f ../.env ]; then
    export $(grep -v '^#' ../.env | xargs)
    echo "✅ Environment variables loaded"
else
    echo "❌ .env file not found"
    exit 1
fi

# Wait for core services to be ready
echo "Waiting for core services to be ready..."
sleep 20

# Run setup scripts in order
SCRIPTS=(
    "setup-minio.sh"
    "setup-lakefs.sh" 
    "setup-clearml.sh"
    "setup-label-studio.sh"
)

for script in "${SCRIPTS[@]}"; do
    echo ""
    echo "=========================================="
    echo "Running: $script"
    echo "=========================================="
    
    if [ -f "./$script" ]; then
        bash "./$script"
        echo "✅ $script completed successfully"
    else
        echo "❌ Script $script not found"
        exit 1
    fi
    
    sleep 3
done

echo ""
echo "=========================================="
echo "🎉 All services setup completed!"
echo "=========================================="
echo ""
echo "📊 Service Status:"
echo "MinIO:          http://localhost:9001 (admin:minioadmin)"
echo "LakeFS:         http://localhost:8000 (admin:AKIAIOSFODNN7EXAMPLE)"
echo "ClearML:        http://localhost:8008"
echo "Label Studio:   http://localhost:8080 (admin@labelstudio.com:labelstudio123)"
echo "Jenkins:        http://localhost:8080"
echo "GitLab:         http://localhost:8082 (root:gitlabpassword123)"
echo ""
echo "✅ Setup completed successfully!"