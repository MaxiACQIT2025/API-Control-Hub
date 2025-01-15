# Imagen base oficial de PHP con Apache
FROM php:8.1-apache

# Establecer argumentos para usuario no root (opcional)
ARG USERNAME=maximiliano
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    curl \
   gnupg2\
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools


RUN apt-get update && apt-get install -y \
    libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap
# Configurar Git para permitir directorios con diferente propietario

# Instalar extensiones PHP necesarias para Laravel
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN git config --global --add safe.directory /var/www/html

# Crear usuario no root (opcional)
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Configurar e instalar SQL Server
# Establecer el directorio de trabajo
WORKDIR /var/www/html/api

# Copiar archivos de la aplicación
COPY . /var/www/html/api

# Instalar dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

#Archivo de configuracion de apache
COPY laravel-api.conf /etc/apache2/sites-available/

RUN a2dissite 000-default.conf \
    && rm /etc/apache2/sites-available/000-default.conf \
    && a2ensite laravel-api.conf \
    && a2enmod rewrite headers expires

# Establecer permisos
RUN chown -R $USERNAME:$USERNAME /var/www/html/api \
    && chmod -R 755 /var/www/html/api/storage /var/www/html/api/bootstrap/cache

# Habilitar el módulo de reescritura de Apache
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Cambiar a usuario no root (opcional)
USER $USERNAME

# Comando por defecto para iniciar Apache
CMD ["apache2-foreground"]
