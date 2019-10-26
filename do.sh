#!/usr/bin/env bash

# These script should be executed with sudo, otherwise it might stop to ask for
# password on some steps

##### This section needs to be run as root

# Update system
apt-get update -y

# Install some packages
apt-get install \
  ubuntu-restricted-extras \
  gnome-tweak-tool \
  git \
  gimp \
  vlc -y

# Install vim dependencies
apt-get install build-essential libncurses-dev libncurses5-dev libgtk2.0-dev \
  libatk1.0-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev curl default-jre -y

##### End of root section

##### This section needs to be run as user

myself=`logname`
sudo -i -u $myself bash << EOF
# Terminal set up
echo '# Aliases' >> ~/.bash_aliases
echo 'alias c="clear"' >> ~/.bash_aliases
echo 'alias gs="git status"' >> ~/.bash_aliases
echo 'alias ga="git add"' >> ~/.bash_aliases
echo 'alias gd="git diff"' >> ~/.bash_aliases
echo 'alias gc="git commit"' >> ~/.bash_aliases
echo 'alias gl="git lg"' >> ~/.bash_aliases
echo 'alias gpom="git push origin master"' >> ~/.bash_aliases
echo '' >> ~/.bash_aliases
echo '# Configurations' >> ~/.bash_aliases
echo 'set -o vi' >> ~/.bash_aliases
. ~/.bash_aliases

# Hide stuff I don't want in my home folder
echo snap >> ~/.hidden
echo Desktop >> ~/.hidden

# Gnome keyboard shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal '<Ctrl><Alt>t'
gsettings set org.gnome.settings-daemon.plugins.media-keys home '<Ctrl><Alt>h'
gsettings set org.gnome.settings-daemon.plugins.media-keys www '<Ctrl><Alt>w'
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver '<Ctrl><Alt>l'

# Hide ubuntu dock permanently
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Don't show icons on desktop
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false

# Configure git
git config --global core.editor vim
git config --global alias.lg "log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'"

# Install vim
mkdir ~/repos/
git clone https://github.com/soonick/get-vim.git ~/repos/get-vim
~/repos/get-vim/do.sh <<< "$HOME/bin/vim"

# Configure firefox
ff_preferences="/usr/lib/firefox/browser/defaults/preferences/all-company.js"
touch $ff_preferences
echo "pref('signon.rememberSignons', false);" >> $ff_preferences

EOF

##### End of user section
