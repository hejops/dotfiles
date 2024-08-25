-- https://github.com/pynappo/dotfiles/blob/ec6476a4cb78176be10293812c02dda7a4ac999a/.config/wezterm/wezterm.lua
-- https://gist.github.com/alexpls/83d7af23426c8928402d6d79e72f9401
-- https://github.com/pynappo/dotfiles/blob/ec6476a4cb78176be10293812c02dda7a4ac999a/.config/wezterm/wezterm.lua#L182

-- TODO: investigate high memory usage (up to 1.3 GB RSS)
-- pmap -x $(\pgrep wezterm-gui) | sort -k3 -n | tail -n20
--
-- https://github.com/wez/wezterm/issues/2626
--
-- benchmarks (dwmstatus):
-- cold boot (1 term + ff):
-- warm login (1 term + ff): 4.0 G
-- extended uptime (~1 week): >7 G

-- 00005bb89ee9e000    5640    5640    5640 r---- wezterm-gui
-- 0000797ca8000000    5828    5824    5824 rw---   [ anon ]
-- 0000797c90000000    5992    5960    5960 rw---   [ anon ]
-- 0000797b8c000000    6988    6036    6036 rw---   [ anon ]
-- 0000797bec000000    6108    6108    6108 rw---   [ anon ]
-- 0000797caf1c2000   11364    6392       0 r---- radeonsi_dri.so
-- 00005bb89bb5f000    6620    6600       0 r---- wezterm-gui
-- 0000797c9c000000    9756    9708    9708 rw---   [ anon ]
-- 0000797cadc14000   22200   13584       0 r-x-- radeonsi_dri.so
-- 0000797ac4000000   15232   15232   15232 rw---   [ anon ]
-- 00005bb89c1d6000   32252   16292       0 r-x-- wezterm-gui
-- 0000797c74e9d000   46436   19704       0 r---- libLLVM.so.18.1
-- 0000797a94000000   23448   23448   23448 rw---   [ anon ]
-- 0000797b54000000   30552   30488   30488 rw---   [ anon ]
-- 0000797c702ab000   77768   52480       0 r-x-- libLLVM.so.18.1
-- 0000797b50000000   62184   62184   62184 rw---   [ anon ]
-- 0000797b60000000   62596   62596   62596 rw---   [ anon ]
-- 0000797c14000000   65228   63048   63048 rw---   [ anon ]
-- 00005bb8d87ea000  692676  692536  692536 rw---   [ anon ]
-- total kB         7587336 1325072 1155516

-- reasons to use wezterm over kitty:
-- declarative config
-- auto-sourced config
-- much easier os-specific config
-- superior documentation

-- reasons not to use wezterm:
-- memory leak

local wezterm = require("wezterm")

local act = wezterm.action
local config = {}

-- TODO: tab title?
-- TODO: projects (see old kitty example)

-- https://github.com/P1n3appl3/config/blob/46b4935f2a0d9cf88ebc444bac5b10c03e8c6df3/dotfiles/.config/wezterm/wezterm.lua#L46
-- https://github.com/wez/wezterm/blob/main/docs/config/lua/wezterm/on.md#example-opening-whole-scrollback-in-vim
-- open scrollback in less
wezterm.on("view-history-in-pager", function(window, pane)
	local text = pane:get_lines_as_escapes(pane:get_dimensions().scrollback_rows)

	-- TODO: mkfifo or something to avoid writing tmpfile?
	local name = os.tmpname()
	local f = io.open(name, "w+")
	f:write(text)
	f:flush()
	f:close()

	window:perform_action(act.SpawnCommandInNewTab({ args = { "less", "-R", name } }), pane)
	wezterm.sleep_ms(5000)
	os.remove(name)
end)

wezterm.on(
	"watch",
	-- spawn new window for watch testing
	-- this is similar to exec (in my init.lua); but i generally don't want to
	-- run tests in a vim split
	-- https://github.com/rwxrob/dot/blob/fa81b2b138805276a35b458196b67ddb87660505/scripts/goentrtest
	-- https://github.com/vouch/vouch-proxy/blob/ad2e9ac8ad03e7d22cdbb44abc47c74ad046071a/do.sh#L109C1-L109C38
	function(window, pane)
		-- determine what lang we are in. we always assume we are at project root

		-- ideally, the table should be something like
		-- go = {
		--	f = 'go.mod', -- how to tell what lang
		--	proc = 'entr', -- how to tell if we are running (via pgrep etc)
		--	cmd = {...}, -- what to do
		-- }
		-- but this is fine for now

		local watchers = {
			["Cargo.toml"] = { "cargo", "watch", "-x", "check", "-x", "test" },
			["go.mod"] = { "bash", "-c", "find . -name '*.go' | entr -cr go test" },
			["pyproject.toml"] = { "bash", "-c", "find . -name '*.py' | entr -cr poetry run pytest -x -vv" },
			-- ["pyproject.toml"] = { "poetry", "run", "pytest", "-x", "-vv" },
		}

		-- https://github.com/rust-lang/rust/blob/master/src/doc/rustc/src/tests/index.md#cli-arguments
		-- runner = "cargo test -- --include-ignored --show-output" -- incl test stdout
		-- runner = "cargo test -- --include-ignored --nocapture" -- incl test debug messages

		-- TODO: prevent duplicate

		for f, cmd in pairs(watchers) do
			local fo = io.open(
				-- get_current_working_dir returns url (file://...)
				pane:get_current_working_dir().file_path
					.. "/"
					.. f,
				"r"
			)
			if fo ~= nil then
				io.close(fo)
				window:perform_action(act.SpawnCommandInNewWindow({ args = cmd }), pane)
				return
			end
		end
	end
)

-- font {{{

-- wezterm.font("Haskplex", {weight="Regular", stretch="Normal", style="Normal"})

local font = wezterm.font_with_fallback({
	-- quirky
	-- "Silkscreen", -- allcaps
	-- "mononoki", -- can get very crowded
	-- "Intel One Mono", -- cramped {x}, too wide
	-- "Monaspace Argon", -- large
	-- "Terminus", -- if you like pretending to be in the login shell
	-- "Z003", -- hilarious

	-- round
	-- "Inconsolata", -- classic
	-- "Uiua386", -- comic sans-ish
	-- "Google Sans Mono", -- a bit too round...

	-- narrow
	-- "Iosevka",

	-- regular
	-- "IBM Plex Mono", -- too tall
	-- "Fira Mono", -- feels cramped
	-- "SF Mono", -- '--' too close
	-- "Martian Mono", -- very large
	-- "Haskplex", -- literally the same as SCP
	"Source Code Pro",
})

config.cell_width = 0.9
config.font = font
config.font_size = 10.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.warn_about_missing_glyphs = false
config.window_frame = { font = font, font_size = 10 }

-- }}}
-- appearance {{{

-- config.default_cursor_style = "SteadyBlock"
-- config.enable_kitty_graphics = false -- ranger: iterm2
-- config.window_background_opacity = 0.8 -- see opacity-rule in picom.conf
config.color_scheme = "citruszest"
config.default_prog = { "bash" } -- source .bashrc
config.enable_scroll_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.text_background_opacity = 0.8
config.use_fancy_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- }}}
-- keys {{{

local function keys()
	local leader = "SHIFT|CTRL"

	local keys = {

		-- https://github.com/wez/wezterm/tree/main/docs/config/lua/keyassignment

		-- https://github.com/wez/wezterm/blob/30345b36d8a00fed347e4df5dadd83915a7693fb/wezterm-gui/src/overlay/quickselect.rs#L26
		-- https://github.com/wez/wezterm/blob/main/docs/config/lua/config/quick_select_patterns.md#quick_select_patterns
		-- https://github.com/wez/wezterm/blob/main/docs/quickselect.md

		-- https://github.com/wez/wezterm/blob/main/docs/config/lua/keyassignment/PromptInputLine.md#example-of-interactively-renaming-the-current-tab
		-- https://github.com/wez/wezterm/blob/main/docs/config/lua/keyassignment/Search.md#search

		-- https://github.com/wez/wezterm/blob/main/docs/config/launch.md#the-launcher-menu

		-- both SpawnWindow and SpawnTab should (sanely) default to cwd
		{ key = "e", mods = "CTRL", action = act.SpawnWindow },
		{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },

		-- { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },

		{ key = "h", mods = leader, action = act.ActivateTabRelative(-1) },
		{ key = "j", mods = leader, action = act.ScrollByPage(1) },
		{ key = "k", mods = leader, action = act.ScrollByPage(-1) },
		{ key = "l", mods = leader, action = act.ActivateTabRelative(1) },
		{ key = "w", mods = leader, action = act.EmitEvent("watch") },

		{ key = "x", mods = leader, action = act.EmitEvent("view-history-in-pager") },

		-- note: ctrl-l is bound to readline's forward-word
		{
			key = "z",
			mods = "CTRL",
			action = act.ClearScrollback("ScrollbackAndViewport"),
			-- action = act.Multiple({
			-- 	act.ClearScrollback("ScrollbackAndViewport"),
			-- 	act.SendKey({ key = "L", mods = "CTRL" }),
			-- }),
		},
	}

	-- TODO: use weruio (?) instead of numbers (when the need arises)
	for i = 0, 9 do
		table.insert(keys, { key = tostring(i), mods = leader, action = act.ActivateTab(i) })
	end

	-- https://github.com/wez/wezterm/issues/1362#issuecomment-1000457693
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/QuickSelectArgs.html
	local hint_url = {
		QuickSelectArgs = {
			patterns = {
				"https?://\\S+",
				-- add more
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("opening: " .. url)
				wezterm.open_with(url)
			end),
		},
	}

	table.insert(keys, { key = "g", mods = "CTRL", action = wezterm.action(hint_url) })

	return keys
end

config.keys = keys()

-- }}}

return config
