#!/bin/bash
set -e

echo "🔧 Setting up Apache Zeppelin..."

# Wait for Zeppelin to be ready
echo "Waiting for Zeppelin to be ready..."
until curl -s http://localhost:${ZEPPELIN_PORT:-8080} > /dev/null; do
    sleep 5
done

echo "Zeppelin is ready. Configuring interpreters..."

# Create sample notebook directory
mkdir -p ../notebooks/zeppelin

# Create sample notebook
cat > ../notebooks/zeppelin/welcome.json << 'EOL'
{
  "name": "Welcome to Zeppelin",
  "paragraphs": [
    {
      "text": "%md\n# Welcome to Apache Zeppelin\n## Multi-language notebook for data analytics\n\nThis is a sample notebook connected to your MLOps stack.",
      "config": {},
      "settings": {}
    },
    {
      "text": "%python\nprint('Hello from Zeppelin!')\nprint('Python interpreter is working correctly')",
      "config": {},
      "settings": {}
    }
  ],
  "config": {},
  "info": {},
  "guiSettings": {
    "fontSize": 14
  }
}
EOL

echo "✅ Zeppelin setup completed!"