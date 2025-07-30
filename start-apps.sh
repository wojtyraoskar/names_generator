#!/bin/bash

# Rekru Application Management Script
# ===================================
# 
# Usage: ./start-apps.sh [command]
# 
# Available commands:
#   start          - Start both Phoenix API and Symfony applications
#   stop           - Stop both applications
#   restart        - Restart both applications
#   status         - Show status of all containers
#   logs           - Show logs from both applications
#   clean          - Stop and remove all containers and volumes
#   rebuild        - Rebuild both applications from scratch
#   import         - Import names into Phoenix API
#   test           - Test both applications are working
#   help           - Show this help message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to start both applications
start_apps() {
    print_info "🚀 Starting Phoenix API..."
    cd phoenix_api && docker-compose up -d
    cd ..
    
    print_info "⏳ Waiting for Phoenix API to be ready..."
    sleep 10
    
    print_info "🔧 Setting up Phoenix API database..."
    cd phoenix_api
    docker-compose exec -T web mix ecto.create
    docker-compose exec -T web mix ecto.migrate
    cd ..
    
    print_info "🌐 Starting Symfony application..."
    cd symfony_app && docker-compose up -d
    cd ..
    
    print_info "⏳ Waiting for Symfony application to be ready..."
    sleep 15
    
    print_status "Both applications are starting up!"
    echo ""
    print_info "📱 Applications URLs:"
    echo "  Phoenix API:     http://localhost:4000"
    echo "  Symfony App:     http://localhost:8080"
    echo "  Users Page:      http://localhost:8080/users/"
    echo ""
    print_info "🔍 Check status with: ./start-apps.sh status"
    print_info "📋 View logs with:   ./start-apps.sh logs"
}

# Function to stop both applications
stop_apps() {
    print_info "🛑 Stopping Phoenix API..."
    cd phoenix_api && docker-compose down
    cd ..
    
    print_info "🛑 Stopping Symfony application..."
    cd symfony_app && docker-compose down
    cd ..
    
    print_status "Both applications stopped!"
}

# Function to show status
show_status() {
    echo "📊 Container Status:"
    echo "==================="
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(phoenix_api|symfony_app)" || echo "No containers running"
    echo ""
    echo "🔍 Health Checks:"
    echo "================="
    echo -n "Phoenix API: "
    if curl -s http://localhost:4000/api/health >/dev/null; then
        print_status "Healthy"
    else
        print_error "Not responding"
    fi
    
    echo -n "Symfony App: "
    if curl -s -I http://localhost:8080/users/ >/dev/null; then
        print_status "Healthy"
    else
        print_error "Not responding"
    fi
}

# Function to show logs
show_logs() {
    echo "📋 Phoenix API Logs:"
    echo "==================="
    cd phoenix_api && docker-compose logs --tail=20
    cd ..
    echo ""
    echo "📋 Symfony App Logs:"
    echo "==================="
    cd symfony_app && docker-compose logs --tail=20
    cd ..
}

# Function to clean up
clean_up() {
    print_info "🧹 Cleaning up all containers and volumes..."
    cd phoenix_api && docker-compose down -v
    cd ..
    cd symfony_app && docker-compose down -v
    cd ..
    docker system prune -f
    print_status "Cleanup complete!"
}

# Function to rebuild
rebuild_apps() {
    clean_up
    print_info "🔨 Rebuilding both applications..."
    start_apps
}

# Function to import names
import_names() {
    print_info "📥 Importing names into Phoenix API..."
    curl -X POST http://localhost:4000/api/import
    echo ""
    print_status "Import completed!"
}

# Function to test applications
test_apps() {
    print_info "🧪 Testing both applications..."
    echo ""
    echo -n "Phoenix API Health: "
    if curl -s http://localhost:4000/api/health >/dev/null; then
        print_status "OK"
    else
        print_error "FAILED"
    fi
    
    echo -n "Phoenix API Users: "
    if curl -s http://localhost:4000/api/users >/dev/null; then
        print_status "OK"
    else
        print_error "FAILED"
    fi
    
    echo -n "Symfony App: "
    if curl -s -I http://localhost:8080/users/ >/dev/null; then
        print_status "OK"
    else
        print_error "FAILED"
    fi
    
    echo ""
    print_status "All tests completed!"
}

# Function to show help
show_help() {
    echo "Rekru Application Management Script"
    echo "==================================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Available commands:"
    echo "  start          - Start both Phoenix API and Symfony applications"
    echo "  stop           - Stop both applications"
    echo "  restart        - Restart both applications"
    echo "  status         - Show status of all containers"
    echo "  logs           - Show logs from both applications"
    echo "  clean          - Stop and remove all containers and volumes"
    echo "  rebuild        - Rebuild both applications from scratch"
    echo "  import         - Import names into Phoenix API"
    echo "  test           - Test both applications are working"
    echo "  help           - Show this help message"
}

# Main script logic
main() {
    check_docker
    
    case "${1:-start}" in
        start|up)
            start_apps
            ;;
        stop|down)
            stop_apps
            ;;
        restart)
            stop_apps
            start_apps
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        clean)
            clean_up
            ;;
        rebuild)
            rebuild_apps
            ;;
        import)
            import_names
            ;;
        test)
            test_apps
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 
