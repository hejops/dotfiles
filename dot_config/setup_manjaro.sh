set -euo pipefail

pkgs=(

	# vim
	adobe-source-code-pro-fonts
	chezmoi
	clang
	eza
	fzf
	github-cli
	go
	jq
	luacheck
	make
	npm
	nvim
	pacman-contrib
	rofi
	shellharden # mason install requires cargo (rustup)
	wezterm
	xclip
	yazi

)

pacman -S "${pkgs[@]}"

chezmoi init hejops # git creds not required
chezmoi apply

# WARN: removing manjaro-zsh-config WILL irreparably break login (not even tty
# will work)
pacman --remove --recursive pamac-gtk3 manjaro-application-utility

ssh_key="$HOME/.ssh/github_$(date -I)"

ssh-keygen -t ed25519 -C hejops1@gmail.com -f "$ssh_key"

# oldschool ssh-agent will no longer be needed
/usr/bin/gh auth login # opens browser
/usr/bin/gh auth refresh -h github.com -s admin:public_key
/usr/bin/gh ssh-key add "$ssh_key".pub

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

# firefox

# systemctl restart lightdm
