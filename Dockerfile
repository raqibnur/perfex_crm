FROM php:8.0-fpm

# Expose port 80 for HTTP
EXPOSE 80

# Update the package repository and install required packages
RUN apt-get update -y && \
    apt-get install -y libpng-dev libc-client-dev libkrb5-dev libzip-dev nginx --no-install-recommends

# Configure and install IMAP extension with SSL and Kerberos
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

# Install additional PHP extensions
RUN docker-php-ext-install mysqli gd zip

# Copy your Nginx vhost config to the appropriate directory
COPY ./vhost.conf /etc/nginx/conf.d/default.conf

# Copy the application code to the appropriate directory
COPY ./ /var/www/html/

# Ensure proper ownership of the application files
RUN chown -R www-data:www-data /var/www/html/

# Set correct permissions for specific folders and files
RUN chmod 755 /var/www/html/uploads/
RUN chmod 755 /var/www/html/application/config/
RUN chmod 755 /var/www/html/application/config/config.php
RUN chmod 755 /var/www/html/application/config/app-config.php
RUN chmod 755 /var/www/html/temp/

# Start Nginx and PHP-FPM
CMD service php8.0-fpm start && nginx -g 'daemon off;'
