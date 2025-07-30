# SUPER SIMPLE MAKEFILE TO START APP
# ===========================
# 
# Available commands:
#   make start          - Start both Phoenix API and Symfony applications
#   make stop           - Stop both applications
#   make restart        - Restart both applications
#   make status         - Show status of all containers
#   make logs           - Show logs from both applications
#   make clean          - Stop and remove all containers and volumes
#   make rebuild        - Rebuild both applications from scratch
#   make import         - Import names into Phoenix API
#   make test           - Test both applications are working

.PHONY: start stop restart status logs clean rebuild import test help

# Default target
help:
	@echo "Rekru Application Management"
	@echo "==========================="
	@echo ""
	@echo "Available commands:"
	@echo "  make start          - Start both Phoenix API and Symfony applications"
	@echo "  make stop           - Stop both applications"
	@echo "  make restart        - Restart both applications"
	@echo "  make status         - Show status of all containers"
	@echo "  make logs           - Show logs from both applications"
	@echo "  make clean          - Stop and remove all containers and volumes"
	@echo "  make rebuild        - Rebuild both applications from scratch"
	@echo "  make import         - Import names into Phoenix API"
	@echo "  make test           - Test both applications are working"
	@echo "  make help           - Show this help message"

# Start both applications
start:
	@echo "🚀 Starting Phoenix API..."
	@cd phoenix_api && docker-compose up -d
	@echo "⏳ Waiting for Phoenix API to be ready..."
	@sleep 15
	@echo "🌐 Starting Symfony application..."
	@cd symfony_app && docker-compose up -d
	@echo "⏳ Waiting for Symfony application to be ready..."
	@sleep 15
	@echo "✅ Both applications are starting up!"
	@echo ""
	@echo "📱 Applications URLs:"
	@echo "  Phoenix API:     http://localhost:4000"
	@echo "  Symfony App:     http://localhost:8080"
	@echo "  Users Page:      http://localhost:8080/users/"
	@echo ""
	@echo "🔍 Check status with: make status"
	@echo "📋 View logs with:   make logs"

# Stop both applications
stop:
	@echo "🛑 Stopping Phoenix API..."
	@cd phoenix_api && docker-compose down
	@echo "🛑 Stopping Symfony application..."
	@cd symfony_app && docker-compose down
	@echo "✅ Both applications stopped!"

# Restart both applications
restart: stop start

# Show status of all containers
status:
	@echo "📊 Container Status:"
	@echo "==================="
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(phoenix_api|symfony_app)" || echo "No containers running"
	@echo ""
	@echo "🔍 Health Checks:"
	@echo "================="
	@echo -n "Phoenix API: "
	@curl -s http://localhost:4000/api/health >/dev/null && echo "✅ Healthy" || echo "❌ Not responding"
	@echo -n "Symfony App: "
	@curl -s -I http://localhost:8080/users/ >/dev/null && echo "✅ Healthy" || echo "❌ Not responding"

# Show logs from both applications
logs:
	@echo "📋 Phoenix API Logs:"
	@echo "==================="
	@cd phoenix_api && docker-compose logs --tail=20
	@echo ""
	@echo "📋 Symfony App Logs:"
	@echo "==================="
	@cd symfony_app && docker-compose logs --tail=20

# Clean up everything
clean:
	@echo "🧹 Cleaning up all containers and volumes..."
	@cd phoenix_api && docker-compose down -v
	@cd symfony_app && docker-compose down -v
	@docker system prune -f
	@echo "✅ Cleanup complete!"

# Rebuild both applications from scratch
rebuild: clean
	@echo "🔨 Rebuilding both applications..."
	@make start

# Import names into Phoenix API
import:
	@echo "📥 Importing names into Phoenix API..."
	@curl -X POST http://localhost:4000/api/import
	@echo ""
	@echo "✅ Import completed!"

# Phoenix API database operations
phoenix-db-create:
	@echo "🗄️  Creating Phoenix API database..."
	@cd phoenix_api && docker-compose exec -T web bin/phoenix_api eval "PhoenixApi.Release.create"

phoenix-db-migrate:
	@echo "🔄 Running Phoenix API migrations..."
	@cd phoenix_api && docker-compose exec -T web bin/phoenix_api eval "PhoenixApi.Release.migrate"

phoenix-db-reset:
	@echo "🔄 Resetting Phoenix API database..."
	@cd phoenix_api && docker-compose exec -T web bin/phoenix_api eval "PhoenixApi.Release.reset"

phoenix-db-drop:
	@echo "🗑️  Dropping Phoenix API database..."
	@cd phoenix_api && docker-compose exec -T web bin/phoenix_api eval "PhoenixApi.Release.drop"

phoenix-db-setup: phoenix-db-create phoenix-db-migrate
	@echo "✅ Phoenix API database setup complete!"

# Test both applications
test:
	@echo "🧪 Testing both applications..."
	@echo ""
	@echo -n "Phoenix API Health: "
	@curl -s http://localhost:4000/api/health >/dev/null && echo "✅ OK" || echo "❌ FAILED"
	@echo -n "Phoenix API Users: "
	@curl -s http://localhost:4000/api/users >/dev/null && echo "✅ OK" || echo "❌ FAILED"
	@echo -n "Symfony App: "
	@curl -s -I http://localhost:8080/users/ >/dev/null && echo "✅ OK" || echo "❌ FAILED"
	@echo ""
	@echo "🎯 All tests completed!"

# Quick start (alias for start)
up: start

# Quick stop (alias for stop)
down: stop 
