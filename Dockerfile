FROM php:7.4-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxslt-dev \
        libxml2-dev \
        gettext \
        libmcrypt-dev \
        libcurl4 \
        libcurl4-openssl-dev \
        libonig-dev \
        libzip-dev


# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Packages
RUN docker-php-ext-install -j$(nproc) mbstring mysqli pdo_mysql bcmath opcache calendar exif pcntl shmop sysvmsg sysvsem sysvshm

RUN docker-php-ext-install curl xml soap xsl gettext zip sockets

RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV COMPOSER_ALLOW_SUPERUSER true

# Run composer and phpunit installation.
RUN composer selfupdate && \
  composer global require --dev "phpunit/phpunit:^9" && \
  ln -s ~/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

# PHP.ini Config

RUN sed -i 's|memory_limit = 128M|memory_limit = 1G|g' "$PHP_INI_DIR/php.ini"
RUN sed -i 's|;date.timezone =|date.timezone = "America/Bahia"|g' "$PHP_INI_DIR/php.ini"
RUN sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 100M|g' "$PHP_INI_DIR/php.ini"
RUN sed -i 's|post_max_size = 8M|post_max_size = 100M|g' "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

COPY . .
