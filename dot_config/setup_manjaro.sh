set -euo pipefail

pkgs=(

	# vim
	adobe-source-code-pro-fonts
	chezmoi
	chromium
	clang
	docker
	docker-compose
	eza
	fakeroot # for checkupdates
	fzf
	github-cli
	glab
	go
	jq
	luacheck
	make
	mpv
	npm
	nvim
	pacman-contrib # pactree
	playerctl mpv-mpris
	rofi
	shellharden # mason install requires cargo (rustup)
	slock
	wezterm
	wireless_tools # iwgetid
	xclip
	xorg-xsetroot # dwmstatus, wallpaper
	yarn
	yazi
	yt-dlp

)

if ! command -v trizen; then
	git clone https://aur.archlinux.org/trizen.git
	cd trizen
	makepkg -si # NOT sudo
	cd ..
	rm -rf trizen
fi

sudo gpasswd -a "$USER" docker

chsh -s /bin/bash # $(which bash)

find ~ -maxdepth 1 -type d -regex '^\./[A-Z].+' -regextype egrep -delete

sudo pacman --sync --needed "${pkgs[@]}"

# WARN: removing manjaro-zsh-config WILL irreparably break login (not even tty
# will work)
sudo pacman --remove --recursive pamac-gtk3 manjaro-application-utility

# need non-oss version for devcontainer; this is non-negotiable
trizen --sync visual-studio-code-bin

chezmoi init hejops # git creds not required
chezmoi apply

if ! ssh -T git@github.com 2>&1 | grep 'successfully authenticated'; then

	ssh_key="$HOME/.ssh/github_$(date -I)"

	ssh-keygen -t ed25519 -C hejops1@gmail.com -f "$ssh_key"

	# oldschool ssh-agent will no longer be needed
	/usr/bin/gh auth login # opens browser
	/usr/bin/gh auth refresh -h github.com -s admin:public_key
	/usr/bin/gh ssh-key add "$ssh_key".pub

	# ssh-keygen -t ed25519 -C "$WORK_EMAIL" -f "$HOME/.ssh/gitlab_$(date -I)"
	# cat "$HOME/.ssh/gitlab_$(date -I)" | xclip
	# firefox $WORK_GITLAB/-/user_settings/ssh_keys

fi

nvim +Mason # wait for installs to finish

cd
git clone https://github.com/hejops/dwm
cd ~/dwm
echo >> ./config.h # force recompile
sudo make install

cd
git clone https://github.com/hejops/gripts
cd ~/gripts/dwmstatus
go build

# TODO: disable /etc/bash.bashrc

# bash ~/.mozilla/restore.sh

# bash ~/.local/share/fonts/download_fonts

# systemctl restart lightdm
