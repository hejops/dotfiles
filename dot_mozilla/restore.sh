set -euo pipefail

pkill firefox || :

if [[ -d ~/snap ]]; then
	MOZ_DIR=~/snap/firefox/common/.mozilla/ # ubuntu
else
	MOZ_DIR=~/.mozilla
fi

PROFILE_DIR="$MOZ_DIR"/firefox/default

# find "$MOZ_DIR" -name recovery.jsonlz4
# mozlz4 -x ~/.mozilla/firefox/*default/sessionstore-backups/recovery.jsonlz4 |
# 	jq -r '.windows[0].tabs[].entries[-1].url' |
# 	grep ^http |
# 	sort -u

# note: logins.json can never be restored

# rm -rf "$MOZ_DIR" # would remove restore.sh
rm -rf "$MOZ_DIR"/extensions
rm -rf "$MOZ_DIR"/firefox
rm -rf "$MOZ_DIR"/native-messaging-hosts

mkdir -p "$MOZ_DIR"/firefox

# TODO: random hex? can it be 1 char?

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

cp -r ~/.local/share/chezmoi/dot_mozilla/firefox/default "$PROFILE_DIR"

# https://askubuntu.com/a/73480
# https://devicetests.com/install-firefox-addon-command-line
# https://github.com/LukeSmithxyz/LARBS/blob/master/static/larbs.sh#L232
# https://stackoverflow.com/a/37739112

NEW_PROFILE_DIR=$MOZ_DIR/firefox/default
EXT_DIR=$NEW_PROFILE_DIR/extensions
mkdir -p "$EXT_DIR"

addons=(

	# auto-tab-discard # native as of ff 93 https://support.mozilla.org/en-US/kb/unload-inactive-tabs-save-system-memory-firefox
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
< "$PROFILE_DIR"/extensions.json jq '

	.addons[].active = true;
	.addons[].appDisabled = false;
	.addons[].embedderDisabled = false;
	.addons[].softDisabled = false;
	.addons[].userDisabled = false;
'

sed -i 's/\(extensions\.pendingOperations", \)false/\1true/' "$MOZ_DIR"/firefox/default/prefs.js

# pre-installed search engines can only be hidden, not removed (this is why the
# default engines can -always- be restored)
# TODO: might not actually work?
search_lz4=$MOZ_DIR/firefox/default/search.json.mozlz4

# disable all engines except ddg
# might not work? (reverts to google)
mozlz4 -x "$search_lz4" |
	# "defaultEngineIdHash": "nVbjzSsX6W+tHUrVamgarg//cmHv2Ul2ykTB2j5qPbE="
	jq '
		.engines[] | ._metaData.hideOneOffButton = .id != "ddg";
		.metaData.defaultEngineId = "ddg"
	' |
	mozlz4 -z - "$search_lz4"

# need gui startup to create xulstore
firefox

# autohide menu bar
< "$PROFILE_DIR"/xulstore.json jq '."chrome://browser/content/browser.xhtml"."toolbar-menubar".autohide = true'

# activate TST sidebar
if [[ -n $need_tst ]]; then
	# TODO: sidebar = tst (workaround: xdotool (which is already in tri))
	< "$PROFILE_DIR"/xulstore.json jq '."chrome://browser/content/browser.xhtml"."sidebar-title".value = "Tree Style Tab"'
fi

sqlite3 "$PROFILE_DIR"/places.sqlite "DELETE FROM moz_bookmarks;"
sqlite3 "$PROFILE_DIR"/places.sqlite "DELETE FROM moz_places;"

# manual action required (why?):
# disable, then enable addons (about:addons)
# restore tabs (make sure tri is enabled first, else not grouped)
# remove elements from toolbar (warn: removing 'list all tabs' also removes sidebar?)
# set search engine
# restore ublock
# disable all themes except dark
