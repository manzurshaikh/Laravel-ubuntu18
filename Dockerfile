FROM ubuntu:18.04

MAINTAINER manzur.shaikh@gmail.com 

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    # Install git
    git \
    # Install apache
    apache2 \
    # Install php 7.2
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
    php7.2-intl \
    php-imagick \
    # Install tools
    openssl \
    nano \
    graphicsmagick \
    imagemagick \
    ghostscript \
    mysql-client \
    iputils-ping \
    locales \
    sqlite3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

#RUN apt-get install  ca-certificates
# Install Microsoft Derivers Pre-requisites
RUN apt-get update && apt-get install -my wget gnupg
#RUN apt-get install -y gnupg
RUN apt-get install -y php-pear
RUN apt-get install -y php7.2-dev
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
# optional: for bcp and sqlcmd
RUN ACCEPT_EULA=Y apt-get install mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
# optional: for unixODBC development headers
RUN apt-get install unixodbc-dev
RUN apt-get install unixodbc

#Install the PHP drivers for Microsoft SQL Server

RUN  pecl install sqlsrv
RUN  pecl install pdo_sqlsrv
RUN  echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN  echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

RUN apt-get install -y libmcrypt-dev libreadline-dev
RUN pecl install mcrypt-1.0.1

# Install Apache and configure driver loading
RUN apt-get install -y libapache2-mod-php7.2 apache2
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php7.2
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/30-pdo_sqlsrv.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.2/apache2/conf.d/20-sqlsrv.ini
RUN echo "extension=mcrypt.so" >> /etc/php/7.2/apache2/conf.d/20-mcrypt.ini
RUN apt-get install -y libssl1.0
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

RUN a2enmod rewrite expires

# Configure PHP
#ADD php.ini /etc/php/7.2/apache2/conf.d/

# Configure vhost
#ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 8000
WORKDIR /var/www/html

#RUN rm index.html

CMD ["apache2ctl", "-D", "FOREGROUND"]

