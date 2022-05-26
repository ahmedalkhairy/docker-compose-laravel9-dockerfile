FROM php:8.1.1-apache
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
ENV APACHE_DOCUMENT_ROOT /var/www/public
WORKDIR /var/www/
RUN  apt-get update && apt-get install -y ca-certificates gnupg nano
#RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
#RUN apt-get update && apt-get upgrade -y && apt-get install -y git nodejs
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN /usr/sbin/a2enmod rewrite && /usr/sbin/a2enmod headers && /usr/sbin/a2enmod expires
RUN apt-get update && apt-get install -y libzip-dev zip && docker-php-ext-install zip
RUN docker-php-ext-install pdo pdo_mysql
#mysqli
RUN apt-get install -y libtidy-dev && docker-php-ext-install tidy && docker-php-ext-enable tidy
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#RUN pecl install xdebug
#RUN docker-php-ext-enable xdebug
#RUN echo 'zend_extension=xdebug' >> /usr/local/etc/php/php.ini
#RUN echo 'xdebug.mode=develop,debug' >> /usr/local/etc/php/php.ini
#RUN echo 'xdebug.client_host=host.docker.internal' >> /usr/local/etc/php/php.ini
#RUN echo 'xdebug.start_with_request=yes' >> /usr/local/etc/php/php.ini
#RUN echo 'session.save_path = "/tmp"' >> /usr/local/etc/php/php.ini

COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY .env.production /var/www/.env
COPY . /var/www/
WORKDIR /var/www/

RUN composer install \
    --no-interaction \
    --prefer-dist
Run composer dump-autoload

RUN chmod 777 -R /var/www/storage/
RUN chown -R www-data:www-data /var/www/

ENV APACHE_DOCUMENT_ROOT /var/www/public
RUN service apache2 restart


RUN php artisan config:cache
#RUN php artisan migrate --seed
#RUN php artisan route:cache
