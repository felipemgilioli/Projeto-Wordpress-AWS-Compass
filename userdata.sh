#!/bin/bash
set -xe

### ================================
### VARIÁVEIS DE CONFIGURAÇÃO
### ================================
EFS_ID="<id_efs>"
DB_ROOT_PASSWORD="<senhaBD>"
DB_NAME="<NOMEBD>"
DB_USER="<UserBD>"
DB_PASSWORD="<senhaBD>"

### ================================
### ATUALIZA SISTEMA E INSTALA DEPENDÊNCIAS
### ================================
yum update -y
yum install -y aws-cli docker amazon-efs-utils

### ================================
### INICIA E CONFIGURA DOCKER
### ================================
service docker start
systemctl enable docker
usermod -a -G docker ec2-user

### ================================
### INSTALA DOCKER COMPOSE
### ================================
curl -SL "https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

### ================================
### MONTAGEM DO EFS
### ================================
mkdir -p /mnt/efs
mount -t efs "${EFS_ID}":/ /mnt/efs
echo "${EFS_ID}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

# Permissões para o WordPress
chown -R 33:33 /mnt/efs

### ================================
### PASTA DO PROJETO
### ================================
mkdir -p /home/ec2-user/projeto-docker
cd /home/ec2-user/projeto-docker

### ================================
### ARQUIVO .env
### ================================
cat > .env <<EOF
MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
MYSQL_DATABASE=${DB_NAME}
MYSQL_USER=${DB_USER}
MYSQL_PASSWORD=${DB_PASSWORD}
EOF

### ================================
### ARQUIVO docker-compose.yml
### ================================
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  database:
    mem_limit: 2048m
    image: mysql:8.0.43
    restart: unless-stopped
    ports:
      - 3306:3306
    env_file: .env
    environment:
      MYSQL_ROOT_PASSWORD: '${MYSQL_ROOT_PASSWORD}'
      MYSQL_DATABASE: '${MYSQL_DATABASE}'
      MYSQL_USER: '${MYSQL_USER}'
      MYSQL_PASSWORD: '${MYSQL_PASSWORD}'
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - wordpress-network
      
  phpmyadmin:
    depends_on:
      - database
    image: phpmyadmin/phpmyadmin
    restart: unless-stopped
    ports:
      - 8081:80
    env_file: .env
    environment:
      PMA_HOST: database
      MYSQL_ROOT_PASSWORD: '${MYSQL_ROOT_PASSWORD}'
    networks:
      - wordpress-network

  wordpress:
    depends_on:
      - database
    image: wordpress:6.8.2-php8.1-apache
    restart: unless-stopped
    ports:
      - 80:80
    env_file: .env
    environment:
      WORDPRESS_DB_HOST: database
      WORDPRESS_DB_NAME: '${MYSQL_DATABASE}'
      WORDPRESS_DB_USER: '${MYSQL_USER}'
      WORDPRESS_DB_PASSWORD: '${MYSQL_PASSWORD}'
    volumes:
      - /mnt/efs:/var/www/html
    networks:
      - wordpress-network

volumes:
  db-data:

networks:
  wordpress-network:
    driver: bridge
EOF

### ================================
### SOBE OS CONTAINERS
### ================================
docker-compose up -d
