# Symfony Application Docker Setup

This document describes how to run the Symfony application using Docker.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Build and start the services:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Web application: http://localhost:8080
   - Database: localhost:5432

## Services

### App Service
- **Image**: Built from local Dockerfile
- **Port**: 8080 (host) → 9000 (container)
- **Environment**: Production mode
- **Dependencies**: PostgreSQL database

### Database Service
- **Image**: PostgreSQL 16 Alpine
- **Port**: 5432 (host) → 5432 (container)
- **Database**: `app`
- **User**: `app`
- **Password**: `!ChangeMe!` (change in production)

## Environment Variables

You can customize the setup by creating a `.env` file with the following variables:

```env
POSTGRES_VERSION=16
POSTGRES_DB=app
POSTGRES_USER=app
POSTGRES_PASSWORD=!ChangeMe!
```

## Development

For development, you can override the environment:

```bash
# Development mode
docker-compose -f compose.yaml -f compose.override.yaml up
```

## Production

For production deployment:

1. Update the database password in the environment variables
2. Set `APP_ENV=prod` and `APP_DEBUG=0`
3. Ensure proper SSL/TLS termination
4. Use a reverse proxy (nginx) in front of the PHP-FPM container

## Useful Commands

```bash
# View logs
docker-compose logs -f app

# Execute commands in the container
docker-compose exec app php bin/console cache:clear

# Run database migrations
docker-compose exec app php bin/console doctrine:migrations:migrate

# Access database
docker-compose exec database psql -U app -d app
```

## Troubleshooting

### Permission Issues
If you encounter permission issues with the `var` directory:
```bash
docker-compose exec app chown -R app:app var/
```

### Database Connection Issues
Ensure the database service is running and the connection string is correct:
```bash
docker-compose ps
```

### Cache Issues
Clear the cache if you encounter issues:
```bash
docker-compose exec app php bin/console cache:clear --env=prod
``` 
