#!/bin/bash
set -e

echo "🔧 Setting up ClearML..."

# Wait for ClearML server to be ready
echo "Waiting for ClearML server to be ready..."
until curl -s http://clearml-server:8008 > /dev/null; do
    sleep 5
done

echo "ClearML server is ready. Setting up configuration..."

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until docker compose -f ../docker-composes/docker-compose.postgres.yml exec postgres pg_isready -U admin; do
    sleep 2
done

# Create ClearML configuration file
cat > ../config/clearml.conf << EOL
# ClearML Server Configuration
api {
    # Web server configuration
    host: "0.0.0.0"
    port: 8008
    base_url: "http://localhost:8008"
    
    # Database configuration
    db {
        driver: postgresql
        host: "postgres"
        port: 5432
        name: "clearml"
        user: "${POSTGRES_USER}"
        pass: "${POSTGRES_PASSWORD}"
    }
    
    # Elasticsearch configuration
    elastic {
        host: "elasticsearch"
        port: 9200
    }
    
    # File server configuration
    files {
        host: "clearml-fileserver"
        port: 8081
    }
}

# Redis configuration
redis {
    host: "redis"
    port: 6379
}
EOL

echo "✅ ClearML configuration created!"

# Test ClearML connection
echo "Testing ClearML connection..."
if curl -s http://localhost:8008 | grep -q "ClearML"; then
    echo "✅ ClearML is running successfully!"
else
    echo "❌ ClearML is not responding correctly"
    exit 1
fi

echo "✅ ClearML setup completed!"