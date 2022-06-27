#!/bin/sh

# This scrip installs:
#   - latest ubuntu updates
#   - wget
#   - Chrome remote Desktop
#   - GUI for Ubuntu (Xfce)
#   - Google Chrome
#   - Firefox
#   - Google Cloud SDK
#   - aws cli
#   - Visual Studio Code
#   - Golang
#   - Postman
#   - jq

# Get the latest package list
sudo apt update

# Do the updates
sudo apt-get update

# install wget
sudo apt install -y software-properties-common apt-transport-https wget

# Download the Debian Linux Chrome Remote Desktop installation package:
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

# Install the package and its dependencies:
sudo dpkg --install chrome-remote-desktop_current_amd64.deb
sudo apt install -y --fix-broken

# Cleanup remove the unnecessary file after the installation is done:
rm chrome-remote-desktop_current_amd64.deb

# install xcfe
sudo DEBIAN_FRONTEND=noninteractive \
    apt install -y xfce4 xfce4-goodies desktop-base

# Configure Chrome Remote Desktop to use Xfce by default:
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Xfce's default screen locker is Light Locker, which doesn't work with Chrome Remote Desktop. 
# install XScreenSaver as an alternative:
sudo apt install -y xscreensaver

# Install Firefox browser
sudo apt -y install firefox

# Install Chrome browser
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg --install google-chrome-stable_current_amd64.deb
sudo apt install -y --fix-broken

# Cleanup remove the unnecessary file after the installation is done:
rm google-chrome-stable_current_amd64.deb

# Disable the display manager service:
# There is no display connected to the VM --> the display manager service won't start.
sudo systemctl disable lightdm.service

# Install the Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get install apt-transport-https ca-certificates gnupg

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt-get update 
sudo apt-get install -y google-cloud-sdk

# END Install the Google Cloud SDK

# Install AWS CLI
# This is needed to interact with AWS resources

# Download the installation file 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the installer
unzip awscliv2.zip

# Run the install program
sudo ./aws/install

# Cleanup: remove the zip file for the aws installer
rm awscliv2.zip

# END Install AWS CLI

# Install Visual Studio Code
sudo snap install --classic code

# install Golang

# Download the code
# This will install Go v1.17.3
wget https://golang.org/dl/go1.17.3.linux-amd64.tar.gz

# Install Golang in the folder /usr/local
sudo tar -C /usr/local -xvf go1.17.3.linux-amd64.tar.gz

# Cleanup remove the installation file
rm go1.17.3.linux-amd64.tar.gz

# create a copy of the orginal /etc/profile file
sudo cp /etc/profile /etc/profile.vanila

# Configure the Go PATH (for all users)
echo '' | sudo tee -a /etc/profile > /dev/null
echo "# Configure the GOPATH for Golang " | sudo tee -a /etc/profile > /dev/null
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile > /dev/null

# END install Golang

# Install Postman so we can test API if needed
sudo snap install postman

# Install jq
sudo snap install jq