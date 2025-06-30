set -euo pipefail

pkill firefox || :

if [[ -d ~/snap ]]; then
	MOZ_DIR=~/snap/firefox/common/.mozilla/ # ubuntu
else
	MOZ_DIR=~/.mozilla
fi

PROFILE_DIR="$MOZ_DIR"/firefox/default

# chezmoi will still track files in the old 4cl... dir, but will no longer be
# able to 'sync' changes to the new default dir. the correct migration strategy
# is to just wipe all existing sessions, run this script, and update dotfiles
# once and for all. it will probably take a while to clear my tab backlog
# though...
rm -rf "$MOZ_DIR"/firefox
rm -rf "$MOZ_DIR"/extensions
rm -rf "$MOZ_DIR"/native-messaging-hosts

# in the meantime, just do
# cp ~/.mozilla/firefox/default/user.js ~/.local/share/chezmoi/dot_mozilla/firefox/4clnophl.default/user.js
# cp ~/.mozilla/firefox/default/chrome/* ~/.local/share/chezmoi/dot_mozilla/firefox/4clnophl.default/chrome

mkdir -p "$MOZ_DIR"/firefox

cat << EOF > $MOZ_DIR/firefox/profiles.ini
[Install4F96D1932A9F858E]
Default=default

[Profile0]
Name=default
IsRelative=1
Path=default
EOF

cat << EOF > $MOZ_DIR/firefox/installs.ini
[4F96D1932A9F858E]
Default=default
Locked=1
EOF

cp -r ~/.local/share/chezmoi/dot_mozilla/firefox/4clnophl.default "$PROFILE_DIR"

# https://askubuntu.com/a/73480
# https://devicetests.com/install-firefox-addon-command-line
# https://github.com/LukeSmithxyz/LARBS/blob/master/static/larbs.sh#L232
# https://stackoverflow.com/a/37739112

EXT_DIR=$MOZ_DIR/firefox/default/extensions
mkdir -p "$EXT_DIR"

addons=(

	# auto-tab-discard # native of ff 93 https://support.mozilla.org/en-US/kb/unload-inactive-tabs-save-system-memory-firefox
	cookie-autodelete
	tridactyl-vim
	ublock-origin
)

need_tst=
if [[ $(firefox --version | grep -Po '\d[^.]+') -lt 136 ]]; then
	need_tst=1
	addons+=(tree-style-tab) # TODO: consider sidebery or tabcenter-reborn
fi

# note: addons still must be enabled (unless there's some about:config option
# that allows skipping this)
tmpdir=$(mktemp -d)
for addon in "${addons[@]}"; do
	# TODO: github xpi not verified

	# if [ "$addon" = ublock-origin ]; then
	# 	addonurl="$(
	# 		curl -sL https://api.github.com/repos/gorhill/uBlock/releases/latest |
	# 			grep -P 'browser_download_url.*\.firefox\.xpi' |
	# 			cut -d'"' -f4
	# 	)"
	# else

	addonurl="$(curl -sL "https://addons.mozilla.org/en-US/firefox/addon/${addon}/" |
		grep -o 'https://addons.mozilla.org/firefox/downloads/file/[^"]*')"

	# fi

	file="${addonurl##*/}"
	curl -sLO "$addonurl" > "$tmpdir/$file"
	id="$(unzip -p "$file" manifest.json | grep '"id"' | cut -d'"' -f4)"
	mv "$file" "$EXT_DIR/$id.xpi"
done

# TODO: sidebar = tst (workaround: xdotool (which is already in tri))

rm -rf "$tmpdir"

if [ ! -f "$MOZ_DIR"/native-messaging-hosts/tridactyl.json ]; then
	curl \
		-fsSl https://raw.githubusercontent.com/tridactyl/native_messenger/master/installers/install.sh \
		-o /tmp/trinativeinstall.sh &&
		sh /tmp/trinativeinstall.sh master
	# tridactyl :source not really necessary, just restart
fi

# https://github.com/Alex313031/Mercury/blob/673aa3e8f3fcbf3436b12186212708d3aa7b853c/policies/policies.json#L11
# https://github.com/dm0-/installer/blob/6cf8f0bbdc91757579bdcab53c43754094a9a9eb/configure.pkg.d/firefox.sh#L95
# https://github.com/yokoffing/Betterfox/blob/master/policies.json
# https://mozilla.github.io/policy-templates/

# TODO: restore addon settings (storage/default/moz-extension*)

# ublock: google -- disable inline scripts

# https://github.com/BryceVandegrift/ffsetup/blob/4b17486ed6e1360076f3f8f297d9cde7adad5c9c/ffsetup.sh#L67
firefox --headless > /dev/null 2>&1 & # generate extensions.json
sleep 10
pkill firefox
sed -i '
	s/\(seen":\)false/\1true/g
	s/\(active":\)false\(,"userDisabled":\)true/\1true\2false/g
' "$PROFILE_DIR"/extensions.json
sed -i 's/\(extensions\.pendingOperations", \)false/\1true/' "$PROFILE_DIR"/prefs.js

# # TODO: cookies.sqlite -- block cookies on consent.youtube.com
# sqlite3 $FF_PROFILE_DIR/cookies.sqlite "INSERT INTO moz_cookies VALUES(5593,'^firstPartyDomain=youtube.com','CONSENT','PENDING+447','.youtube.com','/',1723450203,1660378445948074,1660378204032779,1,0,0,1,0,2);"
# INSERT INTO moz_cookies VALUES(2358,'^firstPartyDomain=youtube.com','CONSENT','PENDING+675','.youtube.com','/',1727208372,1664136373196881,1664136373196881,1,0,0,1,0,2);

# pre-installed search engines can only be hidden, not removed (this is why the
# default engines can -always- be restored)
# TODO: might not actually work?
search_lz4=$MOZ_DIR/firefox/default/search.json.mozlz4
wget https://github.com/jusw85/mozlz4/releases/download/v0.1.0/mozlz4-linux
chmod +x mozlz4-linux
# disable all engines except ddg
./mozlz4-linux -x "$search_lz4" |
	jq '.engines[] | ._metaData.hidden = .id != "ddg"' |
	./mozlz4-linux -z - "$search_lz4"
rm mozlz4-linux

# need gui startup to create xulstore
firefox

# < $MOZ_DIR/firefox/default/xulstore.json jq '."chrome://browser/content/browser.xhtml"."toolbar-menubar".autohide = true'

# not sure if these are still relevant
< "$PROFILE_DIR"/xulstore.json jq '
{"chrome://browser/content/browser.xhtml": {
	"toolbar-menubar": { "autohide": "true" }, # autohide menu bar
	"PersonalToolbar": { "collapsed": "false" }
}}'

# activate TST sidebar
if [[ -n $need_tst ]]; then
	< "$PROFILE_DIR"/xulstore.json jq '."chrome://browser/content/browser.xhtml"."sidebar-title".value = "Tree Style Tab"'
fi

sqlite3 "$PROFILE_DIR"/places.sqlite "DELETE FROM moz_bookmarks;"
sqlite3 "$PROFILE_DIR"/places.sqlite "DELETE FROM moz_places;"

# manual action required (why?):
# customize toolbar (remove spaces, add search bar)
