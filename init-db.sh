#!/bin/sh
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER"; do
  echo "PostgreSQL is not ready yet. Waiting..."
  sleep 2
done

echo "PostgreSQL is ready. Checking if flowise database exists..."

# Check if the database exists
DB_EXISTS=$(PGPASSWORD="$DATABASE_PASSWORD" psql -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" -d "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname='$DATABASE_NAME'" 2>/dev/null || echo "0")

if [ "$DB_EXISTS" = "1" ]; then
  echo "Database '$DATABASE_NAME' already exists. Skipping initialization."
else
  echo "Creating database '$DATABASE_NAME'..."
  PGPASSWORD="$DATABASE_PASSWORD" psql -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" -d "$POSTGRES_DB" -c "CREATE DATABASE $DATABASE_NAME;"
  echo "Database '$DATABASE_NAME' created successfully."
fi

# Start Flowise based on MODE
if [ "$MODE" = "worker" ]; then
  echo "Starting Flowise in worker mode..."
  exec flowise worker
else
  echo "Starting Flowise in main mode..."
  exec flowise start
fi