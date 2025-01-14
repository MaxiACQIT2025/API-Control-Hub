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
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP necesarias para Laravel
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Crear usuario no root (opcional)
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Configurar e instalar SQL Server
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . .

# Instalar dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

COPY .devcontainer/settings.conf /etc/apache2/sites-available/

RUN a2dissite 000-default.conf \
    && rm /etc/apache2/sites-available/000-default.conf \
    && a2ensite settings.conf \
    && a2enmod rewrite headers expires
    
# Configurar permisos
RUN chown -R $USERNAME:$USERNAME /var/www/html/API-Control-Hub
    

# Habilitar el módulo de reescritura de Apache
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Cambiar a usuario no root (opcional)
USER $USERNAME

# Comando por defecto para iniciar Apache
CMD ["apache2-foreground"]
