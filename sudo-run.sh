#!/usr/bin/env bash

# This script needs to be executed with sudo, otherwise it will fail

# Stop if there is any error
set -e

# Update system
apt-get update -y

# Install some packages
apt-get install -y \
  flameshot \
  gimp \
  git \
  gnome-tweaks \
  gnucash \
  gnupg \
  kicad \
  tree \
  ubuntu-restricted-extras \
  vlc \
  `# tmux and dependencies` \
  tmux xclip \
  `# Jekyll dependencies` \
  ruby ruby-dev \
  `# Vim dependencies` \
  build-essential libncurses-dev libncurses5-dev libgtk2.0-dev libatk1.0-dev \
  libcairo2-dev libx11-dev libxpm-dev libxt-dev curl default-jre \
  `# Docker dependencies` \
  apt-transport-https ca-certificates gnupg-agent software-properties-common \
  `# Dependencies for gnome-shell-system-monitor-applet` \
  gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 gnome-system-monitor

myself=`logname`

# Install docker and docker compose
if command -v docker &> /dev/null
then
  echo "Docker is already installed"
else
  echo "Installing docker and docker compose"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  # Get current release
  CURRENT_RELEASE=$(lsb_release -cs)

  # Check if current release exists, if not use the previous one
  if ! curl -s --head "https://download.docker.com/linux/ubuntu/dists/$CURRENT_RELEASE" | head -n 1 | grep -q "200"; then
      echo "Release $CURRENT_RELEASE not found, finding latest available..."
      CURRENT_RELEASE=$(
        curl -s "https://api.launchpad.net/1.0/ubuntu/series" \
          | jq -r '.entries[] | select(.active==true) | "\(.version) \(.name)"' \
          | sort -V \
          | grep "$CURRENT_RELEASE" -B 1 \
          | head -n 1 \
          | awk '{print $2}'
      )
      echo "Using previous release: $CURRENT_RELEASE"
  fi

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $CURRENT_RELEASE stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Docker post-install steps
groupadd -f docker
usermod -aG docker $myself

mkdir -p /home/$myself/bin/

# Install kubectl
if command -v kubectl &> /dev/null
then
  echo "Kubectl is already installed"
else
  echo "Installing kubectl"
  curl -L -o /home/$myself/bin/kubectl \
    "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 /home/$myself/bin/kubectl /usr/local/bin/kubectl
fi

chown -R $myself /home/$myself/bin
chgrp -R $myself /home/$myself/bin
