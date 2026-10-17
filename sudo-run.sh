#!/usr/bin/env bash

# This script needs to be executed with sudo, otherwise it will fail

# Stop if there is any error
set -Eeuo pipefail

# Remove stale riseup-vpn PPA source from previous failed runs (PPA doesn't support resolute/26.04)
rm -f /etc/apt/sources.list.d/leapcodes-ubuntu-riseup-vpn-resolute.sources

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
  apt-transport-https ca-certificates gpg-agent software-properties-common \
  `# Dependencies for gnome-shell-system-monitor-applet` \
  gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 gnome-system-monitor \
  `# Helper tools used by user-run.sh` \
  jq lsb-release unzip wget

myself=`logname`

# Install docker and docker compose
if command -v docker &> /dev/null
then
  echo "Docker is already installed"
else
  echo "Installing docker and docker compose"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Get current release
  CURRENT_RELEASE=$(lsb_release -cs)

  # Check if current release exists, if not use the previous one
  release_status=$(curl -s -o /dev/null -w "%{http_code}" "https://download.docker.com/linux/ubuntu/dists/$CURRENT_RELEASE" || true)
  if [ "$release_status" != "200" ]; then
      echo "Release $CURRENT_RELEASE not found, finding latest available..."
      CURRENT_RELEASE=$(
        curl -s "https://api.launchpad.net/1.0/ubuntu/series" \
          | jq -r '.entries[] | select(.active==true) | "\(.version) \(.name)"' \
          | sort -V \
          | grep "$CURRENT_RELEASE" -B 1 \
          | awk 'NR==1 {print $2}'
      ) || true
      if [ -z "$CURRENT_RELEASE" ]; then
        echo "Could not determine a valid Ubuntu release for docker" >&2
        exit 1
      fi
      echo "Using previous release: $CURRENT_RELEASE"
  fi

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CURRENT_RELEASE stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Docker post-install steps
groupadd -f docker
usermod -aG docker "$myself"

mkdir -p "/home/$myself/bin/"

# Install kubectl
if command -v kubectl &> /dev/null
then
  echo "Kubectl is already installed"
else
  echo "Installing kubectl"
  case "$(dpkg --print-architecture)" in
    amd64) kubectl_arch=amd64 ;;
    arm64) kubectl_arch=arm64 ;;
    armhf) kubectl_arch=arm ;;
    *) kubectl_arch=amd64 ;;
  esac
  curl -L -o "/home/$myself/bin/kubectl" \
    "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$kubectl_arch/kubectl"
  install -o root -g root -m 0755 "/home/$myself/bin/kubectl" /usr/local/bin/kubectl
fi

# Install brave browser
if command -v brave-browser &> /dev/null
then
  echo "Brave browser is already installed"
else
  echo "Installing brave browser"
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list
  apt-get update -y
  apt-get install -y brave-browser
fi

# Install brave browser extensions automatically via managed policy.
# Extensions are force-installed on next Brave launch, similar to how
# Firefox extensions are dropped into the profile folder.
mkdir -p /etc/brave/policies/managed
cat > /etc/brave/policies/managed/extensions.json <<'EOF'
{
  "ExtensionInstallForcelist": [
    "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx",
    "lodbfhdipoipcjmlebjbgmmgekckhpfb;https://clients2.google.com/service/update2/crx",
    "lmjnegcaeklhafolokijcfjliaokphfk;https://clients2.google.com/service/update2/crx"
  ]
}
EOF

# Install proton vpn
if command -v protonvpn &> /dev/null
then
  echo "Proton VPN is already installed"
else
  echo "Installing Proton VPN"
  wget -O /tmp/protonvpn-stable-release.deb https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
  dpkg -i /tmp/protonvpn-stable-release.deb
  apt-get update -y
  apt-get install -y proton-vpn-gnome-desktop
  rm -f /tmp/protonvpn-stable-release.deb
fi

# Install riseup vpn
if command -v riseup-vpn &> /dev/null
then
  echo "Riseup VPN is already installed"
else
  echo "Installing Riseup VPN"
  # RiseupVPN is in Ubuntu's universe repository. The LEAP PPA only supports
  # older releases (noble, jammy), not resolute+, so install from universe instead.
  # Remove any leftover PPA source file from a previous failed run.
  rm -f /etc/apt/sources.list.d/leapcodes-ubuntu-riseup-vpn-resolute.sources
  if ! apt-cache show riseup-vpn &>/dev/null
  then
    add-apt-repository -y universe
    apt-get update -y
  fi
  apt-get install -y riseup-vpn
fi

# Install gcloud (Google Cloud CLI)
if command -v gcloud &> /dev/null
then
  echo "gcloud is already installed"
else
  echo "Installing gcloud"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --batch --yes --dearmor -o /etc/apt/keyrings/cloud.google.gpg
  chmod a+r /etc/apt/keyrings/cloud.google.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list

  apt-get update -y
  apt-get install -y google-cloud-cli
fi

chown -R "$myself" "/home/$myself/bin"
chgrp -R "$myself" "/home/$myself/bin"
