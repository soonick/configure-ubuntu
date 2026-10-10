#!/usr/bin/env bash

# This script expects an e-mail address as the first argument and a name as second argument
# ./user-run.sh abc@def.ghi "Carlos Sanchez"

# Stop if there is any error
set -Eeuo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <email> <name>" >&2
  exit 1
fi

# Some variables
myself=`logname`
myid=$(id -u "$myself")
email=$1
name=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Set up aliases and other shell configurations
cp "$script_dir/customizations.bash" ~/.customizations.bash
if ! grep -q "customizations.bash" ~/.bashrc
then
  echo '. ~/.customizations.bash' >> ~/.bashrc
fi
. ~/.bashrc

# Hide stuff I don't want in my home folder
for entry in snap Desktop go Downloads; do
  if ! grep -qx "$entry" ~/.hidden 2> /dev/null
  then
    echo "$entry" >> ~/.hidden
  fi
done

# This is necessary to set gsettings from within a script. Otherwise it doesn't work
export XDG_RUNTIME_DIR=/run/user/$myid
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

# Terminal fonts
mkdir -p "$HOME/bin/fonts"
wget -O "$HOME/bin/fonts/NerdFont.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/UbuntuMono.zip
mkdir -p "$HOME/.fonts"
unzip -o "$HOME/bin/fonts/NerdFont.zip" -d "$HOME/.fonts"
fc-cache -f -v

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

# Use flameshot for Prt Sc
gsettings set org.gnome.shell.keybindings show-screenshot-ui '[]'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'flameshot'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'script --command "flameshot gui" /dev/null'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding 'Print'

# Configure terminal
gsettings set org.gnome.Ptyxis font-name 'UbuntuMono Nerd Font 12'
gsettings set org.gnome.Ptyxis use-system-font false
gsettings set org.gnome.Ptyxis audible-bell false
PROFILE_UUID=$(dconf read /org/gnome/Ptyxis/default-profile-uuid | tr -d "'" || true)
if [ -n "$PROFILE_UUID" ]
then
  dconf write "/org/gnome/Ptyxis/Profiles/$PROFILE_UUID/palette" "'campbell'"
fi

# Create an ssh key pair for github
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if test -f ~/.ssh/github_rsa
then
  echo "Github ssh key pair already exists"
else
  echo "Creating github ssh key pair"
  ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/github_rsa -N ""
  chmod 600 ~/.ssh/github_rsa
fi

# Add github key to ssh configuration
if ! grep -q "Host github.com" ~/.ssh/config 2> /dev/null
then
  cat >> ~/.ssh/config <<EOF
Host github.com
  IdentityFile ~/.ssh/github_rsa
EOF
  chmod 600 ~/.ssh/config
fi

# Configure git
git config --global core.editor nvim
git config --global alias.lg "log --graph --all --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'"
git config --global user.email "$email"
git config --global user.name "$name"
git config --global pull.rebase true

# Install vim
if command -v nvim &> /dev/null
then
  echo "Vim is already installed"
else
  echo "Installing vim"
  mkdir -p ~/repos/

  if ! test -d "$HOME/repos/get-vim"
  then
    git clone https://github.com/soonick/get-vim.git "$HOME/repos/get-vim"
  fi
  (cd ~/repos/get-vim/ && ./do.sh <<< "$HOME/bin/vim")
fi

# Install gnome-shell-system-monitor-applet
if ! test -d "$HOME/bin/gnome-shell-system-monitor-next-applet"
then
  git clone https://github.com/mgalgs/gnome-shell-system-monitor-next-applet.git "$HOME/bin/gnome-shell-system-monitor-next-applet"
fi
(cd "$HOME/bin/gnome-shell-system-monitor-next-applet" && make install gschemas.install-and-compile)
gsettings set org.gnome.shell.extensions.system-monitor-next-applet icon-display false
gsettings set org.gnome.shell.extensions.system-monitor-next-applet memory-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor-next-applet memory-show-text false
gsettings set org.gnome.shell.extensions.system-monitor-next-applet cpu-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor-next-applet cpu-show-text false
gsettings set org.gnome.shell.extensions.system-monitor-next-applet net-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor-next-applet net-show-text false
gsettings set org.gnome.shell.extensions.system-monitor-next-applet thermal-display true
gsettings set org.gnome.shell.extensions.system-monitor-next-applet thermal-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor-next-applet thermal-show-text false
gsettings set org.gnome.shell.extensions.system-monitor-next-applet thermal-sensor-label 'k10temp - Tctl'

# Enable the system monitor applet. It only loads on the next session restart
if python3 -c "import gi" &> /dev/null
then
  python3 - <<'PY'
import gi
gi.require_version('Gio', '2.0')
from gi.repository import Gio
uuid = 'system-monitor-next@paradoxxx.zero.gmail.com'
s = Gio.Settings.new('org.gnome.shell')
enabled = list(s.get_strv('enabled-extensions'))
if uuid not in enabled:
    enabled.append(uuid)
    s.set_strv('enabled-extensions', enabled)
disabled = list(s.get_strv('disabled-extensions'))
if uuid in disabled:
    disabled.remove(uuid)
    s.set_strv('disabled-extensions', disabled)
PY
else
  echo "python3 with gi is not available, enable the applet manually after a restart:"
  echo "gnome-extensions enable system-monitor-next@paradoxxx.zero.gmail.com"
fi

# Generate GPG key
if test -f ~/.ssh/gpg.pub
then
  echo "GPG key already exists"
else
  echo "Creating GPG key"
  gpg_key_file=$(mktemp)
  trap 'rm -f "$gpg_key_file"' EXIT
  cat > "$gpg_key_file" <<EOF
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
  gpg --batch --gen-key "$gpg_key_file"
  key=$(gpg --list-secret-keys --with-colons "$email" | awk -F: '/^fpr:/ {print $10; exit}')
  if [ -z "$key" ]; then
    echo "Could not determine the generated GPG key id" >&2
    exit 1
  fi
  gpg --armor --export "$key" > ~/.ssh/gpg.pub
  echo "Public key copied to ~/.ssh/gpg.pub"
  git config --global commit.gpgsign true
  git config --global user.signingkey "$key"
fi

# Tmux configuration
if test -f ~/.tmux.conf
then
  echo ".tmux.conf already exists"
else
  echo "Creating tmux.conf"
  cp "$script_dir/tmux.conf" ~/.tmux.conf
fi

# Firefox settings
echo "Configuring firefox"
firefox_profile_dir=$(find ~/snap/firefox/common/.mozilla/firefox -maxdepth 1 -type d -name '*default*' 2> /dev/null | head -n 1 || true)
if [ -n "$firefox_profile_dir" ]
then
  cp "$script_dir/user.js" "$firefox_profile_dir/user.js"

  # Download and install firefox extensions
  firefox_extensions_dir="$firefox_profile_dir/extensions"
  mkdir -p "$firefox_extensions_dir"
  install_firefox_extension() {
    local slug=$1
    local info guid url
    info=$(curl -s "https://addons.mozilla.org/api/v5/addons/addon/$slug/" || true)
    guid=$(printf '%s' "$info" | jq -r '.guid // empty')
    url=$(printf '%s' "$info" | jq -r '.current_version.file.url // empty')
    if [ -n "$guid" ] && [ -n "$url" ]
    then
      wget -O "$firefox_extensions_dir/$guid.xpi" "$url"
    else
      echo "Could not resolve the download URL for $slug"
    fi
  }
  install_firefox_extension ublock-origin
  install_firefox_extension bitwarden-password-manager
  install_firefox_extension private-grammar-checker-harper
  install_firefox_extension video-downloadhelper
else
  echo "Firefox profile not found, skipping user.js and extensions"
fi

# Dropbox
echo "Configuring dropbox"
(cd ~ && wget -4 -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -)
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/dropbox.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Dropbox
Exec=$HOME/.dropbox-dist/dropboxd
X-GNOME-Autostart-enabled=true
EOF
chmod +x "$HOME/.config/autostart/dropbox.desktop"

# Delete default directories
rmdir ~/Documents &> /dev/null || true
rmdir ~/Downloads &> /dev/null || true
rmdir ~/Music &> /dev/null || true
rmdir ~/Pictures &> /dev/null || true
rmdir ~/Public &> /dev/null || true
rmdir ~/Templates &> /dev/null || true
rmdir ~/Videos &> /dev/null || true
echo "enabled=False" > ~/.config/user-dirs.conf
rm -f ~/.config/gtk-3.0/bookmarks

# Disable Ubuntu's stupid tiling behaviour
gnome-extensions disable tiling-assistant@ubuntu.com
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"

# Allow audio over aplification
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent 'true'

# Things that couldn't be automated
echo ""
cat "$script_dir/manual-steps"
