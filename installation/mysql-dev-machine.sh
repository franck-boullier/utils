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
#   - Wine <-- run Windows App)
#   - A MySQL client for the CLI
#   - The MySQL Workbench interface
#   - WIP SQLyog Enterprise.

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

# Install The AWS Toolkit extension for VS Code 
code --install-extension amazonwebservices.aws-toolkit-vscode

# END Install Visual Studio Code

# install Wine
# This is taken from this link: http://ubuntuhandbook.org/index.php/2020/01/install-wine-5-0-stable-ubuntu-18-04-19-10/

# enable 32 bit architecture:
sudo dpkg --add-architecture i386

# Download and install the repository key
wget -nc https://dl.winehq.org/wine-builds/winehq.key; sudo apt-key add winehq.key

# Add wine repository
sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

# Add PPA for the required libfaudio0 library
sudo add-apt-repository -y ppa:cybermax-dexter/sdl2-backport

# Finally install Wine 5.0 stable
sudo apt update && sudo apt install -y --install-recommends winehq-stable

# END install Wine 5.0

# Install a command line MySQL client:
sudo apt-get install -y mysql-client

# Install MySQL Workbench
sudo apt-get install -y mysql-workbench