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

function M:buf_contains(target)
	for _, l in pairs(vim.api.nvim_buf_get_lines(0, 0, 10, false)) do
		if string.find(l, target) ~= nil then
			return true
		end
		return false
	end
end

function M:in_git_repo()
	-- https://www.reddit.com/r/neovim/comments/y2t9rt/comment/is4wjmb/
	-- https://www.reddit.com/r/neovim/comments/vkckjb/comment/idosy7m/
	-- maybe use this cond to lazy-start gitsigns
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
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

function M:get_bufs_loaded()
	-- return list of (open) buffer paths that are git tracked
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

-- get_bufs_loaded()

function M:random_colorscheme()
	-- {{{
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
end

-- M:random_colorscheme() -- don't assume colorschemes are loaded yet


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
	if #io.popen("lsof " .. out):read("*a") == 0 then
		os.execute(string.format("zathura %s >/dev/null 2>/dev/null &", out))
	end
end

return M
