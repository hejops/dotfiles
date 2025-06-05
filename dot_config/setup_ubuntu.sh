set -euo pipefail

# install typical dependencies on ubuntu
# for arch, pkg.sh should have been run -- https://github.com/hejops/arch

# in case of "failed to start session" after system update (pathetic)
# sudo apt-get install --reinstall ubuntu-desktop

# disable desktop icons (who enabled this??)
gnome-extensions disable ding@rastersoft.com

# ensure us layout at login
if ! < /etc/default/keyboard grep -q '^XKBLAYOUT="us"'; then
	sudo dpkg-reconfigure keyboard-configuration
fi

# ensure us layout -after- login; setxkbmap in dwm generally will not work
# https://wiki.archlinux.org/title/IBus#Settings_removed_after_restart
gsettings set org.freedesktop.ibus.general preload-engines "['xkb:us::eng']"
# alternatively, use ibus-setup (gui) -- https://askubuntu.com/a/651345

APT=(

	eza
	fzf
	groff
	lowdown
	mpv
	ncdu
	neomutt
	npm
	playerctl mpv-mpris
	python3.12-venv
	ranger
	rg
	sqlite3
	xclip
	zathura
)

sudo apt -y install "${APT[@]}"             # apt assumes --needed
sudo snap install --classic chezmoi go nvim # https://snapcraft.io/docs/install-modes#classic-confinement
sudo snap install chromium

if ! command -v wezterm; then
	# https://wezfurlong.org/wezterm/install/linux.html#using-the-apt-repo
	curl -fsSL https://apt.fury.io/wez/gpg.key |
		sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
	echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
		sudo tee /etc/apt/sources.list.d/wezterm.list
fi
# TODO: generate ssh key, add to gh

cd

# bash ~/.mozilla/restore.sh # TODO: how to detect if setup done?

git clone https://github.com/hejops/dwm
cd dwm
sudo make install
# sudo cp dwm.desktop /usr/share/xsessions
