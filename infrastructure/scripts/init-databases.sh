#!/bin/bash
set -e

echo "Creating multiple databases for DevOps infrastructure..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE clearml;
    CREATE DATABASE clearml_events;
    CREATE DATABASE lakefs;
    CREATE DATABASE gitlab;
    CREATE DATABASE sonarqube;
    CREATE DATABASE nexus;
    CREATE DATABASE label_studio;
    GRANT ALL PRIVILEGES ON DATABASE clearml TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE clearml_events TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE lakefs TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE gitlab TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE sonarqube TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE nexus TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE label_studio TO $POSTGRES_USER;
EOSQL

echo "All databases created successfully!"