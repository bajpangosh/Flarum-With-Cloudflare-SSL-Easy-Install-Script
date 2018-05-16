#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. flarum)?"
read USERNAME
echo "Updating Your OS................."
sleep 2;
sudo apt-get update && sudo apt-get upgrade -y

echo "lets install php 7.0 and modules"
sleep 2;
sudo apt install php7.0 php7.0-fpm git curl -y
sudo apt-get -y install php7.0-fpm php7.0-curl php7.0-gd php7.0-imap php7.0-mcrypt php7.0-readline php7.0-common php7.0-recode php7.0-mysql php7.0-cli php7.0-curl php7.0-mbstring php7.0-bcmath php7.0-mysql php7.0-opcache php7.0-zip php7.0-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.0-soap

echo "Some php.ini tweaks"
sleep 2;
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/zlib.output_compression = Off/zlib.output_compression = on/" /etc/php/7.0/fpm/php.ini

sudo systemctl restart php7.0-fpm.service

echo "Installing Nginx"
sleep 2;
sudo apt-get install nginx zip unzip pwgen composer -y
echo "Sit back and relax :) ......"
sleep 2;
cd /etc/nginx/sites-available/
wget -O "$DOMAIN" https://goo.gl/uV3Vz2
sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/

echo "Setting up Cloudflare FULL SSL"
sleep 2;
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
wget -O nginx.conf https://goo.gl/n8crcR
composer create-project flarum/flarum /var/www/flarum --stability=beta
sudo chown www-data:www-data -R /var/www/flarum
sudo systemctl restart nginx.service

echo "Instaling MariaDB"
sleep 2;
sudo apt install mariadb-server mariadb-client php7.0-mysql -y
sudo systemctl restart php7.0-fpm.service
sudo mysql_secure_installation
PASS=`pwgen -s 14 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is the database"
echo "Database:   $USERNAME"
echo "Username:   $USERNAME"
echo "Password:   $PASS"
