# Use CentOS Stream 9 as the base image
FROM quay.io/centos/centos:stream9

# Set environment variables
ENV NEXTCLOUD_VERSION=28.0.2 \
    NEXTCLOUD_DIR=/var/www/html \
    UPLOAD_MAX_SIZE=512M \
    MEMORY_LIMIT=512M \
    MAX_EXECUTION_TIME=300 \
    POSTGRES_HOST=nextcloud-db \
    POSTGRES_DB=nextcloud \
    POSTGRES_USER=nextcloud \
    POSTGRES_PASSWORD=supersecurepassword

# Install required system dependencies and Remi's Repo
RUN dnf install -y epel-release && \
    dnf install -y dnf-utils && \
    dnf install -y http://rpms.remirepo.net/enterprise/remi-release-9.rpm && \
    dnf config-manager --set-enabled crb && \
    dnf module reset php && \
    dnf module enable php:remi-8.3 -y && \
    dnf install -y php php-cli php-common php-pdo php-pgsql php-gd php-curl \
                   php-intl php-json php-mbstring php-xml php-zip php-bcmath \
                   php-gmp php-imagick wget tar bzip2 unzip httpd && \
    dnf clean all

# Download Nextcloud using wget
RUN wget -q "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" -O /tmp/nextcloud.tar.bz2

# Ensure the extraction directory exists
RUN mkdir -p ${NEXTCLOUD_DIR} && \
    tar -xjf /tmp/nextcloud.tar.bz2 -C ${NEXTCLOUD_DIR} --strip-components=1 && \
    rm -rf /tmp/nextcloud.tar.bz2

# Set proper permissions for Apache
RUN chown -R apache:apache ${NEXTCLOUD_DIR} && chmod -R 770 ${NEXTCLOUD_DIR}

# Use a heredoc to create the Apache VirtualHost configuration file
RUN cat <<EOF > /etc/httpd/conf.d/nextcloud.conf
<VirtualHost *:8080>
    DocumentRoot ${NEXTCLOUD_DIR}
    <Directory ${NEXTCLOUD_DIR}>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/nextcloud_error.log
    CustomLog /var/log/httpd/nextcloud_access.log combined
</VirtualHost>
EOF

# Ensure Apache starts correctly
RUN mkdir -p /run/httpd

# Expose Nextcloud on port 8080
EXPOSE 8080

# Start Apache in foreground
CMD ["httpd", "-D", "FOREGROUND"]