FROM php:5.6-fpm

# Указываем ссылку до debian-архивов:
COPY sources.list /etc/apt/sources.list

ENV ORACLE_HOME=/usr/local/instantclient

# Добавить и распаковать OCI-драйвер для oracle db:
ADD oracle/instantclient_12_1.tar.gz /usr/local

RUN apt-get update && apt-get -y --allow-unauthenticated install \
    libzip-dev mc telnet memcached libmemcached-dev nginx libldap2-dev \
  && ln -s /usr/local/instantclient_12_1 /usr/local/instantclient \
  && ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so \
  && ln -s /usr/local/instantclient/lib* /usr/lib \
  && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
  && chmod 755 -R /usr/local/instantclient \
  && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
  && docker-php-ext-install ldap \
  && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
  && docker-php-ext-install oci8 exif opcache \
  && pecl install memcache-2.2.7 \
  && docker-php-ext-enable memcache \
  && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient,12.1 \
  && docker-php-ext-install pdo_oci \
  && apt-get install -y --allow-unauthenticated libicu-dev libaio-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev \
  && docker-php-ext-install intl soap dom \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-install zip \
  && apt-get install -y --allow-unauthenticated imagemagick jq \
  && apt-get purge -y --auto-remove \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /var/www/html/public \
  && pecl install xdebug-2.5.5 xhprof-0.9.4 \
  && yes no|pecl install stomp-1.0.9 \
  && docker-php-ext-enable xdebug stomp xhprof \
  && rm -rf /tmp/pear/* \
  && rm /etc/nginx/sites-enabled/default

WORKDIR /var/www/html

# Копирование конфигурационных файлов
COPY php/conf/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY php/conf/vars-dev.ini /usr/local/etc/php/conf.d/vars-dev.ini
COPY php/conf/vars-pro.ini /usr/local/etc/php/conf.d/vars-production.ini.disabled
COPY php/conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY src/public/index.php /var/www/html/public/index.php

# Копирование конфига Nginx
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Запуск memcached, PHP-FPM и Nginx
CMD service memcached start && php-fpm -D && nginx -g 'daemon off;'