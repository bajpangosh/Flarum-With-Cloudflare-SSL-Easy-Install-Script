#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. flarum)?"
read USERNAME
echo "Updating Your OS................."
sleep 2;
sudo apt-get update && sudo apt-get upgrade -y

echo "Install Dependancies"
sleep 2;
sudo apt-get install pwgen php7.0-{mysql,common,gd,xml,mbstring,curl} php7.0 composer nginx mysql-server unzip -y

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

echo "Download & Installing Flarum"
sleep 2;

composer create-project flarum/flarum /var/www/flarum --stability=beta
sudo chown www-data:www-data -R /var/www/flarum
sudo systemctl restart nginx.service

echo "Generating a Strong MySQL Database"
sleep 2;
PASS=`pwgen -s 14 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is the MySQL Database Credentials"
echo "Database:   $USERNAME"
echo "Username:   $USERNAME"
echo "Password:   $PASS"
