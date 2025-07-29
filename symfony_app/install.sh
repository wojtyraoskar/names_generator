#!/bin/bash

echo "🚀 Setting up Symfony User Management System"
echo "============================================="

# Check if Composer is installed
if ! command -v composer &> /dev/null; then
    echo "❌ Composer is not installed. Please install Composer first."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
composer install

# Create .env.local if it doesn't exist
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local file..."
    cp .env .env.local
    echo "✅ .env.local created. Please configure your database settings."
fi

# Clear cache
echo "🧹 Clearing cache..."
php bin/console cache:clear

echo ""
echo "✅ Installation completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure your database in .env.local"
echo "2. Start the Phoenix API: cd ../phoenix_api && mix phx.server"
echo "3. Start the Symfony server: symfony server:start"
echo "4. Test the API connection: php bin/console app:test-api"
echo "5. Open http://localhost:8000 in your browser"
echo ""
echo "🎉 Happy coding!" 
