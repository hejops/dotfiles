M = {}

-- "The colon syntax is used for defining methods, that is, functions that have
-- an implicit extra parameter self"
-- https://www.lua.org/manual/5.1/manual.html#2.5.9
--
-- this means that methods declared with : must be called with :
--
-- function M.bar -> require('foo').bar(baz) = bar(baz)
-- function M:bar -> require('foo'):bar(baz) = bar(self, baz) = self:bar(baz)
-- function M:bar -> require('foo').bar(baz) = bar(baz) = baz:bar()

-- https://luals.github.io/wiki/annotations

-- vim.tbl_keys is non-deterministic
function M:keys(t)
	local _keys = {}
	for k, _ in pairs(t) do
		table.insert(_keys, k)
	end
	return _keys
end

-- buffers {{{

function M:get_bufnr(fname)
	-- nvim_list_bufs implicitly includes bufs that are not actually loaded!
	-- (:buffers) how though? seems interesting
	for _, bn in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bn) and vim.api.nvim_buf_get_name(bn) == fname then
			return bn
		end
	end
	return nil
end

-- only first 10 lines of buffer are checked
function M:buf_contains(target, lines)
	for _, l in pairs(vim.api.nvim_buf_get_lines(0, 0, lines or 10, false)) do
		if string.find(l, target) ~= nil then
			return true
		end
	end
	return false
end

function M:get_bufs_loaded() -- return list of (open) buffer paths
	-- TODO: ...that are git tracked
	-- Git commit <paths>
	local bufs_loaded = {}

	for _, buf_num in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf_num) then
			local buf_name = vim.api.nvim_buf_get_name(buf_num)
			if buf_name ~= "" then
				-- TODO: check if git tracked
				-- git ls-files --error-unmatch
				-- print(buf_num, buf_name)
				table.insert(bufs_loaded, buf_name)
			end
		end
	end

	-- print(bufs_loaded)

	return bufs_loaded
end

function M:buf_loaded(fname)
	for _, buf_num in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf_num) and vim.api.nvim_buf_get_name(buf_num):find(fname) ~= nil then
			return true
		end
	end
	return false
end

-- }}}

-- ui {{{

function M:resize_2_splits()
	-- maximise required, else 50/50 split
	vim.cmd("resize " .. vim.o.lines) -- max height (no default)
	vim.cmd("vertical resize " .. vim.o.columns) -- max width

	local height = vim.o.lines
	local width = vim.o.columns

	local wide = vim.o.columns > 150
	if wide then
		vim.cmd("vertical resize -" .. math.floor(width * 0.33))
	else
		vim.cmd("resize -" .. math.floor(height * 0.2))
	end
end

function M:get_layout_strategy()
	-- "vertical" is recommended if file previews are important, e.g. git
	-- diff, symbol search, or if window is narrow
	--
	-- "center" is recommended if previews are unimportant (or
	-- irrelevant)
	--
	-- for everything else, "horizontal" is a good fallback. having said
	-- that, thinking about layouts is cognitive load and should be
	-- avoided
	if vim.o.lines > 60 or vim.o.columns < 100 then
		return "vertical"
	else
		return "horizontal"
	end
end

function M:open_split(file)
	if not M:buf_loaded(vim.fs.basename(file)) then
		local h = vim.o.lines * 0.2
		local cmd = h .. " new " .. file
		vim.cmd(cmd)
		vim.cmd.wincmd("k")
	end
end

function M:close_unnamed_splits()
	for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(bufnr) == "" then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end
end

function M:open_float(lines)
	-- https://github.com/neovim/neovim/blob/51ccd12b3db/runtime/lua/vim/lsp/buf.lua#L133
	vim.lsp.util.open_floating_preview(lines, "text")
end

-- vim.keymap.set("n", "<leader>X", , { silent = true })

function M:random_colorscheme() -- {{{
	-- sliced and diced from tssm/nvim-random-colors

	-- ~/.local/share/nvim/lazy/*/colors/*.(lua|vim)

	local function map(f, xs)
		local result = {}
		for _, x in ipairs(xs) do
			local mapped = f(x)
			local function _0_()
				if 0 == select("#", mapped) then
					return nil
				else
					return mapped
				end
			end
			table.insert(result, _0_())
		end
		return result
	end

	local function concat(...)
		local function map2(f, xs)
			for _, x in ipairs(xs) do
				f(x)
			end
		end
		local result = {}
		local function append(xs)
			for _, x in ipairs(xs) do
				table.insert(result, x)
			end
		end
		map2(append, { ... })
		return result
	end

	local root = "~/.local/share/nvim/lazy/" -- globpath expands ~, apparently?
	local glob = "*/colors/*.%s"

	local paths = concat(
		vim.fn.globpath(root, string.format(glob, "lua"), false, true),
		vim.fn.globpath(root, string.format(glob, "vim"), false, true)
	)

	local function scheme_name(path)
		return vim.fn.fnamemodify(path, ":t:r") -- :t tail (basename), :r root (strip extension)
	end

	local all_schemes = map(scheme_name, paths)
	local scheme = all_schemes[math.random(#all_schemes)]

	vim.cmd.colorscheme(scheme)
end -- }}}

-- }}}

-- i/o {{{

-- commands should not contain pipe, because exit code will always be 2 (use
-- get_command_output and check for non-empty output instead)
function M:command_ok(cmd)
	assert(cmd)
	-- https://stackoverflow.com/a/23827063
	return os.execute(cmd) / 256 == 0
end

M.is_ubuntu = M:command_ok("grep -q Ubuntu /etc/*-release")

---@return string
function M:get_command_output(cmd, strip_newline)
	assert(cmd)
	---@type string
	local out, _ = assert(io.popen(cmd)):read("*all")
	if strip_newline then
		out = out:gsub("\n", "")
	end
	return out
end

function M:in_git_repo()
	-- https://www.reddit.com/r/neovim/comments/y2t9rt/comment/is4wjmb/
	-- https://www.reddit.com/r/neovim/comments/vkckjb/comment/idosy7m/
	-- maybe use this cond to lazy-start gitsigns
	return M:command_ok("git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null")
end

-- attempt to get git repo root, ignoring all possible child directories
---@return string|nil
function M:root_directory()
	local cmd = "git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " rev-parse --show-toplevel"
	local toplevel = vim.fn.system(cmd)
	if not toplevel or #toplevel == 0 or toplevel:match("fatal") then
		-- return vim.fn.getcwd()
		return nil
	end
	return toplevel:sub(0, -2)
end

-- }}}

-- markdown {{{

function M:md_to_pdf()
	local _in = vim.fn.shellescape(vim.fn.expand("%")) -- basename!
	if string.find(_in, "chapter_") ~= nil then -- don't compile mdbook
		return
	end
	local out = string.gsub(_in, "%.md", ".pdf")
	local compile = string.format(
		--
		[[ lowdown -sTms %s | pdfroff -tik -Kutf8 -mspdf > %s 2>/dev/null ]],
		_in,
		out
	)
	os.execute(compile)
	if require("util"):command_ok("lsof " .. out) then
		os.execute(string.format("zathura %s >/dev/null 2>/dev/null &", out))
	end
end

-- }}}

function M:sql_dialect()
	local default = "sqlite"
	local allowed = { "sqlite", "postgres", "clickhouse" }
	local lines = vim.api.nvim_buf_get_lines(0, 0, 5, false)

	-- calling nvim_buf_get_lines too early leads to empty table
	if #lines == 0 then
		return default
	end

	local pat = "-- *dialect:([a-z]+)"

	for _, line in pairs(lines) do
		if line:find(pat) then
			local dialect = line:match(pat)
			if not vim.tbl_contains(allowed, dialect) then
				error(string.format("Invalid dialect: '%s'. Dialect must be one of %s", dialect, vim.inspect(allowed)))
			end
			return dialect
		end
	end
	return default
end

local function pg_connection_ok(conn)
	-- pipe to cat to avoid pager
	return conn and M:command_ok(string.format([[psql %s -c '\dt' 2>/dev/null | cat >/dev/null]], conn))
end

---@return { name: string, type: string, url: string }[]
function M:dbee_connections()
	-- TODO: connect to db specified in config.yml?

	local connections = {}

	local f = vim.env.HOME .. "/gripts/disq/collection2.db"
	if vim.loop.fs_stat(f) then
		table.insert(connections, { name = "foo", type = "sqlite", url = f })
	end

	local rental = "postgres://postgres:postgres@localhost:5432/dvdrental?sslmode=disable"
	if pg_connection_ok(rental) then
		table.insert(connections, { name = "neon", type = "postgres", url = rental })
	end

	if pg_connection_ok(vim.env.POSTGRES_URL) then
		table.insert(connections, { name = "work", type = "postgres", url = vim.env.POSTGRES_URL })
	end

	return connections
end

return M
