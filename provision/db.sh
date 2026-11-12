#!/bin/bash
set -e

DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASS="${DB_PASS}"

echo ">>> Updating packages and insatlling MySQL Server..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y mysql-server

echo ">>> Config MySQL for privat ip Vagrant..."
# Change bind-address from 127.0.0.1 on 0.0.0.0 (or 192.168.56.%)
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql

echo ">>> Create db, users and privileges..."
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'192.168.56.%' IDENTIFIED BY '${DB_PASS}';
ALTER USER '${DB_USER}'@'192.168.56.%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'192.168.56.%';
FLUSH PRIVILEGES;
EOF

echo ">>> MySQL configured successfully!"