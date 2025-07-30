FROM php:8.3-fpm-alpine AS builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    postgresql-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_pgsql \
        zip \
        intl \
        mbstring \
        xml \
        gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application code
COPY . .

# Install dependencies and optimize for production
RUN composer install --no-dev --optimize-autoloader --no-scripts && \
    composer dump-autoload --optimize --no-dev --classmap-authoritative

# Clear cache and warm up
RUN php bin/console cache:clear --env=prod --no-debug

FROM php:8.3-fpm-alpine AS app

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_pgsql \
        intl \
        mbstring \
        xml \
        gd

# Create app user
RUN addgroup -g 1000 app && \
    adduser -D -s /bin/sh -u 1000 -G app app

WORKDIR /app

# Copy application from builder stage
COPY --from=builder --chown=app:app /app ./

# Create necessary directories and set permissions
RUN mkdir -p var/cache var/log && \
    chown -R app:app var

USER app

EXPOSE 9000

ENV APP_ENV=prod
ENV APP_DEBUG=0

CMD ["php-fpm"] 
