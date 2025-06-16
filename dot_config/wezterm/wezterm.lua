-- https://gist.github.com/alexpls/83d7af23426c8928402d6d79e72f9401
-- https://github.com/pynappo/dotfiles/blob/ec6476a4cb78176be10293812c02dda7a4ac999a/.config/wezterm/wezterm.lua#L182

-- reasons not to use wezterm:
-- memory leak

local wezterm = require("wezterm")
-- local log = wezterm.log_info

local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

---@return string
local function get_output(cmd)
	assert(cmd)
	---@type string
	local out, _ = assert(io.popen(cmd)):read("*all")
	return out
end

local is_ubuntu = get_output("grep Ubuntu /etc/*-release") ~= ""

-- local function extend(t1, t2)
-- 	for _, v in ipairs(t2) do
-- 		table.insert(t1, v)
-- 	end
-- end

-- wezterm.on("gui-startup", function()
-- 	local _, _, window = wezterm.mux.spawn_window({ args = { "yazi" } })
-- 	window:spawn_tab({ args = { "yazi" } })
-- 	window:spawn_tab({ args = { "yazi" } })
-- end)

-- behaviour {{{

-- config.default_domain = "unix"
-- config.enable_kitty_graphics = false -- ranger: iterm2
config.default_cwd = wezterm.home_dir
config.default_prog = { "bash" } -- source .bashrc
config.pane_focus_follows_mouse = true
config.switch_to_last_active_tab_when_closing_tab = true

-- https://github.com/P1n3appl3/config/blob/46b4935f2a0d9cf88ebc444bac5b10c03e8c6df3/dotfiles/.config/wezterm/wezterm.lua#L46
-- https://github.com/wez/wezterm/blob/main/docs/config/lua/wezterm/on.md#example-opening-whole-scrollback-in-vim
-- open scrollback in less
wezterm.on("view-history-in-pager", function(window, pane)
	local text = pane:get_lines_as_escapes(pane:get_dimensions().scrollback_rows)

	-- TODO: mkfifo or something to avoid writing tmpfile?
	local name = os.tmpname()
	local f = assert(io.open(name, "w+"))
	f:write(text)
	f:flush()
	f:close()

	window:perform_action(act.SpawnCommandInNewTab({ args = { "less", "-R", name } }), pane)
	wezterm.sleep_ms(5000)
	os.remove(name)
end)

-- }}}
-- font {{{

-- wezterm.font("Haskplex", {weight="Regular", stretch="Normal", style="Normal"})

-- wezterm ls-fonts --list-system | cut -d, -f1 | grep ^wez | cut -d'(' -f2 | sort -u | append ,

local fonts = {

	-- https://devfonts.gafi.dev
	-- https://www.codingfont.com
	-- https://www.programmingfonts.org

	-- quirky
	-- "Monaspace Argon", -- ubuntu-ish
	-- "Monaspace Xenon", -- serif
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
	-- "Monoisome", -- extremely wide

	-- narrow
	-- "NanumGothicCoding",
	-- "Mplus Code 60", -- too tall, otherwise quite good
	-- "Iosevka",

	-- regular
	-- "Monaspace Neon", -- good scp alternative
	-- "IBM Plex Mono", -- tall
	-- "Fira Mono", -- cramped
	-- "SF Mono", -- '--' too close (almost ligature-ish)
	-- "Input Mono", -- why so short?
	"Source Code Pro",
}

-- config.freetype_load_flags = "MONOCHROME"
-- config.freetype_load_flags = "NO_HINTING" -- squashes fonts (makes them shorter)
-- config.freetype_load_target = "Mono" -- yikes

-- note: entire config is evaluated on window open (but not close), tab
-- open/close, but not on split

-- relying on xrdb dpi is unreliable, as ubuntu seems to ignore it
local cell_width = 0.9
local font_size

if not is_ubuntu then
	-- home, 4k
	font_size = 10.0 -- scp
	-- the main drawback is subpar non-ascii support (e.g. cyrillic), which is a slight problem at home
	-- table.insert(fonts, 1, "NanumGothicCoding")
	-- font_size = 12.0
	-- -- underline 'disappears' at larger sizes in wezterm (works ootb in ghostty, regardless of size)
	-- config.underline_position = -6
elseif get_output("xdpyinfo | grep -F 3840x1200") then -- note: xrandr is unacceptably slow
	-- dual 2k
	table.insert(fonts, 1, "NanumGothicCoding")
	font_size = 13.0
elseif get_output("xdpyinfo | grep -F x1200") then
	-- single 2k
	table.insert(fonts, 1, "NanumGothicCoding")
	font_size = 16.0
elseif get_output("xdpyinfo | grep -F 1920x1080") then
	-- laptop-only (2k)
	font_size = 18.0
elseif get_output("xdpyinfo | grep -F 3840x3240") then
	table.insert(fonts, 1, "NanumGothicCoding")
	font_size = 24.0
else
	-- home, 4k only
	font_size = 18.0
end

-- note: source han sans is implicitly used as fallback for cn/jp/kr (which is
-- why scp goes great with it). scp also has cyrillic
local main_font = wezterm.font_with_fallback(fonts)

config.cell_width = cell_width > 0 and cell_width or 0.9 -- negative values will kill wezterm
config.command_palette_font_size = font_size
config.font = main_font
config.font_size = font_size
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.warn_about_missing_glyphs = false
config.window_frame = { font = main_font, font_size = font_size }

-- config.font_rules = {
-- 	{
-- 		italic = true, -- this has the unintended effect of disabling italics entirely
-- 		font = main_font,
-- 	},
-- }

-- }}}
-- appearance {{{

-- config.default_cursor_style = "SteadyBlock"
-- config.window_background_opacity = 0.8 -- see opacity-rule in picom.conf
config.color_scheme = "citruszest"
config.enable_scroll_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 999
config.text_background_opacity = 0.8 -- dim slightly
config.use_fancy_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function get_title(tab)
	local pane = tab.active_pane
	local title = assert(pane.title) -- may be ""
	-- local dir = assert(pane.current_working_dir.path)
	local dir = pane.current_working_dir and pane.current_working_dir.path or ""
	local proc = basename(assert(pane.foreground_process_name))

	local function get_bash_dir()
		return dir == os.getenv("HOME") and "~" or "> " .. basename(dir)
	end

	-- return table.concat({
	-- 	proc,
	-- 	basename(title),
	-- 	basename(dir),
	-- }, " ")

	-- os.execute("notify-send " .. proc)
	-- os.execute(string.format("notify-send '%s'", title))

	if proc == "" and dir == "" then -- mpv?
		-- os.execute(string.format("notify-send '%s'", dir))
		return "unknown"
	elseif proc == "bash" then
		return get_bash_dir()
	elseif proc == "ssh" then
		return string.match(title, "@[^:]+") or proc
	elseif
		proc == "nvim" --
		or title:sub(1, 2) == "x0"
	then
		-- this is the only situation where we ever check the title. when nvim is
		-- started from yazi (i.e. yazi -> nvim), proc still remains yazi, which
		-- makes sense, because yazi does not (and should not) exec.
		--
		-- if only proc is checked, it would be impossible to react to yazi -> nvim
		-- and nvim -> yazi. to work around this, we force nvim to set a reserved
		-- title on startup (which is caught in this condition), and another title
		-- on exit (which is caught in the next condition).

		return "f: " .. basename(title):gsub("^x0", ""):sub(1, 20)
	elseif
		proc == "yazi" --
		or title == "___"
	then
		-- note: nvim -> bash tends to end up here. this is probably because nvim
		-- sets exit title faster than pane.foreground_process_name can update.
		-- pressing super should set the title correctly (but not for
		-- nvim->bash->mpv, for example)

		-- os.execute(string.format("notify-send '%s'", proc))

		-- return basename(dir)

		return string.format("d: %s", basename(dir))
	else
		-- os.execute("notify-send unreachable!")
		error("unreachable")
	end

	--
end

wezterm.on("format-window-title", function(tab, pane, tabs, panes, cfg)
	local title = get_title(tab) -- only applies to wezterm windows

	local dir = pane.current_working_dir and pane.current_working_dir.path or ""

	-- attaching branch info to tab title is silly, because it uses a lot of space

	-- yazi always executes commands from ~
	local branch = get_output(string.format("git -C %s branch --show-current", dir)):gsub("\n", "")
	if branch == "" then
		return title
	else
		-- return string.format("[%s] %s", branch, title)
		return string.format("%s [%s]", title, branch)
	end
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local t = string.format(" %s %s ", tostring(tab.tab_index + 1), get_title(tab))
	-- if tab.active_pane.has_unseen_output then
	-- 	t = "! " .. t
	-- end
	return t
end)

-- }}}
-- keys {{{

local function file_exists(fname)
	-- https://stackoverflow.com/a/4991602
	local f = io.open(fname, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local function keys()
	local leader = "SHIFT|CTRL"

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

				-- -- first determine if ff has xcb problem
				-- if is_ubuntu and not file_exists("/var/lib/snapd/lib/gl/libxcb.so.1") then
				-- 	os.execute("notify-send 'xcb broken!'")
				-- 	return
				-- end

				-- log("opening: " .. url)
				-- if string.find(url, "youtu") then
				-- 	wezterm.open_with(url, "mpv")
				-- 	return
				-- end
				-- xdg-open on ubuntu wrongly chooses chromium, might as well be explicit
				wezterm.open_with(url, "firefox")
			end),
		},
	}

	-- like hint_url but open in nvim/less
	local hint_file = {
		QuickSelectArgs = {
			patterns = { [[\.?/[^ ]+]] }, -- there is proably a better regex
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				window:perform_action(act.SpawnCommandInNewTab({ args = { "less", "-R", url } }), pane)
			end),
		},
	}

	-- spawn new tab adjacent to current one, with same cwd
	local function SpawnTabNext()
		-- https://old.reddit.com/r/wezterm/comments/1d71ei3/_/l759axf/
		---@return number?
		local function active_tab_index(window)
			for _, item in ipairs(window:mux_window():tabs_with_info()) do
				if item.is_active then
					return item.index
				end
			end
		end

		return wezterm.action_callback(function(window, pane)
			local idx = active_tab_index(window) -- important: determine where to position tab -before- spawning new tab
			window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
			window:perform_action(act.MoveTab(idx + 1), pane)
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
		-- note: ctrl-shift-i = tab
		-- { mods = "CTRL", key = "e", action = act.SpawnWindow },
		-- { mods = "CTRL", key = "r", action = act.PromptInputLine(rename_tab) },
		{ mods = "CTRL", key = "PageDown", action = act.DisableDefaultAssignment },
		{ mods = "CTRL", key = "PageUp", action = act.DisableDefaultAssignment },
		{ mods = "CTRL", key = "Tab", action = act.DisableDefaultAssignment },
		{ mods = "CTRL", key = "g", action = act(hint_url) },
		-- { mods = "CTRL", key = "t", action = SpawnTabNext() },
		-- { mods = "CTRL", key = "z", action = act.ClearScrollback("ScrollbackAndViewport") }, -- note: ctrl-l is bound to readline's forward-word
		{ mods = "WIN", key = "f", action = act.DisableDefaultAssignment },

		-- { mods = leader, key = "g", action = act(hint_file) },
		-- { mods = leader, key = "o", action = act.MoveTabRelative(1) }, -- moving tabs is probably an antipattern
		-- { mods = leader, key = "p", action = act.ActivateCommandPalette },
		-- { mods = leader, key = "w", action = act.EmitEvent("watch") }, -- moved to vim
		-- { mods = leader, key = "x", action = act.EmitEvent("view-history-in-pager") },
		-- { mods = leader, key = "y", action = act.MoveTabRelative(-1) }, -- u reserved -- org.freedesktop.ibus.panel.emoji unicode-hotkey ['<Control><Shift>u']
		{ mods = leader, key = "h", action = act.ActivateTabRelative(-1) },
		{ mods = leader, key = "i", action = act.ShowTabNavigator },
		{ mods = leader, key = "j", action = act.ScrollByPage(1) },
		{ mods = leader, key = "k", action = act.ScrollByPage(-1) },
		{ mods = leader, key = "l", action = act.ActivateTabRelative(1) },
		{ mods = leader, key = "t", action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir }) }, -- TODO: also adjacent?
		{ mods = leader, key = "x", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	}

	-- local function get_active_pane(panes)
	-- 	for i, p in ipairs(panes) do
	-- 		-- log(i, p)
	-- 		if p.is_active then
	-- 			return i
	-- 		end
	-- 	end
	-- end

	return _keys
end

config.keys = keys()

-- }}}

return config
