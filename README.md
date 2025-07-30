# Rekru Application Suite

This project contains two applications:
- **Phoenix API** (Elixir/Phoenix) - Backend API for user management
- **Symfony App** (PHP/Symfony) - Web interface for user management

## Quick Start

### Option 1: Automated Setup (Recommended)

For a complete setup test on a fresh machine:

```bash
# Run the automated test script
./test-setup.sh
```

This will check prerequisites, clean any existing setup, rebuild everything, and test all functionality.

### Option 2: Using Makefile

```bash
# Start both applications
make start

# Check status
make status

# Stop both applications
make stop

# View logs
make logs

# Test applications
make test
```

### Option 3: Using Shell Script

```bash
# Start both applications
./start-apps.sh start

# Check status
./start-apps.sh status

# Stop both applications
./start-apps.sh stop

# View logs
./start-apps.sh logs

# Test applications
./start-apps.sh test
```

### For New Users

If you're setting up on a different PC, see the comprehensive [Setup Guide](SETUP_GUIDE.md) for detailed instructions.

## Available Commands

| Command | Description |
|---------|-------------|
| `start` | Start both Phoenix API and Symfony applications |
| `stop` | Stop both applications |
| `restart` | Restart both applications |
| `status` | Show status of all containers |
| `logs` | Show logs from both applications |
| `clean` | Stop and remove all containers and volumes |
| `rebuild` | Rebuild both applications from scratch |
| `import` | Import names into Phoenix API |
| `test` | Test both applications are working |
| `help` | Show help message |

## Application URLs

Once started, you can access:

- **Phoenix API**: http://localhost:4000
  - Health check: http://localhost:4000/api/health
  - Users API: http://localhost:4000/api/users

- **Symfony App**: http://localhost:8080
  - Users page: http://localhost:8080/users/
  - Import functionality via the red "Import" button

## Features

### Phoenix API (Backend)
- RESTful API for user management
- PostgreSQL database
- Import functionality for government data
- Pagination and filtering support
- Health monitoring

### Symfony App (Frontend)
- Modern web interface with Bootstrap
- User management (CRUD operations)
- Advanced filtering and sorting
- Pagination
- Import button that triggers Phoenix API
- Responsive design

## Prerequisites

- Docker and Docker Compose
- Make (for Makefile usage, optional)
- curl (for health checks)

## Troubleshooting

### If applications won't start:
```bash
# Clean everything and rebuild
make clean
make rebuild
```

### If you see "API connection failed":
```bash
# Check if Phoenix API is running
make status

# Restart if needed
make restart
```

### If database issues occur:
```bash
# Clean and rebuild
make clean
make rebuild
```

## Development

### Viewing Logs
```bash
make logs
```

### Testing Applications
```bash
make test
```

### Importing Data
```bash
make import
```

## Project Structure

```
rekru/
├── Makefile              # Main management script
├── start-apps.sh         # Alternative shell script
├── README.md             # This file
├── phoenix_api/          # Phoenix API application
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── ...
└── symfony_app/          # Symfony application
    ├── compose.yaml
    ├── Dockerfile
    └── ...
```

## Docker Containers

The applications run in the following containers:

- `phoenix_api_web` - Phoenix API server (port 4000)
- `phoenix_api_db` - PostgreSQL database for Phoenix API (port 5432)
- `symfony_app-nginx-1` - Nginx web server (port 8080)
- `symfony_app-app-1` - PHP-FPM application server
- `symfony_app-database-1` - PostgreSQL database for Symfony (port 5433)
- `symfony_app-mailer-1` - Mailpit for email testing

## API Endpoints

### Phoenix API
- `GET /api/health` - Health check
- `GET /api/users` - List users (with pagination/filtering)
- `POST /api/users` - Create user
- `GET /api/users/{id}` - Get specific user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `POST /api/import` - Import names from government data

## License

This project is for demonstration purposes.
