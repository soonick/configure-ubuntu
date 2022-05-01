#!/usr/bin/env bash

# This script expects an e-mail address as the first argument:
# ./user-run.sh abc@def.ghi

# Stop if there is any error
set -e

# Some variables
myself=`logname`
myid=`id -u $myself`
email=$1

# Set up aliases and other shell configurations
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
echo 'export GEM_HOME=$HOME/.gems' >> ~/.bashrc
echo 'export PATH=$HOME/.gems/bin:$PATH' >> ~/.bashrc
export GEM_HOME=$HOME/.gems
export PATH=$HOME/.gems/bin:$PATH
gem install jekyll bundler

# Delete default directories
rmdir ~/Documents || true
rmdir ~/Downloads || true
rmdir ~/Music || true
rmdir ~/Pictures || true
rmdir ~/Public || true
rmdir ~/Templates || true
rmdir ~/Videos || true

# Delete default directories from bookmarks
truncate -s 0 ~/.config/user-dirs.dirs

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

# Don't show trash and home folders on desktop
gsettings set org.gnome.shell.extensions.ding show-trash false
gsettings set org.gnome.shell.extensions.ding show-home false

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
git clone https://github.com/soonick/get-vim.git $HOME/repos/get-vim
~/repos/get-vim/do.sh <<< "$HOME/bin/vim"
