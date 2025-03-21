-- https://github.com/Feqzz/mpv-lastfm-scrobbler/blob/master/lastfm.lua
-- requires hauzer/scrobbler
local msg = require("mp.msg")
require("mp.options")
local prev_song_args = ""
local options = { username = "hejops" }
local accepted_file_formats = { "flac", "mp3", "m4a", "opus" }
-- m4as don't actually get scrobbled; might be due to different way of reading metadata
-- read_options(options, 'lastfm')

-- resume_all() is deprecated as of 2022-11-12
-- there is no replacement to this
-- https://github.com/mpv-player/mpv/blob/2f747341f99d9f8697303be01c67ae3b3437cd18/RELEASE_NOTES#L51
-- https://github.com/mpv-player/mpv/commit/dfcd561ba9087c2a62cb7034c5e661d0b57ad660

function contains(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function mkmetatable()
	local m = {}
	-- doesn't work for opus, i guess?
	-- https://github.com/mpv-player/mpv/blob/4f129a3eca7f8e1d6e3407c0689cbe313debf301/DOCS/man/input.rst#property-list
	-- for  mp.get_property("metadata") - 1 do
	-- 	local p = "metadata/list/" .. i .. "/" -- .. = string concat
	-- end
	for i = 0, mp.get_property("metadata/list/count") - 1 do
		local p = "metadata/list/" .. i .. "/" -- .. = string concat
		m[mp.get_property(p .. "key")] = mp.get_property(p .. "value")
	end
	return m
end

function esc(s)
	return string.gsub(s, "'", "'\\''")
end

function scrobble()
	-- mp.resume_all()
	if artist and title then
		args = string.format(
			"scrobbler scrobble --album='%s' --duration=%ds -- %s '%s' '%s' now > /dev/null",
			esc(album),
			length,
			esc(options.username),
			esc(artist),
			esc(title)
		)
		prev_song_args = args
	end
end

function enqueue()
	-- mp.resume_all()
	if options.username == "" then
		msg.info(string.format("Could not find a username! Please follow the steps in the README.md"))
		return
	end
	if not (artist and title) then
		return
	end
	args = string.format(
		"scrobbler now-playing %s '%s' '%s' -a '%s' -d %ds > /dev/null",
		esc(options.username),
		esc(artist),
		esc(title),
		esc(album),
		length
	)
	msg.verbose(args)
	os.execute(args .. " 2>/dev/null")
	if tim then
		tim.kill(tim)
	end
	timeout = length and length / 2 or 240
	tim = mp.add_timeout(timeout, scrobble)
end

function new_track()
	-- os.execute(string.format("echo '%s' >> /tmp/mpvscrobble.log", mp.get_property("metadata")))
	-- for k, v in pairs(mp.get_property_native("metadata")) do
	-- 	os.execute(string.format("echo '%s:%s' >> /tmp/mpvscrobble.log", k, v))
	-- end

	if mp.get_property("metadata/list/count") then
		local m = mkmetatable()
		local icy = m["icy-title"]
		if icy then
			-- TODO: better magic
			artist, title = string.gmatch(icy, "(.+) %- (.+)")()
			album = nil
			length = nil
		else
			length = mp.get_property("duration")
			-- last.fm doesn't allow scrobbling short tracks
			if length and tonumber(length) < 30 then
				return
			end

			local function get_nth_line(s, n)
				local i = 1
				for l in s:gmatch("[^\r\n]+") do
					if i == n then
						return l
					end
					i = i + 1
				end
			end

			-- mp.osd_message(
			-- 	get_nth_line(mp.get_property_native("metadata")["ytdl_description"]),
			-- 	-- mp.get_property_native("metadata")["ytdl_description"]:gmatch("[^\r\n]+"), --[3],
			-- 	10000
			-- )

			title = m["title"] or m["TITLE"] or mp.get_property("media-title")
			album = m["album"]
				or m["ALBUM"]
				or get_nth_line(mp.get_property_native("metadata")["ytdl_description"], 3)
				or ""
			artist = m["artist"]
				or m["ARTIST"]
				or string.gsub(mp.get_property_native("metadata")["uploader"], " %- Topic", "")
		end
		enqueue()
	end
end

function on_close()
	if not prev_song_args or prev_song_args ~= "" then
		msg.verbose(prev_song_args)
		os.execute(prev_song_args .. " 2>/dev/null")
		prev_song_args = ""
	end
end

function on_file_loaded()
	file_format = mp.get_property("file-format")
	path = mp.get_property("path")

	if path:find("music.youtube.com") ~= nil then
		print(path)
		new_track()
		return
	end

	if
		-- ignore non mp3s
		not contains(accepted_file_formats, file_format)
		-- ignore files from http (i.e. podcasts)
		or path:find("http", 1, true) == 1
	then
		return
	end

	new_track()
end

mp.register_event("end-file", on_close)
mp.register_event("file-loaded", on_file_loaded)
