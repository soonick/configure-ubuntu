#!/usr/bin/env bash

# This script should be executed with sudo, otherwise it might stop to ask for
# password on some steps

##### This section needs to be run as root

# Stop if there is any error
set -e

# Some variables
myself=`logname`
myid=`id -u $myself`
myhome=`eval echo ~$myself`
email=$1

# Update system
apt-get update -y

# Install some packages
apt-get install -y \
  ubuntu-restricted-extras \
  gnome-tweak-tool \
  git \
  gimp \
  vlc \
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
groupadd docker
usermod -aG docker $USER

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure firefox
ff_preferences="/usr/lib/firefox/browser/defaults/preferences/all-company.js"
touch $ff_preferences
echo "pref('signon.rememberSignons', false);" >> $ff_preferences

# Install lastpass extension for Firefox
wget https://addons.mozilla.org/firefox/downloads/file/3429807/lastpass.xpi -O /usr/lib/firefox-addons/extensions/support@lastpass.com.xpi

##### End of root section

##### This section needs to be run as user

sudo -i -u $myself bash << EOF
# Stop if there is any error
set -e

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

# Install jekyll for signed in user
echo 'export GEM_HOME=\$HOME/.gems' >> ~/.bashrc
echo 'export PATH=\$HOME/.gems/bin:\$PATH' >> ~/.bashrc
. ~/.bashrc
gem install jekyll bundler

# Delete default directories
rmdir ~/Documents
rmdir ~/Downloads
rmdir ~/Music
rmdir ~/Pictures
rmdir ~/Public
rmdir ~/Templates
rmdir ~/Videos

# This is necessary to set gsettings from within a script. Otherwise it doesn't
# work
export XDG_RUNTIME_DIR=/run/user/$myid
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$myid/bus

# Gnome keyboard shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Ctrl><Alt>t']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Ctrl><Alt>h']"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Ctrl><Alt>w']"
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Ctrl><Alt>l']"

# Hide ubuntu dock permanently
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Don't show icons on desktop
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false

# Disable "natural" scrolling
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# When switching workspace, switch all monitors
gsettings set org.gnome.mutter workspaces-only-on-primary false

# Configure terminal
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'Monospace 10'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-system-font false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-color '#000000'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ foreground-color '#AFAFAF'

# Create an ssh key pair for github
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/github_rsa -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_rsa

# Configure git
git config --global core.editor vim
git config --global alias.lg "log --graph --all --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'"
git config --global user.email "$email"
git config --global user.name "Adrian Ancona Novelo"

# Install vim
mkdir -p ~/repos/
git clone https://github.com/soonick/get-vim.git $myhome/repos/get-vim
~/repos/get-vim/do.sh <<< "$myhome/bin/vim"

EOF

##### End of user section
