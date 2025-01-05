-- https://github.com/pynappo/dotfiles/blob/ec6476a4cb78176be10293812c02dda7a4ac999a/.config/wezterm/wezterm.lua
-- https://gist.github.com/alexpls/83d7af23426c8928402d6d79e72f9401
-- https://github.com/pynappo/dotfiles/blob/ec6476a4cb78176be10293812c02dda7a4ac999a/.config/wezterm/wezterm.lua#L182

-- os.execute("notify-send hi")

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
local log = wezterm.log_info

local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local function get_output(command)
	local handle = io.popen(command)
	_ = handle:read("*a")
	return handle:close()
end

local is_ubuntu = get_output("grep Ubuntu /etc/*-release")

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
	function(window, pane) -- {{{
		-- determine what lang we are in. we always assume we are at project root

		-- ideally, the table should be something like
		-- go = {
		--	f = 'go.mod', -- how to tell what lang
		--	proc = 'entr', -- how to tell if we are running (via pgrep etc)
		--	cmd = {...}, -- what to do
		-- }
		-- but this is fine for now

		local watchers = {

			-- ["pyproject.toml"] = { "poetry", "run", "pytest", "-x", "-vv" },
			["Cargo.toml"] = { "cargo", "watch", "-x", "check", "-x", "test" },
			["go.mod"] = { "bash", "-c", "find . -name '*.go' | entr -cr go test ./..." },
			["pyproject.toml"] = { "bash", "-c", "find . -name '*.py' | entr -cr poetry run pytest -x -vv" },
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
	end -- }}}
)

config.pane_focus_follows_mouse = true
config.switch_to_last_active_tab_when_closing_tab = true

-- font {{{

-- wezterm.font("Haskplex", {weight="Regular", stretch="Normal", style="Normal"})

-- wezterm ls-fonts --list-system | cut -d, -f1 | grep ^wez | cut -d'(' -f2 | sort -u | append ,

-- note: source han sans is implicitly used as fallback for cn/jp/kr (which is
-- why scp goes great with it). scp also has cyrillic
local font = wezterm.font_with_fallback({

	-- https://devfonts.gafi.dev
	-- https://www.codingfont.com
	-- https://www.programmingfonts.org

	-- quirky
	-- "mononoki", -- very cramped
	-- "Intel One Mono", -- cramped {x}, too wide
	-- "Monaspace Argon", -- cramped
	-- "Terminus", -- too thin
	-- "Silkscreen", -- allcaps
	-- "Z003", -- hilarious

	-- round
	-- "Google Sans Mono", -- somewhat round (but exact same size as SCP); latin only
	-- "Commit Mono", -- tall, vertically cramped
	-- "Inconsolata", -- small (need +2), vertically cramped
	-- "Uiua386", -- comic sans-ish (not very readable imo)
	-- "Geist Mono", -- chonky

	-- narrow
	"NanumGothicCoding", -- only has underline >= 12
	-- "Mplus Code 60", -- too tall, otherwise quite good
	-- "Iosevka",

	-- regular
	-- "IBM Plex Mono", -- tall
	-- "Fira Mono", -- cramped
	-- "SF Mono", -- '--' too close (almost ligature-ish)
	-- "Input Mono", -- why so short?
	"Source Code Pro",
})

if is_ubuntu then
	-- https://github.com/wez/wezterm/issues/284#issuecomment-1177628870
	wezterm.on("gui-startup", function() -- note: not reliable
		local _, _, window = wezterm.mux.spawn_window({})
		window:gui_window():maximize()
	end)
end

-- config.freetype_load_flags = "NO_HINTING" -- squashes fonts (makes them shorter)

-- -- yikes
-- config.freetype_load_flags = "MONOCHROME"
-- config.freetype_load_target = "Mono"

local cell_width = 0.9

-- relying on xrdb dpi is unreliable, as ubuntu seems to ignore it
local font_size
if is_ubuntu then
	-- note: xrandr is unacceptably slow
	font_size = get_output("xdpyinfo | grep -F '3840x1200'") and 12.0 or 18.0
else
	font_size = 10.0
end

-- config.font, config.font_size = wezterm.font_with_fallback({ "B612 Mono" }), 9.0
-- config.font, config.font_size = wezterm.font_with_fallback({ "Source Code Pro" }), 10.0
config.cell_width = cell_width > 0 and cell_width or 0.9 -- negative values will kill wezterm
config.command_palette_font_size = font_size
config.font = font
config.font_size = font_size
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.warn_about_missing_glyphs = false
config.window_frame = { font = font, font_size = font_size }

-- }}}
-- appearance {{{

-- config.default_cursor_style = "SteadyBlock"
-- config.default_domain = "unix"
-- config.enable_kitty_graphics = false -- ranger: iterm2
-- config.window_background_opacity = 0.8 -- see opacity-rule in picom.conf
config.color_scheme = "citruszest"
config.default_cwd = wezterm.home_dir
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

	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/PromptInputLine.html#example-of-interactively-renaming-the-current-tab
	local rename_tab = {
		-- initial_value = "My Tab Name", -- nightly only
		description = "Rename tab",
		action = wezterm.action_callback(function(window, pane, line)
			_ = pane
			if line then
				window:active_tab():set_title(line)
			end
		end),
	}

	-- https://github.com/wez/wezterm/issues/1362#issuecomment-1000457693
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/QuickSelectArgs.html
	local hint_url = {
		QuickSelectArgs = {
			patterns = {
				-- https://wezfurlong.org/wezterm/config/lua/config/hyperlink_rules.html
				-- "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
				"\\b\\w+://\\S+[/a-zA-Z0-9-]+",
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				-- log("opening: " .. url)
				-- if string.find(url, "youtu") then
				-- 	wezterm.open_with(url, "mpv")
				-- 	return
				-- end
				wezterm.open_with(url)
			end),
		},
	}

	local function SpawnTabNext()
		-- https://old.reddit.com/r/wezterm/comments/1d71ei3/how_to_make_spawntab_spawn_a_new_tab_next_to/l759axf/
		local function active_tab_index(window)
			for _, item in ipairs(window:mux_window():tabs_with_info()) do
				if item.is_active then
					return item.index
				end
			end
		end

		return wezterm.action_callback(function(win, pane)
			local prev_active_tab_index = active_tab_index(win)
			win:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
			win:perform_action(act.MoveTab(prev_active_tab_index + 1), pane)
		end)
	end

	local _keys = {

		-- https://github.com/wez/wezterm/tree/main/docs/config/lua/keyassignment

		-- https://github.com/wez/wezterm/blob/30345b36d8a00fed347e4df5dadd83915a7693fb/wezterm-gui/src/overlay/quickselect.rs#L26
		-- https://github.com/wez/wezterm/blob/main/docs/config/lua/config/quick_select_patterns.md#quick_select_patterns
		-- https://github.com/wez/wezterm/blob/main/docs/quickselect.md

		-- https://github.com/wez/wezterm/blob/main/docs/config/lua/keyassignment/PromptInputLine.md#example-of-interactively-renaming-the-current-tab
		-- https://github.com/wez/wezterm/blob/main/docs/config/lua/keyassignment/Search.md#search

		-- https://github.com/wez/wezterm/blob/main/docs/config/launch.md#the-launcher-menu

		-- both SpawnWindow and SpawnTab default to cwd
		-- { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "e", mods = "CTRL", action = act.SpawnWindow },
		{ key = "t", mods = "CTRL", action = SpawnTabNext() },
		{ key = "t", mods = leader, action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir }) },

		{ key = "o", mods = leader, action = act.ShowTabNavigator },

		{ key = "h", mods = leader, action = act.ActivateTabRelative(-1) },
		{ key = "j", mods = leader, action = act.ScrollByPage(1) },
		{ key = "k", mods = leader, action = act.ScrollByPage(-1) },
		{ key = "l", mods = leader, action = act.ActivateTabRelative(1) },

		{ key = "g", mods = "CTRL", action = act(hint_url) },
		{ key = "r", mods = "CTRL", action = act.PromptInputLine(rename_tab) },
		{ key = "w", mods = leader, action = act.EmitEvent("watch") },
		{ key = "x", mods = leader, action = act.EmitEvent("view-history-in-pager") },
		{ key = "z", mods = "CTRL", action = act.ClearScrollback("ScrollbackAndViewport") }, -- note: ctrl-l is bound to readline's forward-word

		{ key = "p", mods = leader, action = act.ActivateCommandPalette },
	}

	-- TODO: use weruio (?) instead of numbers (when the need arises)
	for i = 0, 9 do
		table.insert(_keys, { key = tostring(i), mods = leader, action = act.ActivateTab(i) })
	end

	local function get_active_pane(panes)
		for i, p in ipairs(panes) do
			-- log(i, p)
			if p.is_active then
				return i
			end
		end
	end

	local function resize(win, pane)
		local tab = pane:tab()
		local panes = tab:panes_with_info() -- https://wezfurlong.org/wezterm/config/lua/MuxTab/panes_with_info.html

		-- force right panes to have equal height
		local height = panes[1].height
		local r_height = math.floor(height / (#panes - 1)) -- before recalc

		for x = 2, #panes do
			panes = tab:panes_with_info() -- recalc
			-- log(panes[x])
			local p = panes[x].pane

			local diff = p:get_dimensions().viewport_rows - r_height
			local dir = diff > 0
					-- and x < #panes
					and "Up"
				or "Down"

			log("pane", x, #panes, "has height", p:get_dimensions().viewport_rows, "need", r_height, dir, diff)

			-- adjust Up on first split ignored
			-- adjust Down on last split ignored
			-- https://github.com/wez/wezterm/issues/4038

			-- > lua: opening new split: 4
			-- > lua: pane 2 4 has height 32 need 20 Up 12 (manual AdjustPaneSize call would have worked)
			-- > lua: height is now 32
			-- > lua: pane 3 4 has height 2 need 20 Down -18
			-- > lua: height is now 20
			-- > lua: pane 4 4 has height 8 need 20 Down -12
			-- > lua: height is now 1

			-- https://wezfurlong.org/wezterm/config/lua/pane/index.html
			-- https://wezfurlong.org/wezterm/config/lua/keyassignment/AdjustPaneSize.html

			if diff == 0 then
				log("already ok")
			else
				-- win:perform_action({ AdjustPaneSize = { dir, math.abs(diff) } }, p)
				win:perform_action(act.AdjustPaneSize({ dir, math.abs(diff) }), p)
			end

			log("height is now", tab:panes_with_info()[x].height)
		end
	end

	local test_keys = {
		-- https://github.com/nathanaelkane/dotfiles/blob/8b6c3f59157ccd85a51e20b580930f160d29e121/config/wezterm.lua#L163
		-- https://github.com/uolot/dotfiles/blob/aa07dd01fddab8c7ffaa2230f298946671979e1a/wezterm/balance.lua#L108

		{
			mods = "SUPER",
			key = "r",
			action = wezterm.action_callback(function(win, pane)
				resize(win, pane)
			end),
		},

		{
			mods = "SUPER",
			key = "t",
			action = wezterm.action_callback(function(win, pane)
				local tab = pane:tab()
				local panes = tab:panes_with_info() -- https://wezfurlong.org/wezterm/config/lua/MuxTab/panes_with_info.html

				if #panes == 3 then -- need to get resize working first
					return
				end

				local active_pane = panes[get_active_pane(panes)].pane
				-- local active_pane = tab.active_pane
				local cwd = active_pane:get_current_working_dir().file_path

				if #panes == 1 then
					log("first pane, splitting horiz (2)")
					panes[1].pane:split({
						direction = "Right",
						size = 0.45,
						cwd = cwd,
					})
					-- active_pane:activate()
					return
				end

				log("opening new split:", #panes + 1)
				panes[#panes].pane:split({
					direction = "Bottom",
					cwd = cwd,
				})
				-- resize(win, pane)
				-- active_pane:activate()
			end),
		},

		-- 'fullscreen' = pane:set_zoomed(true)

		-- TODO: on closing left pane (pane 1), activate pane 2 and move it left
		-- TODO: on closing any pane, resize all right panes

		-- https://github.com/wez/wezterm/discussions/3331#discussioncomment-9477701 (swap)
		-- https://github.com/wez/wezterm/issues/1975#issuecomment-1134817741 (tmux style select)

		-- https://wezfurlong.org/wezterm/config/lua/keyassignment/RotatePanes.html
		-- https://wezfurlong.org/wezterm/config/lua/keyassignment/PaneSelect.html

		-- { key = "k", mods = leader, action = wezterm.action.AdjustPaneSize({ "Up", 12 }) },

		{
			key = "i",
			mods = "SUPER",
			-- action = act.RotatePanes("Clockwise"),
			action = wezterm.action_callback(function(win, pane)
				-- os.execute("notify-send hi")
				-- local active = get_active_pane()
				win:perform_action(act.RotatePanes("Clockwise"), pane)
			end),
		},

		-- TODO: should only be reloaded when screen dimensions change
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/on.html
		{
			key = ",",
			mods = "SUPER",
			action = wezterm.action_callback(function()
				wezterm.reload_configuration()
			end),
		},

		-- note: disable ubuntu default keybinds first (< ~/.config/dconf/dconf.ini dconf load /)
		{ key = "h", mods = "SUPER", action = act.ActivateTabRelative(-1) },
		{ key = "j", mods = "SUPER", action = act.ActivatePaneDirection("Next") },
		{ key = "k", mods = "SUPER", action = act.ActivatePaneDirection("Prev") },
		{ key = "l", mods = "SUPER", action = act.ActivateTabRelative(1) },
	}

	local function extend(t1, t2)
		for _, v in ipairs(t2) do
			table.insert(t1, v)
		end
	end

	if is_ubuntu then
		extend(_keys, test_keys)
	end

	return _keys
end

config.keys = keys()

-- with Up 3
-- 1:22 -> 1:19
-- 2:9 -> 2:6
-- 3:3 -> 3:1
-- 4:1

-- without
-- 1:22
-- 2:11
-- 3:5
-- 4:2

-- expected:
-- 1:46 -> 2:23 -> 3:15 -> 4:11

-- local wezterm = require("wezterm")
-- config = wezterm.config_builder()
-- config.keys = {
-- 	{
-- 		mods = "SHIFT|CTRL",
-- 		key = "t",
-- 		action = wezterm.action_callback(function(win, pane)
-- 			local panes = pane:tab():panes_with_info()
-- 			log("new pane:", #panes + 1)
-- 			panes[1].pane:send_text(string.format("%d:%d ", 1, panes[1].height))
-- 			panes[#panes].pane:activate()
-- 			panes[#panes].pane:split({ direction = "Bottom" })
-- 			for i = 1, #panes + 1 do
-- 				local p = pane:tab():panes_with_info()[i]
-- 				win:perform_action({ AdjustPaneSize = { "Up", 3 } }, p.pane)
-- 				p.pane:send_text(string.format("%d:%d ", i, p.height))
-- 			end
-- 			panes[1].pane:activate()
-- 		end),
-- 	},
-- }

-- }}}

return config
