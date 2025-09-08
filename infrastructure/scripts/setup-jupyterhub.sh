#!/bin/bash
set -e

echo "🔧 Setting up JupyterHub..."

# Wait for JupyterHub to be ready
echo "Waiting for JupyterHub to be ready..."
until curl -s http://localhost:${JUPYTERHUB_PORT:-8000} > /dev/null; do
    sleep 5
done

echo "JupyterHub is ready. Creating admin user..."

# Create admin user
docker compose -f ../docker-composes/docker-compose.jupyterhub.yml exec jupyterhub \
    jupyterhub user add ${JUPYTERHUB_ADMIN_USER:-admin} --password=${JUPYTERHUB_ADMIN_PASSWORD:-jupyterhub123} --admin

echo "✅ JupyterHub setup completed!"