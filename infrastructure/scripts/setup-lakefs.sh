#!/bin/bash
set -e

echo "🔧 Setting up LakeFS..."

# Wait for LakeFS to be ready
echo "Waiting for LakeFS to be ready..."
until curl -s http://lakefs:8000/_health > /dev/null; do
    sleep 2
done

echo "LakeFS is ready. Setting up repositories..."

# Setup LakeFS credentials
echo "Setting up LakeFS admin credentials..."
curl -X POST http://localhost:8000/api/v1/setup_lakefs \
    -H "Content-Type: application/json" \
    -d '{
        "username": "admin",
        "key": {
            "accessKeyId": "AKIAIOSFODNN7EXAMPLE",
            "secretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
        }
    }' || echo "Setup may already be completed"

# Get authentication token
echo "Getting authentication token..."
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{
        "accessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "secretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }' | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "❌ Failed to get LakeFS token"
    exit 1
fi

# Create repositories
repositories=("ml-data" "models" "datasets" "experiments")

for repo in "${repositories[@]}"; do
    echo "Creating repository: $repo"
    
    curl -X POST http://localhost:8000/api/v1/repositories \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        -d "{
            \"name\": \"${repo}\",
            \"storage_namespace\": \"local://${repo}\",
            \"default_branch\": \"main\",
            \"sample_data\": true
        }" || echo "Repository $repo may already exist"
done

echo "✅ LakeFS setup completed! Repositories:"
curl -s http://localhost:8000/api/v1/repositories \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.results[].id'