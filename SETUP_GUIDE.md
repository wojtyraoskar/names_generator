# Rekru Application Setup Guide

This guide will help you set up the Rekru application suite on any PC from scratch.

## Prerequisites

Before starting, ensure you have the following installed:

### Required Software
- **Docker Desktop** - Download from [docker.com](https://www.docker.com/products/docker-desktop/)
- **Make** - Usually pre-installed on macOS/Linux, install via package manager on Windows
- **curl** - Usually pre-installed, install via package manager if missing

### System Requirements
- **RAM**: Minimum 4GB, recommended 8GB+
- **Disk Space**: At least 5GB free space
- **OS**: macOS, Windows, or Linux

## Quick Start

### Option 1: Automated Setup (Recommended)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd rekru
   ```

2. **Run the automated test**:
   ```bash
   ./test-setup.sh
   ```

This script will:
- Check all prerequisites
- Clean any existing setup
- Rebuild everything from scratch
- Test all functionality
- Verify both applications work

### Option 2: Manual Setup

1. **Start Docker Desktop**:
   - Open Docker Desktop application
   - Wait for it to fully start (green icon in system tray)

2. **Start the applications**:
   ```bash
   make start
   ```

3. **Check status**:
   ```bash
   make status
   ```

4. **Test functionality**:
   ```bash
   make test
   ```

## Available Commands

| Command | Description |
|---------|-------------|
| `make start` | Start both applications |
| `make stop` | Stop both applications |
| `make restart` | Restart both applications |
| `make status` | Show container status and health |
| `make logs` | View application logs |
| `make test` | Test all endpoints |
| `make import` | Import sample data |
| `make clean` | Remove all containers and volumes |
| `make rebuild` | Clean and rebuild everything |
| `make help` | Show help message |

## Application URLs

Once started, access the applications at:

- **Phoenix API**: http://localhost:4000
  - Health check: http://localhost:4000/api/health
  - Users API: http://localhost:4000/api/users

- **Symfony App**: http://localhost:8080
  - Users page: http://localhost:8080/users/
  - Import functionality via the red "Import" button

## Troubleshooting

### Docker Issues

**Problem**: "Cannot connect to the Docker daemon"
**Solution**: Start Docker Desktop and wait for it to fully initialize

**Problem**: "Port already in use"
**Solution**: 
```bash
make clean
make rebuild
```

### Application Issues

**Problem**: Applications won't start
**Solution**:
```bash
make clean
make rebuild
```

**Problem**: Database connection errors
**Solution**:
```bash
make clean
make rebuild
```

**Problem**: Import not working
**Solution**:
```bash
make import
```

### Performance Issues

**Problem**: Slow startup
**Solution**: 
- Ensure Docker has enough resources allocated (4GB+ RAM)
- Close other resource-intensive applications

**Problem**: Applications not responding
**Solution**:
```bash
make restart
```

## Development

### Viewing Logs
```bash
make logs
```

### Testing Changes
```bash
make test
```

### Database Operations
```bash
# Phoenix API database operations
make phoenix-db-create
make phoenix-db-migrate
make phoenix-db-reset
make phoenix-db-drop
```

## Architecture

The application consists of:

### Phoenix API (Backend)
- **Language**: Elixir/Phoenix
- **Database**: PostgreSQL
- **Port**: 4000
- **Features**: RESTful API, user management, data import

### Symfony App (Frontend)
- **Language**: PHP/Symfony
- **Database**: PostgreSQL
- **Web Server**: Nginx
- **Port**: 8080
- **Features**: Web interface, user management, filtering

### Docker Containers
- `phoenix_api_web` - Phoenix API server
- `phoenix_api_db` - PostgreSQL for Phoenix API
- `symfony_app-nginx-1` - Nginx web server
- `symfony_app-app-1` - PHP-FPM application
- `symfony_app-database-1` - PostgreSQL for Symfony
- `symfony_app-mailer-1` - Mailpit for email testing

## Security Notes

- Default passwords are used for development only
- Database credentials are in docker-compose files
- No production secrets are included
- Change passwords for production use

## Support

If you encounter issues:

1. **Check prerequisites**: Ensure Docker, Make, and curl are installed
2. **Clean and rebuild**: `make clean && make rebuild`
3. **Check logs**: `make logs`
4. **Verify Docker**: Ensure Docker Desktop is running
5. **Check ports**: Ensure ports 4000 and 8080 are available

## License

This project is for demonstration purposes. 
