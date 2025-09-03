#!/bin/bash
set -e

echo "🔧 Setting up Jenkins agent with ML tools..."

# Install system dependencies
apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    wget \
    curl \
    unzip \
    docker.io

# Create Python virtual environment
python3 -m venv /opt/ml-venv
source /opt/ml-venv/bin/activate

# Install ML packages
pip install --upgrade pip
pip install \
    clearml \
    dvc \
    dvc-s3 \
    boto3 \
    pandas \
    numpy \
    scikit-learn \
    matplotlib \
    tensorflow \
    torch \
    torchvision \
    awscli

# Configure AWS for MinIO
mkdir -p /home/jenkins/.aws

cat > /home/jenkins/.aws/config << EOF
[default]
region = us-east-1
s3 =
    endpoint_url = http://minio:9000
    signature_version = s3v4
EOF

cat > /home/jenkins/.aws/credentials << EOF
[default]
aws_access_key_id = minioadmin
aws_secret_access_key = minioadmin
EOF

# Configure DVC
mkdir -p /home/jenkins/.dvc

cat > /home/jenkins/.dvc/config << EOF
['remote "minio"']
url = s3://dvc-storage
endpointurl = http://minio:9000
access_key_id = minioadmin
secret_access_key = minioadmin
EOF

# Set proper permissions
chown -R jenkins:jenkins /home/jenkins/.aws
chown -R jenkins:jenkins /home/jenkins/.dvc
chown -R jenkins:jenkins /home/jenkins/agent

echo "✅ Jenkins agent setup completed!"