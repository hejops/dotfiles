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

return M

-- vim.keymap.set("n", "<leader>H", devdocs)
