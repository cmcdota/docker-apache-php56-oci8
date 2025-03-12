FROM php:5.6.40-apache

#push to docker:
#docker login
#docker tag php56-oci-master:latest myusername/php56-oci-master:latest
#docker push myusername/php56-oci-master:latest

#Указываем ссылку до debian-архивов:
COPY sources.list /etc/apt/sources.list

#ENV LD_LIBRARY_PATH=/usr/local/instantclient:$LD_LIBRARY_PATH
ENV ORACLE_HOME=/usr/local/instantclient

#Добавить и распаковать OCI-драйвер для oracle db:
ADD oracle/instantclient_12_1.tar.gz /usr/local
#ADD oracle/instantclient-sdk-linux.x64-12.2.0.1.0.tar.gz /usr/local
#ADD oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.tar.gz /usr/local

RUN apt-get update && apt-get -y install libzip-dev mc memcached libmemcached-dev \
  && ln -s /usr/local/instantclient_12_1 /usr/local/instantclient \
  && ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so \
  && ln -s /usr/local/instantclient/lib* /usr/lib \
  && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
  && chmod 755 -R /usr/local/instantclient \
  && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
  && docker-php-ext-install oci8 exif opcache \
  # Установка расширения memcache (не путать с memcached!)
  && pecl install memcache-2.2.7 \
  && docker-php-ext-enable memcache

#PDO_OCI:
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient,12.1 \
    && docker-php-ext-install pdo_oci \
  && apt-get install -y libicu-dev libaio-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev \
  && docker-php-ext-install intl soap dom \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-install zip \
  && apt-get install -y imagemagick \
  && apt-get purge -y --auto-remove \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /var/www/html/public \
  && a2enmod headers rewrite

WORKDIR /var/www/html

# Копирование конфигурационных файлов
COPY apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY apache/charset.conf /etc/apache2/conf-available/charset.conf
COPY php/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY src/public/index.php /var/www/html/public/index.php
COPY php/vars-dev.ini /usr/local/etc/php/conf.d/vars.ini

# Копирование php.ini
RUN cp -f "/usr/local/etc/php/php.ini-development" /usr/local/etc/php/php.ini

# Открытие порта 80
EXPOSE 80

# Запуск Apache
CMD ["apache2-foreground"]

