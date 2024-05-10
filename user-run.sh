#!/usr/bin/env bash

# This script expects an e-mail address as the first argument and a name as second argument
# ./user-run.sh abc@def.ghi "Carlos Sanchez"

# Stop if there is any error
set -e

# Some variables
myself=`logname`
myid=`id -u $myself`
email=$1
name=$2

# Set up aliases and other shell configurations
cp ./customizations.bash ~/.customizations.bash
if ! cat ~/.bashrc | grep customizations.bash &> /dev/null
then
  echo '. ~/.customizations.bash' >> ~/.bashrc
fi
. ~/.bashrc

# Hide stuff I don't want in my home folder
if ! cat ~/.hidden | grep snap &> /dev/null
then
  echo snap >> ~/.hidden
fi
if ! cat ~/.hidden | grep Desktop &> /dev/null
then
  echo Desktop >> ~/.hidden
fi

# Delete default directories
rmdir ~/Documents &> /dev/null || true
rmdir ~/Downloads &> /dev/null || true
rmdir ~/Music &> /dev/null || true
rmdir ~/Pictures &> /dev/null || true
rmdir ~/Public &> /dev/null || true
rmdir ~/Templates &> /dev/null || true
rmdir ~/Videos &> /dev/null || true

# Delete default directories from bookmarks
truncate -s 0 ~/.config/user-dirs.dirs

# This is necessary to set gsettings from within a script. Otherwise it doesn't work
export XDG_RUNTIME_DIR=/run/user/$myid
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$myid/bus

# Gnome keyboard shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Ctrl><Alt>t']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Ctrl><Alt>h']"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Ctrl><Alt>w']"
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Ctrl><Alt>l']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up "['<Ctrl><Shift>Up']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down "['<Ctrl><Shift>Down']"
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:ralt']"

# Hide ubuntu dock permanently
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Don't show trash and home folders on desktop
gsettings set org.gnome.shell.extensions.ding show-trash false
gsettings set org.gnome.shell.extensions.ding show-home false

# Disable "natural" scrolling
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# When switching workspace, switch all monitors
gsettings set org.gnome.mutter workspaces-only-on-primary false

# Use dark theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Remove Characters search from desktop search providers
gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Characters.desktop']"

# Configure terminal
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'Monospace 10'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-system-font false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-color '#000000'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ foreground-color '#AFAFAF'

# Create an ssh key pair for github
if test -f ~/.ssh/github_rsa
then
  echo "Github ssh key pair already exists"
else
  echo "Creating github ssh key pair"
  ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/github_rsa -N ""
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/github_rsa
fi

# Configure git
git config --global core.editor nvim
git config --global alias.lg "log --graph --all --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'"
git config --global user.email "$email"
git config --global user.name "$name"

# Install vim
if command -v nvim &> /dev/null
then
  echo "Vim is already installed"
else
  echo "Installing vim"
  mkdir -p ~/repos/

  if ! test -d $HOME/repos/get-vim
  then
    git clone https://github.com/soonick/get-vim.git $HOME/repos/get-vim
  fi
  current_folder=$(pwd)
  cd ~/repos/get-vim/
  ./do.sh <<< "$HOME/bin/vim"
  cd $current_folder
fi

# Generate GPG key
if test -f ~/.ssh/gpg.pub
then
  echo "GPG key already exists"
else
  echo "Creating GPG key"
  cat >foo <<EOF
%echo Generating GPG key
Key-Type: RSA
Key-Length: 3072
Subkey-Type: RSA
Subkey-Length: 3072
Name-Real: $name
Name-Email: $email
%no-protection
%commit
%echo done
EOF
  key=$(gpg --batch --gen-key foo 2>&1 | grep "revocation certificate stored as")
  # Remove everything before last /
  key=$(echo $key | sed -e 's/^.*\///g')
  # Remove everything after the .
  key=$(echo $key | cut -d "." -f 1)
  gpg --armor --export $key > ~/.ssh/gpg.pub
  echo "Public key copied to ~/.ssh/gpg.pub"
  git config --global commit.gpgsign true
  git config --global user.signingkey $key
fi

# # Tmux configuration
if test -f ~/.tmux.conf
then
  echo ".tmux.conf already exists"
else
  echo "Creating tmux.conf"
  cp ./tmux.conf ~/.tmux.conf
fi

# Things that couldn't be automated
echo ""
cat ./manual-steps

# Firefox settings
profilePath=`find ~/snap/firefox/common/.mozilla/firefox  -maxdepth 1 -type d | grep default`
cp ./user.js ${profilePath}/user.js
