#!/bin/bash

sudo apt update -y 

sudo apt install nginx -y 

echo "Welcome to My Default Page. Please Deploy Your App" >> /var/www/html/index.html

echo "My Health Page" >> /var/www/html/health.html