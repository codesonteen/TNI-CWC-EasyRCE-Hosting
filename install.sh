#!/bin/bash

# Check Root Privilege
if [ "$EUID" -ne 0 ]
  then echo "Root privilege is required to run the installation script."
  exit
fi

# Configure APT repository
cp -rf env/apt/sources.list /etc/apt/sources.list

# Install Packages (Nginx, MySQL, PHP-FPM)
apt install -y nginx mysql-server php-fpm php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-ldap php-zip php-curl

# Create Users
useradd -m -d /home/grizz grizz
useradd -m -d /home/icebear icebear
useradd -m -d /home/panda panda

# Add sudo user
usermod -aG sudo panda

# Copy files
cp -rf env/* /

# Configure sudoers
sed -i "s/#includedir \/etc\/sudoers.d/includedir \/etc\/sudoers.d" /etc/sudoers

# Configure Nginx
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/grizz.conf
ln -s /etc/nginx/sites-available/icebear.conf
ln -s /etc/nginx/sites-available/panda.conf

# Restart services
systemctl restart php7.2-fpm
systemctl restart nginx

# Remove default index.html
rm -f /var/www/html/index.nginx-debian.html

# Set owners and permission for public files
chown -R www-data. /var/www/html
chown -R grizz. /home/grizz
chown -R icebear. /home/icebear
chown -R panda. /home/panda
