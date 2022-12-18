#!/usr/bin/env bash

# This script needs to be executed with sudo, otherwise it will fail

# Stop if there is any error
set -e

# Update system
apt-get update -y

# Install some packages
apt-get install -y \
  ubuntu-restricted-extras \
  chrome-gnome-shell \
  gnome-tweaks \
  git \
  gimp \
  vlc \
  gnupg \
  `# Jekyll dependencies` \
  ruby ruby-dev \
  `# Vim dependencies` \
  build-essential libncurses-dev libncurses5-dev libgtk2.0-dev libatk1.0-dev \
  libcairo2-dev libx11-dev libxpm-dev libxt-dev curl default-jre \
  `# Docker dependencies` \
  apt-transport-https ca-certificates gnupg-agent software-properties-common \
  `# Dependencies for gnome-shell-system-monitor-applet` \
  gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 gnome-system-monitor

# Install docker and docker compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install Chrome
myself=`logname`
wget -O /home/$myself/bin/chrome.deb \
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install /home/$myself/bin/chrome.deb
