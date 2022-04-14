#!/bin/bash
sudo apt-get update
sudo apt-get install mysql-server -y
sleep 110
sudo systemctl start mysql.service
sleep 2
sudo apt-get update
sudo apt-get install git -y
sleep 40
sudo git clone https://github.com/wasimahmad2520/Cake-Shop-Website.git 
sleep 30
sudo mv Cake-Shop-Website ecommerce
sudo mysql 
create database ecommerce;
exit;
sudo mysql -u root  ecommerce < ecommerce/Database/cakeshop.sql
sleep 10
sudo mysql -u root
CREATE USER 'wasimahmad'@'localhost' IDENTIFIED BY 'Wasimahmad$$%4' ;
CREATE USER 'wasimahmad'@'%' IDENTIFIED BY 'Wasimahmad$$%4' ;
GRANT ALL ON *.* TO 'wasimahmad'@'localhost';
GRANT ALL ON *.* TO 'wasimahmad'@'%';
FLUSH PRIVILEGES;
exit;
