# set up gmail<>notmuch sync, via lieer. lieer uses oauth instead of app
# passwords, making it useful for org accounts where app passwords cannot be
# created
#
# oauth tokens can be revoked at
# https://myaccount.google.com/connections?filters=3,4&hl=en

set -euo pipefail

if ! command -v gmi > /dev/null; then
	echo "gmi not installed"
fi

if [[ -d ~/.mail ]]; then
	echo "moving existing .mail dir to .mail_bak..."
	mv ~/.mail ~/.mail_bak
fi

notmuch new # init .mail dir
mkdir -p ~/.mail/account.gmail
cd ~/.mail/account.gmail

sed -r '
	/^tags/		s#.*#tags=new#
	/^ignore/	s#.*#ignore=/.*[.](json|lock|bak)$/#
' -i "$(chezmoi source-path ~/.config/notmuch/config)"
# ' -i ~/.config/notmuch/config
chezmoi apply -v

read -r -p 'email: ' email < /dev/tty
gmi init "$email" # authenticate in browser

echo "init ok"
< ./.credentials.gmailieer.json jq

gmi pull # need to be in /account.gmail
