set -euo pipefail

pkill firefox || :

if [[ -d ~/snap ]]; then
	MOZ_DIR=~/snap/firefox/common/.mozilla/ # ubuntu
else
	MOZ_DIR=~/.mozilla
fi

rm -rf $MOZ_DIR/firefox
rm -rf $MOZ_DIR/extensions
rm -rf $MOZ_DIR/native-messaging-hosts

mkdir -p $MOZ_DIR/firefox

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

cp -r ~/.local/share/chezmoi/dot_mozilla/firefox/4clnophl.default $MOZ_DIR/firefox/default

# https://askubuntu.com/a/73480
# https://devicetests.com/install-firefox-addon-command-line
# https://github.com/LukeSmithxyz/LARBS/blob/master/static/larbs.sh#L232
# https://stackoverflow.com/a/37739112

EXT_DIR=$MOZ_DIR/firefox/default/extensions
mkdir -p $EXT_DIR

addons=(

	auto-tab-discard
	cookie-autodelete
	tridactyl-vim
	ublock-origin
	tree-style-tab # TODO: consider sidebery or tabcenter-reborn
)

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

if [ ! -f $MOZ_DIR/native-messaging-hosts/tridactyl.json ]; then
	curl \
		-fsSl https://raw.githubusercontent.com/tridactyl/native_messenger/master/installers/install.sh \
		-o /tmp/trinativeinstall.sh &&
		sh /tmp/trinativeinstall.sh master
	# tridactyl :source not really necessary, just restart
fi

# TODO: remove search engines except ddg; policies.json is ESR-only,
# tragic...
# https://mozilla.github.io/policy-templates/#searchengines--remove

# https://github.com/Alex313031/Mercury/blob/673aa3e8f3fcbf3436b12186212708d3aa7b853c/policies/policies.json#L11
# https://github.com/dm0-/installer/blob/6cf8f0bbdc91757579bdcab53c43754094a9a9eb/configure.pkg.d/firefox.sh#L95
# https://github.com/yokoffing/Betterfox/blob/master/policies.json
# https://mozilla.github.io/policy-templates/

# TODO: restore addon settings (storage/default/moz-extension*)

# ublock: google -- disable inline scripts

# something in my userchrome prevents addon popup from being clicked,
# apparently
sed -i -r '/legacyUserProfileCustomizations/ s#^#//#' $MOZ_DIR/firefox/default/user.js

firefox 'about:addons' # manually enable addons

sed -i -r '/legacyUserProfileCustomizations/ s#^// *##' $MOZ_DIR/firefox/default/user.js

# # TODO: cookies.sqlite -- block cookies on consent.youtube.com
# sqlite3 $FF_PROFILE_DIR/cookies.sqlite "INSERT INTO moz_cookies VALUES(5593,'^firstPartyDomain=youtube.com','CONSENT','PENDING+447','.youtube.com','/',1723450203,1660378445948074,1660378204032779,1,0,0,1,0,2);"
# INSERT INTO moz_cookies VALUES(2358,'^firstPartyDomain=youtube.com','CONSENT','PENDING+675','.youtube.com','/',1727208372,1664136373196881,1664136373196881,1,0,0,1,0,2);

sqlite3 $MOZ_DIR/firefox/default/places.sqlite "DELETE FROM moz_bookmarks;"
sqlite3 $MOZ_DIR/firefox/default/places.sqlite "DELETE FROM moz_places;"

firefox 'about:preferences#search'

# manual action required:
# change default search engine to ddg
# wait for tri, then activate sidebar (T)
# disable menu bar
# customize toolbar (remove spaces, add search bar)
