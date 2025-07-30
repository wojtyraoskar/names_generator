#!/bin/bash
set -e

echo "Waiting for database..."
until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; do
  echo "Database is unavailable - sleeping"
  sleep 2
done

echo "Database is up - running migrations..."
bin/phoenix_api eval "PhoenixApi.Release.migrate"

echo "Starting application..."
exec bin/phoenix_api start 
