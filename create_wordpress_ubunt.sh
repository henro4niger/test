#!/bin/bash

apt update -y && sudo apt upgrade -y
apt install apache2 -y
apt install mariadb-server mariadb-client -y
systemctl start apache2
systemctl enable apache2
systemctl start mariadb
apt -y install expect
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
apt -y purge expect
sudo mysql  << eof
create database mydb;
create user "wpadmin"@"%" identified by "wpadminpass";
grant all privileges on mydb.* to "wpadmin"@"%";
eof
systemctl restart mariadb
apt install php php-gd php-mysql php-cli php-common -y
apt install wget unzip -y
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress/* /var/www/html/
sudo chown www-data:www-data -R /var/www/html/
rm /var/www/html/index.html
