# =============================================================================
# DOCKER SETUP FOR PHOENIX API
# =============================================================================
# This document explains how to run your Phoenix API application using Docker.
# The setup includes the web application and PostgreSQL database.

## =============================================================================
## PREREQUISITES
## =============================================================================
# Before you can use this Docker setup, you need to have Docker and Docker Compose installed:
# - Docker Desktop (for Windows/Mac) or Docker Engine (for Linux)
# - Docker Compose (usually included with Docker Desktop)

## =============================================================================
## QUICK START
## =============================================================================

### 1. Build and Start the Application
```bash
# Navigate to the phoenix_api directory
cd phoenix_api

# Build and start all services (web app + database)
docker-compose up --build
```

### 2. Access Your Application
- **Phoenix API**: http://localhost:4000
- **Health Check**: http://localhost:4000/api/health
- **Database**: localhost:5432 (PostgreSQL)

### 3. Stop the Application
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (this will delete your database data)
docker-compose down -v
```

## =============================================================================
## DETAILED USAGE
## =============================================================================

### Building the Docker Image
```bash
# Build the image manually (if needed)
docker build -t phoenix_api .

# Run the container manually
docker run -p 4000:4000 phoenix_api
```

### Running with Docker Compose
```bash
# Start in background (detached mode)
docker-compose up -d

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f web
docker-compose logs -f db

# Stop services
docker-compose down

# Restart services
docker-compose restart
```

### Database Operations
```bash
# Access the database directly
docker-compose exec db psql -U postgres -d phoenix_api_prod

# Run database migrations
docker-compose exec web bin/phoenix_api eval "PhoenixApi.Release.migrate"

# Reset the database
docker-compose exec web bin/phoenix_api eval "PhoenixApi.Release.reset"
```

## =============================================================================
## ENVIRONMENT VARIABLES
## =============================================================================
# You can customize the application by setting these environment variables:

### Database Configuration
- `DATABASE_URL`: PostgreSQL connection string
- `POOL_SIZE`: Database connection pool size (default: 10)

### Phoenix Configuration
- `MIX_ENV`: Environment (prod/dev/test)
- `PORT`: Port the application runs on (default: 4000)
- `PHX_HOST`: Hostname for the application
- `SECRET_KEY_BASE`: Secret key for session encryption

### Example: Custom Environment Variables
```bash
# Create a .env file with custom settings
echo "SECRET_KEY_BASE=your_secure_secret_key_here" > .env
echo "POOL_SIZE=20" >> .env

# Run with custom environment
docker-compose --env-file .env up
```

## =============================================================================
## TROUBLESHOOTING
## =============================================================================

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using port 4000
lsof -i :4000

# Use a different port
docker-compose up -p 4001:4000
```

#### 2. Database Connection Issues
```bash
# Check if database is running
docker-compose ps

# View database logs
docker-compose logs db

# Restart database
docker-compose restart db
```

#### 3. Application Won't Start
```bash
# Check application logs
docker-compose logs web

# Rebuild the application
docker-compose build --no-cache web
docker-compose up web
```

#### 4. Permission Issues
```bash
# If you get permission errors, ensure Docker has proper permissions
sudo usermod -aG docker $USER
# Then log out and log back in
```

## =============================================================================
## DEVELOPMENT WORKFLOW
## =============================================================================

### Making Code Changes
1. Edit your Phoenix code
2. Rebuild the Docker image: `docker-compose build web`
3. Restart the service: `docker-compose up web`

### Running Tests
```bash
# Run tests in the container
docker-compose exec web mix test

# Run tests with coverage
docker-compose exec web mix test --cover
```

### Adding Dependencies
1. Add dependencies to `mix.exs`
2. Rebuild the image: `docker-compose build web`
3. Restart: `docker-compose up web`

## =============================================================================
## PRODUCTION DEPLOYMENT
## =============================================================================

### Security Considerations
1. **Change Default Passwords**: Update database passwords in production
2. **Secure Secret Key**: Generate a secure `SECRET_KEY_BASE`
3. **Use HTTPS**: Configure SSL/TLS in production
4. **Network Security**: Use Docker networks to isolate services

### Production Environment Variables
```bash
# Generate a secure secret key
mix phx.gen.secret

# Set production environment variables
export SECRET_KEY_BASE="your_generated_secret_key"
export DATABASE_URL="postgres://user:password@host:5432/database"
export PHX_HOST="your-domain.com"
```

### Docker Production Commands
```bash
# Build for production
docker build -t phoenix_api:prod .

# Run in production
docker run -d \
  -p 4000:4000 \
  -e SECRET_KEY_BASE="your_secret" \
  -e DATABASE_URL="your_db_url" \
  phoenix_api:prod
```

## =============================================================================
## FILE STRUCTURE
## =============================================================================
```
phoenix_api/
├── Dockerfile              # Multi-stage Docker build
├── .dockerignore          # Files to exclude from Docker build
├── docker-compose.yml     # Service orchestration
├── lib/phoenix_api_web/
│   └── controllers/
│       └── health_controller.ex  # Health check endpoint
└── DOCKER_README.md       # This file
```

## =============================================================================
## NEXT STEPS
## =============================================================================
1. **Customize Configuration**: Update environment variables for your needs
2. **Add Monitoring**: Integrate with monitoring tools like Prometheus
3. **Set Up CI/CD**: Create automated deployment pipelines
4. **Add Load Balancing**: Use nginx or similar for load balancing
5. **Implement Logging**: Add structured logging for better observability 
