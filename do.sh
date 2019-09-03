# Should be executed with sudo, otherwise it might stop to ask for password on
# some steps

myself=`logname`

# Terminal set up
echo '# Aliases' >> ~/.bash_aliases
echo 'alias c="clear"' >> ~/.bash_aliases
echo 'alias gs="git status"' >> ~/.bash_aliases
echo 'alias ga="git add"' >> ~/.bash_aliases
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

# Update system
apt-get update -y

# Install some packages
apt-get install \
  ubuntu-restricted-extras \
  gnome-tweak-tool \
  git \
  gimp \
  vlc -y

# Configure git
git config --global core.editor vim
git config --global alias.lg "log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'"

# Install vim
mkdir ~/repos/
git clone https://github.com/soonick/get-vim.git ~/repos/get-vim
apt-get install build-essential libncurses-dev libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev curl default-jre -y
~/repos/get-vim/do.sh <<< "$HOME/bin/vim"
chown -R $myself:$myself $HOME/bin/

# Configure firefox
ff_preferences="/usr/lib/firefox/browser/defaults/preferences/all-company.js"
touch $ff_preferences
echo "pref('signon.rememberSignons', false);" >> $ff_preferences
