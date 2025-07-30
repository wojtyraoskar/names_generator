# Docker Setup for Phoenix API

This document describes the Docker setup for the Phoenix API application.

## Overview

The Docker setup includes:
- A PostgreSQL database container
- A Phoenix API application container
- Automatic database migration on startup

## Key Changes

### Database Migration Instead of Creation

The Dockerfile has been updated to use `mix ecto.migrate` instead of `mix ecto.create` for preparing the application. This is because:

1. The database is created by the PostgreSQL container in docker-compose
2. The application should only run migrations, not create the database
3. This follows the principle of separation of concerns

### Release Module

A new `PhoenixApi.Release` module has been created to handle database operations:

- `create_and_migrate/0`: Creates the database if it doesn't exist and runs migrations
- `migrate/0`: Runs migrations only (assumes database exists)
- `rollback/2`: Rolls back migrations to a specific version

### Startup Script

The Dockerfile includes a startup script that:

1. Waits for the database to be ready using `pg_isready`
2. Runs database migrations using the Release module
3. Starts the Phoenix application

## Usage

### Development

To start the application with Docker Compose:

```bash
docker-compose up --build
```

This will:
1. Start a PostgreSQL database container
2. Build and start the Phoenix API container
3. Wait for the database to be ready
4. Run migrations automatically
5. Start the Phoenix server

### Production

For production deployment, ensure the following environment variables are set:

- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY_BASE`: Secret key for Phoenix
- `PHX_HOST`: Hostname for the application
- `PORT`: Port for the application (default: 4000)

## Database Configuration

The application expects a PostgreSQL database with the following default configuration:

- Database: `phoenix_api_prod`
- Username: `postgres`
- Password: `postgres`
- Host: `db` (in Docker Compose) or your database host
- Port: `5432`

## Migration Process

When the container starts:

1. The startup script waits for the database to be available
2. It calls `PhoenixApi.Release.create_and_migrate/0`
3. This function creates the database if it doesn't exist
4. It then runs all pending migrations
5. Finally, it starts the Phoenix application

## Troubleshooting

### Database Connection Issues

If the application can't connect to the database:

1. Check that the PostgreSQL container is running: `docker-compose ps`
2. Verify the database URL in docker-compose.yml
3. Check the logs: `docker-compose logs web`

### Migration Issues

If migrations fail:

1. Check the application logs: `docker-compose logs web`
2. Verify that the database exists and is accessible
3. Check that the database user has the necessary permissions

### Manual Migration

To run migrations manually:

```bash
docker-compose exec web bin/phoenix_api eval "PhoenixApi.Release.migrate"
```

To rollback migrations:

```bash
docker-compose exec web bin/phoenix_api eval "PhoenixApi.Release.rollback(PhoenixApi.Repo, 20250728194019)"
``` 
