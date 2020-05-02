#!/usr/bin/env bash

# This script needs to be executed with sudo, otherwise it will fail

# Stop if there is any error
set -e

# Update system
apt-get update -y

# Install some packages
apt-get install -y \
  ubuntu-restricted-extras \
  gnome-tweak-tool \
  git \
  gimp \
  vlc \
  gnome-shell-extension-system-monitor \
  `# Jekyll dependencies` \
  ruby ruby-dev \
  `# Vim dependencies` \
  build-essential libncurses-dev libncurses5-dev libgtk2.0-dev libatk1.0-dev \
  libcairo2-dev libx11-dev libxpm-dev libxt-dev curl default-jre \
  `# Docker dependencies` \
  apt-transport-https ca-certificates gnupg-agent software-properties-common

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   eoan \
   stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
groupadd -f docker
usermod -aG docker $USER

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure firefox
ff_preferences="/usr/lib/firefox/browser/defaults/preferences/all-company.js"
touch $ff_preferences
echo "pref('signon.rememberSignons', false);" >> $ff_preferences

# Install lastpass extension for Firefox
wget https://addons.mozilla.org/firefox/downloads/file/3429807/lastpass.xpi \
    -O /usr/lib/firefox-addons/extensions/support@lastpass.com.xpi
