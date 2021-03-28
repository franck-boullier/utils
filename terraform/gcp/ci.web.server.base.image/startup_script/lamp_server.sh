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

# Create a ssh Key we can use to configure the repo:
ssh-keygen -t rsa -b 4096 -C "ssh key for webserver using the repo xxx" -f id_rsa -N '' -q

# Add Bitbucket to the list of known Hosts
ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts