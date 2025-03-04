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
                   php-gmp php-imagick wget tar bzip2 unzip && \
    dnf clean all

# Download Nextcloud using wget
RUN wget -q "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" -O /tmp/nextcloud.tar.bz2

# Ensure the extraction directory exists
RUN mkdir -p ${NEXTCLOUD_DIR} && \
    tar -xjf /tmp/nextcloud.tar.bz2 -C ${NEXTCLOUD_DIR} --strip-components=1 && \
    rm -rf /tmp/nextcloud.tar.bz2

# Set permissions for OpenShift
RUN chown -R 1001:0 ${NEXTCLOUD_DIR} && chmod -R 770 ${NEXTCLOUD_DIR}

# Copy the custom router.php file to enforce security
COPY router.php ${NEXTCLOUD_DIR}/router.php

# Verify the file exists in the container during build
RUN ls -l ${NEXTCLOUD_DIR}/router.php

# Expose Nextcloud on port 8080
EXPOSE 8080

# Start PHP with the custom router
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html", "/var/www/html/router.php"]