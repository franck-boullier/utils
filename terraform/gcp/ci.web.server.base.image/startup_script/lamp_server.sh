#!/bin/sh

# We are using this doc: https://upcloud.com/community/tutorials/installing-lamp-stack-ubuntu/

# Get the latest package list
sudo apt update

# Do the updates
sudo apt-get update

# install wget
sudo apt install -y software-properties-common apt-transport-https wget

# Install vim
sudo apt install -y vim

# Install git
sudo apt install -y git

# Install Apache 2
sudo apt install -y apache2

# Install php 7.4 and other common modules
sudo apt install -y php7.4 php7.4-mysql php-common php7.4-cli php7.4-json php7.4-common php7.4-opcache libapache2-mod-php7.4

# Restart Apache
sudo systemctl restart apache2

# Make sure that Apache always starts at boot
sudo update-rc.d apache2 defaults

# Add a new user `deployment-worker`
sudo useradd -m deployment-worker

# add the `deployment-worker` to the apache (www-data) group
sudo usermod -a -G www-data deployment-worker

# Make sure that the default group for the `deployment-worker` user 
# is the apache group (www-data)
sudo usermod -g www-data deployment-worker

# Create the .ssh folder for the deployment worker
sudo -u deployment-worker mkdir -p /home/deployment-worker/.ssh

# Create a ssh Key for the user `deployment-worker` we can use to configure the repo:
sudo -u deployment-worker ssh-keygen -t rsa -b 4096 -C "ssh key for the deployment worker" -f /home/deployment-worker/.ssh/id_rsa -N '' -q

# Create a folder to store the code that is hosted in Bitbucket
sudo -u deployment-worker mkdir -p /home/deployment-worker/code-repository

# Add Bitbucket to the list of known Hosts
ssh-keyscan -t rsa bitbucket.org >> /home/deployment-worker/.ssh/known_hosts

# make sure that the Apache group is the owner of the files and folder
# in the /var/www/html folder
sudo chgrp -R www-data /var/www/html

# Allow members of the Apache group creation of new directories
sudo chmod -R 775 /var/www/html/

# Make sure that every new file in the fodler `/var/www/html`
# is created with `www-data` as the group information
sudo find /var/www/html -type d -exec chmod g+s {} +