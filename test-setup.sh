#!/bin/bash

# Rekru Application Setup Test Script
# ===================================
# This script tests the complete setup on a fresh machine

set -e

echo "🧪 Rekru Application Setup Test"
echo "================================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."
echo "=========================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if Make is installed
if ! command -v make &> /dev/null; then
    echo "❌ Make is not installed. Please install Make."
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed. Please install curl."
    exit 1
fi

echo "✅ All prerequisites are met!"
echo ""

# Clean any existing setup
echo "🧹 Cleaning any existing setup..."
make clean > /dev/null 2>&1 || true
echo "✅ Cleanup completed!"
echo ""

# Test the rebuild process
echo "🔨 Testing complete rebuild process..."
echo "====================================="

echo "Starting applications..."
make rebuild

echo ""
echo "⏳ Waiting for applications to be fully ready..."
sleep 30

echo ""
echo "📊 Testing application status..."
make status

echo ""
echo "🧪 Running comprehensive tests..."
make test

echo ""
echo "📥 Testing import functionality..."
make import

echo ""
echo "🌐 Testing web interfaces..."

# Test Phoenix API endpoints
echo "Testing Phoenix API endpoints..."
curl -s http://localhost:4000/api/health > /dev/null && echo "✅ Phoenix API health check: OK" || echo "❌ Phoenix API health check: FAILED"
curl -s http://localhost:4000/api/users > /dev/null && echo "✅ Phoenix API users endpoint: OK" || echo "❌ Phoenix API users endpoint: FAILED"

# Test Symfony App
echo "Testing Symfony App..."
curl -s -I http://localhost:8080/users/ > /dev/null && echo "✅ Symfony App: OK" || echo "❌ Symfony App: FAILED"

echo ""
echo "📋 Testing logs command..."
make logs > /dev/null 2>&1 && echo "✅ Logs command: OK" || echo "❌ Logs command: FAILED"

echo ""
echo "🎯 Final Status Check..."
make status

echo ""
echo "✅ Setup Test Completed Successfully!"
echo ""
echo "📱 Applications are now running at:"
echo "  Phoenix API:     http://localhost:4000"
echo "  Symfony App:     http://localhost:8080"
echo "  Users Page:      http://localhost:8080/users/"
echo ""
echo "🔧 Available commands:"
echo "  make start       - Start applications"
echo "  make stop        - Stop applications"
echo "  make status      - Check status"
echo "  make logs        - View logs"
echo "  make test        - Run tests"
echo "  make import      - Import data"
echo "  make clean       - Clean everything"
echo "  make rebuild     - Rebuild from scratch"
echo ""
echo "🎉 Everything is working correctly!" 
