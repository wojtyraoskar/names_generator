# Continuous Integration (CI) Setup

This project uses GitHub Actions for continuous integration to ensure code quality and test coverage for both PHP (Symfony) and Elixir (Phoenix) applications.

## Workflow Overview

The CI workflow (`.github/workflows/ci.yml`) runs on:
- Push to `master` or `main` branches
- Pull requests to `master` or `main` branches

## Jobs

### 1. PHP Tests (Symfony)
- **Runtime**: Ubuntu Latest
- **PHP Version**: 8.1
- **Database**: PostgreSQL 15
- **Steps**:
  - Setup PHP with required extensions
  - Validate composer.json and composer.lock
  - Cache Composer packages
  - Install dependencies
  - Create test environment configuration
  - Clear cache
  - Run database migrations
  - Execute PHPUnit tests

### 2. Elixir Tests (Phoenix)
- **Runtime**: Ubuntu Latest
- **Elixir Version**: 1.18.0
- **OTP Version**: 26.0
- **Database**: PostgreSQL 15
- **Steps**:
  - Setup Elixir/OTP
  - Cache dependencies
  - Install dependencies
  - Create test database
  - Run database migrations
  - Execute Mix tests

### 3. PHP Linting
- **Runtime**: Ubuntu Latest
- **PHP Version**: 8.1
- **Steps**:
  - Setup PHP
  - Install dependencies
  - Run PHP syntax check

### 4. Elixir Linting
- **Runtime**: Ubuntu Latest
- **Elixir Version**: 1.18.0
- **OTP Version**: 26.0
- **Steps**:
  - Setup Elixir/OTP
  - Install dependencies
  - Run formatter check
  - Run Credo static analysis (with continue-on-error)

## Database Configuration

### Symfony (PHP)
- **Test Database**: `symfony_test`
- **Connection**: PostgreSQL with server version 15
- **Configuration**: Uses `.env.local` for test environment

### Phoenix (Elixir)
- **Test Database**: `phoenix_api_test`
- **Connection**: PostgreSQL
- **Configuration**: Uses `config/test.exs` for test environment

## Caching

The workflow implements caching for both applications:
- **PHP**: Composer packages cached based on `composer.lock` hash
- **Elixir**: Dependencies cached based on `mix.lock` hash

## Running Tests Locally

### PHP (Symfony)
```bash
cd symfony_app
composer install
php bin/console cache:clear --env=test
php bin/console doctrine:migrations:migrate --env=test
php bin/phpunit
```

### Elixir (Phoenix)
```bash
cd phoenix_api
mix deps.get
mix ecto.create
mix ecto.migrate
mix test
```

## Requirements

- PostgreSQL 15+ for both applications
- PHP 8.1+ with required extensions
- Elixir 1.18.0+ with OTP 26.0+

## Troubleshooting

### Common Issues

1. **Database Connection Issues**: Ensure PostgreSQL is running and accessible
2. **Cache Issues**: Clear cache with `php bin/console cache:clear --env=test`
3. **Migration Issues**: Reset database with `php bin/console doctrine:database:drop --env=test --force && php bin/console doctrine:database:create --env=test && php bin/console doctrine:migrations:migrate --env=test`

### Elixir Issues

1. **Database Issues**: Reset with `mix ecto.reset`
2. **Dependency Issues**: Clean with `mix deps.clean --all && mix deps.get`

## Adding New Tests

- **PHP**: Add test files in `symfony_app/tests/` directory
- **Elixir**: Add test files in `phoenix_api/test/` directory

Both applications use their respective testing frameworks (PHPUnit for PHP, ExUnit for Elixir). 
