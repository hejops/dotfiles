// https://glide-browser.app/config
// https://glide-browser.app/api
// https://github.com/glide-browser/glide/tree/main/src/glide/browser/base/content/plugins
// https://github.com/glide-browser/glide/blob/main/src/glide/browser/base/content/plugins/keymaps.mts

// init_config home
// note: .d.ts file is required for typing, but this is not checked in

// if glide one day supports addon installs...
// https://ba.ln.ea.cx/src/marsironpi/dotfiles/tree/common/.vimfx/config.js?id=95d7f9c741cadccb4c7005a1a18039452fd96e6d#n487

// TODO: 1. containers
// TODO: 2. import tabs
// TODO: addons
// TODO: search engine
// TODO: sort tabs

// hintchars not configurable (resource://glide-docs/hints.html#label-generation)

// ~/.glide/glide/*.default

// glide.keymaps.set("normal", "b", "tab");
glide.keymaps.del("normal", "yy");
glide.keymaps.set("normal", ",", "tab_next");
glide.keymaps.set("normal", "H", "back");
glide.keymaps.set("normal", "J", "scroll_page_down"); // often buggy (scrolls by 1px)
glide.keymaps.set("normal", "K", "scroll_page_up");
glide.keymaps.set("normal", "L", "forward");
glide.keymaps.set("normal", "b", "commandline_show tab ");
glide.keymaps.set("normal", "c", "tab_prev");
glide.keymaps.set("normal", "d", "tab_close");
glide.keymaps.set("normal", "q", "config_reload");
glide.keymaps.set("normal", "y", "url_yank");

//
