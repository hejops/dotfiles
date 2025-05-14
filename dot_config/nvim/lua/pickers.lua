-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#guide-to-your-first-picker

local M = {}

local default_action = "select_tab_drop"

local slug = "sqlite"
local function open_devdocs(path)
	-- we just dump the string into a buffer, so we don't need to popen

	path = string.gsub(path, "#.+", "") -- strip #section, since it is useless in a text dump
	local url = string.format("https://documents.devdocs.io/%s/%s.html", slug, path)
	local cmd = string.format([[curl -sL "%s" | html2markdown | fold -s]], url)
	-- cmd = "echo 'https://devdocs.io/#q=" .. slug .. "+" .. path .. "'" .. cmd
	-- leaving aside the bizarre observation that # expands to %, the 'lang_'
	-- prefix must also be stripped. this is just too much work lol
	-- cmd = string.format([[echo https://devdocs.io/#q=%s+%s; ]], slug, path) .. cmd
	cmd = "vnew | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! " .. cmd
	vim.cmd(cmd)
	vim.cmd.norm("gg")
	vim.cmd.setlocal("ft=markdown")
end

function M:devdocs(opts) -- {{{
	-- require must be deferred!
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")

	opts = opts or {}

	local line = vim.api.nvim_get_current_line()
	local a, b = line:find("[A-Z ]+")
	if not a then
		print("No keywords in line")
		return
	end

	local keywords = line:sub(a, b):gsub("^%s*(.-)%s*$", "%1")
	local search_cmd = string.format(
		[[curl -sL 'https://documents.devdocs.io/sqlite/index.json' | jq -r '.entries[] | select(.name=="%s") | .path' | sort]],
		keywords
	)

	local f = assert(io.popen(search_cmd))
	local output = f:read("*all") -- read as a single line, with \n
	if output == "" then
		print("No results for", keywords)
		return
	end

	local results = {}
	for s in string.gmatch(output, "[^\n]+") do
		table.insert(results, s)
	end
	f:close()

	if #results == 1 then
		open_devdocs(results[1])
		return
	end

	pickers
		.new(opts, {
			prompt_title = slug,
			finder = finders.new_table({ results = results }),

			sorter = conf.generic_sorter(opts),

			attach_mappings = function(prompt_bufnr, _)
				actions[default_action]:replace(function()
					actions.close(prompt_bufnr)
					open_devdocs(action_state.get_selected_entry()[1])
				end)
				return true
			end,
		})
		:find()
end -- }}}

---@param thread string
local function show_mail(thread)
	-- note: text/plain is always preferred, but not all emails have it. this
	-- assumes that plain part is always listed before html

	return require("util"):get_command_output(string.format(
		[[
set -euo pipefail
thread=%s

if
	part=$(notmuch show --limit=1 thread:"$thread" |
		grep -Px '\spart\{.+plain' |
		grep -Pom1 '\d+')
then
	notmuch show --limit=1 --part="$part" thread:"$thread" |
		fold |
		# sed -r 's/^[ 	]+//g; :a;N;$!ba; s/\n{2,}/\n\n/g'
		sed -r 's/^[ 	]+//g' |
		sed -r ':a;N;$!ba; s/\n{2,}/\n\n/g'
else
	part=$(notmuch show --limit=1 thread:"$thread" |
		grep -Px '\spart\{.+html' |
		grep -Pom1 '\d+')
	notmuch show --limit=1 --part="$part" thread:"$thread" |
		# TODO: firefox readability
		lynx -dump -nolist -stdin
fi

]],
		thread
	))
end

-- readonly
function M:mail(opts) -- {{{
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")

	opts = opts or {}

	local cmd = "notmuch search --format=json date:24h.. and tag:inbox | jq"
	local decoded = vim.json.decode(require("util"):get_command_output(cmd))

	local lines = {}
	for _, m in ipairs(decoded) do
		table.insert(lines, string.format("%s\t%s\t%s", m.thread, m.date_relative, m.subject))
	end

	pickers
		.new(opts, {
			prompt_title = slug,
			finder = finders.new_table({ results = lines }),

			sorter = conf.generic_sorter(opts),

			attach_mappings = function(prompt_bufnr, _)
				actions[default_action]:replace(function()
					actions.close(prompt_bufnr)

					local thread = action_state.get_selected_entry()[1]:match("^%w+")
					print(show_mail(thread))
					require("util"):get_command_output(string.format("notmuch tag -unread -- thread:%s", thread))
				end)
				return true
			end,
		})
		:find()
end -- }}}

-- vim.keymap.set("n", "<leader>H", devdocs)
vim.keymap.set("n", "<leader>m", M.mail)

return M
