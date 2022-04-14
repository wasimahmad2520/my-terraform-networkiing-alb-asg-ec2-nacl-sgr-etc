#!/bin/bash
sudo apt-get update
sudo apt-get install apache2 -y
sleep 60
sudo ufw allow 'Apache'
sudo apt-get update
sleep 5
sudo apt install mysql-server -y
sleep 30
sudo systemctl start mysql.service
sleep 2
sudo apt-get update
sleep 2
sudo apt-get install php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath -y
sleep 60
sudo apt-get update
sudo apt-get install git -y
sleep 30
cd /var/www/html/
sudo git clone https://github.com/wasimahmad2520/Cake-Shop-Website.git 
sleep 30
sudo mv Cake-Shop-Website ecommerce

sudo apt-get install mysql-server -y
sleep 80
sudo systemctl start mysql.service
sleep 2
sudo mysql 
create database ecommerce;
CREATE USER 'wasimahmad'@'localhost' IDENTIFIED BY 'Wasimahmad$$%4';
CREATE USER 'wasimahmad'@'10.0.1.22' IDENTIFIED BY 'Wasimahmad$$%4';
GRANT ALL ON *.* TO 'wasimahmad'@'localhost';
GRANT ALL ON *.* TO 'wasimahmad'@'10.0.1.22';
FLUSH PRIVILEGES;
exit;
