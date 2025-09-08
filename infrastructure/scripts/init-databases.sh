#!/bin/bash
set -e

echo "🗄️ Initializing databases..."

# Wait for PostgreSQL to be ready
until pg_isready -h postgres -U ${POSTGRES_USER:-admin}; do
    sleep 2
done

echo "Creating databases..."

# Обновляем список баз данных
databases=("clearml" "clearml_events" "lakefs" "gitlab" "sonarqube" "nexus" "label_studio" "keycloak")

for db in "${databases[@]}"; do
    echo "Creating database: $db"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE DATABASE $db;
        GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;
EOSQL
done

echo "✅ All databases created successfully!"