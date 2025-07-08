-- launch searches from within mpv
--
-- actions: copy link to clipboard (only if url) / copy metadata to clipboard /
-- dump metadata to file / search (menu)
--
-- flow: keybind (e.g. '?') -> show metadata + options -> navigate up/down ->
-- enter -> xdg-open

-- https://mpv.io/manual/stable/#mp-functions
-- https://mpv.io/manual/stable/#list-of-input-commands

-- https://mpv.io/manual/stable/#list-of-events
-- mp.register_event("file-loaded", on_file_loaded)
-- mp.register_event("shutdown", on_file_loaded)

local mp = require("mp")
-- local assdraw = require("mp.assdraw")

SEARCH_ENGINES = {
	discogs = {
		url = "https://www.discogs.com/search/?type=all&q=",
		fields = { "artist", "album" },
	},
	spotify = {
		url = "https://open.spotify.com/search/",
		fields = { "artist", "title" },
	},
	youtube = {
		url = "https://music.youtube.com/search?q=",
		fields = { "artist", "title" },
	},
}

local function keys(tab)
	-- https://stackoverflow.com/a/12674376
	local _keys = {}
	local n = 0

	for k, _ in pairs(tab) do
		n = n + 1
		_keys[n] = k
	end

	table.sort(_keys)

	return _keys
end

local function sanitize(s)
	local replacements = {
		["[']"] = "",
		["[-]"] = " ",
	}
	for pat, repl in pairs(replacements) do
		s = string.gsub(s, pat, repl)
	end
	return s
end

-- urlencode https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99

-- Return table of metadata if playing a file, otherwise string (`media-title`)
local function get_metadata()
	-- {{{
	-- local props = {
	--
	-- 	-- https://mpv.io/manual/stable/#property-expansion
	-- 	-- https://mpv.io/manual/stable/#property-list
	--
	-- 	"filename/no-ext",
	-- 	"media-title", -- metadata/by-key/title
	-- 	"path",
	-- 	"time-pos", -- s.ms
	-- 	-- "filename",
	-- 	-- "playlist", -- table
	-- }
	--
	-- for _, prop in pairs(props) do
	-- 	print(prop .. ":" .. mp.get_property_native(prop))
	-- end

	-- TODO: if path contains /oar/out/, use filename/no-ext

	local path = mp.get_property_native("path")

	-- generalise metadata extraction, depending on file/url
	if string.find(path, "^http") == nil then
		return mp.get_property_native("metadata") -- table
	else
		return mp.get_property_native("media-title")
	end
end -- }}}

local function search_prompt()
	local function search(source, query, verbose)
		local search_url = SEARCH_ENGINES[source].url .. sanitize(query)
		local cmd = string.format("xdg-open '%s'", search_url)

		mp.osd_message(query, 2)

		if verbose then
			print(cmd)
		end

		-- see also: commandv run
		os.execute(cmd)
	end

	local input = require("mp.input")

	-- -- [search] get function: 0x74d846d57d08
	-- -- [search] log function: 0x74d846d52f28
	-- -- [search] log_error function: 0x74d846d52ef0
	-- -- [search] set_log function: 0x74d846d52c50
	-- -- [search] terminate function: 0x74d846d55a08
	-- for k, v in pairs(input) do
	-- 	print(k, v)
	-- end

	-- -- TODO: why is input.select missing??
	-- -- attempt to call field 'select' (a nil value)
	-- input.select({
	-- 	prompt = "Select: ",
	-- 	items = keys(SEARCH_URLS),
	-- 	default_item = 1,
	-- 	submit = function(idx)
	-- 		mp.commandv("print-text", SEARCH_URLS[idx])
	-- 	end,
	-- })

	local verbose = false

	-- works in both osd and console!
	input.get({
		prompt = string.format("Select [%s]:", table.concat(keys(SEARCH_ENGINES), " ")),

		-- opened = function()
		-- 	input.set_log(keys(SEARCH_ENGINES))
		-- end,

		-- submit = function(typed)
		edited = function(typed)
			for engine, _ in pairs(SEARCH_ENGINES) do
				if string.find(engine, "^" .. typed) ~= nil then
					local meta = get_metadata() -- {'artist': ..., ...}
					if type(meta) == "table" then
						local fields = SEARCH_ENGINES[engine].fields -- {'artist', ...'}

						local query = {}
						for _, field in pairs(fields) do
							table.insert(query, meta[field])
						end
						search(engine, table.concat(query, " "), verbose)
					else
						search(engine, meta, verbose)
					end

					break
				end
			end
			input.terminate()
		end,
	})
end

local function copy_link()
	local path = mp.get_property_native("path")
	local fname = mp.get_property_native("filename/no-ext")

	if string.find(path, "^http") ~= nil then
		local pos = mp.get_property_native("time-pos")
		local link = string.format("%s&t=%d", path, pos)
		local cmd = string.format("echo -n '%s' | xclip -selection clipboard", link)
		os.execute(cmd)
	elseif string.find(path, "testdir") ~= nil then
		-- lua escape is % (not \)
		-- https://www.lua.org/pil/20.2.html
		if string.find(fname, "watch%?v=") ~= nil then
			local idx = string.find(fname, "watch%?v=")
			local url = string.sub(fname, idx + 8)
			os.execute(string.format("echo '%s' >> /tmp/foo", url))
		else
			os.execute(string.format("echo '%s' >> /tmp/foo", sanitize(fname)))
		end
		mp.commandv("playlist-next")
	end

	-- mp.osd_message("Copied link", 2)
end

mp.add_key_binding("/", "menu", search_prompt)
mp.add_key_binding("y", "copy_link", copy_link)
