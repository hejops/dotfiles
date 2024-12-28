-- https://luabyexample.netlify.app/docs/nvim-autocmd/
-- https://github.com/rafi/vim-config/blob/801e4456b6c135e92f1bccecd740421a3738f339/lua/rafi/config/autocmds.lua#L38

vim.api.nvim_create_autocmd({ "InsertEnter" }, { command = "set nocursorline" })
vim.api.nvim_create_autocmd({ "InsertLeave" }, { command = "set cursorline" })

-- restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]],
})

vim.api.nvim_create_autocmd({ "InsertEnter" }, { command = "norm zz" })

-- highlight yanked text
-- local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	-- group = highlight_group,
	-- pattern = "*",
})

-- show line diagnostics on hover
-- TODO: disable the virtual line (since it's redundant and only shows the last diagnostic)
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = false, -- still doesn't prevent K from entering float
			source = "always",
			severity_sort = true,
			-- scope = "cursor",
			-- max_width = math.floor(vim.o.columns / 2),
			-- style = "minimal",
			-- border = "rounded",
			-- header = "",
			-- prefix = "",
			close_events = {

				"BufHidden",
				"BufLeave",
				"CursorMoved",
				"CursorMovedI",
				"FocusLost",
				"InsertCharPre",
				"InsertEnter",
				"WinLeave",
			},
		})
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "cron" },
	command = [[exec "!crontab %"]],
})

local function md_to_pdf()
	local _in = vim.fn.shellescape(vim.fn.expand("%")) -- basename!
	local out = string.gsub(_in, "%.md", ".pdf")
	local compile = string.format(
		--
		[[ lowdown -sTms %s | pdfroff -tik -Kutf8 -mspdf > %s 2>/dev/null ]],
		_in,
		out
	)
	vim.fn.jobstart(compile)
	-- TODO: if lsof err, return
	-- if #io.popen("lsof " .. out):read("*a") == 0 then
	-- 	vim.fn.jobstart(string.format("zathura %s >/dev/null 2>/dev/null", out))
	-- end
end

-- compile md -> pdf
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.md" },
	callback = md_to_pdf,
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
	-- group = vim.api.nvim_create_augroup("colorcolumn", { clear = true }),
	callback = function(event)
		local cc_filetypes = {
			-- default is 80
			python = "89",
			rust = "101",
		}
		local filetype = event.match
		if cc_filetypes[filetype] then
			vim.wo.colorcolumn = cc_filetypes[filetype]
		else
			-- vim.wo.colorcolumn = ""
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text,mail,rst" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json" },
	callback = function()
		vim.opt_local.commentstring = "// %s"
		-- if vim.fn.executable("jq") == 1 then
		-- vim.opt_local.formatprg = "jq ." -- doesn't prettier take care of formatting?
		-- end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	-- should i do this for go? hmm...
	pattern = { "lua" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.tabstop = 2
	end,
})

-- vim.api.nvim_create_autocmd({ "FileType" }, {
-- 	pattern = "mail",
-- 	callback = function()
-- 		local name = os.getenv("USER")
-- 		name = (name:gsub("^%l", string.upper))
-- 		vim.cmd(string.format("norm }oBest regards,\r%s\r", name))
-- 		vim.cmd("norm {o")
-- 		vim.cmd("norm O")
-- 		vim.cmd("norm O")
-- 		vim.cmd("norm ODear")
-- 		vim.cmd("startinsert!")
-- 	end,
-- })

-- https://github.com/artart222/CodeArt/blob/3a419066140bc094aa170ac456daa704aa2e88a7/lua/maps.lua#L28
-- https://github.com/kutsan/dotfiles/blob/a1a608768c61c7aadf1fb160166d59a0214f80a6/.config/nvim/plugin/autocmds.lua#L8
-- https://github.com/Bekaboo/nvim/blob/92d103ad117388c877b63d8940e2463656ce9ab1/lua/plugin/term.lua#L9
-- TODO: silence 'process exited with'
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.bo.bufhidden = "wipe"
		vim.cmd.startinsert()
	end,
})

-- -- disabled, because trying to override the default behaviour is usually incorrect
-- -- ensure 80/20 horizontal split
-- vim.api.nvim_create_autocmd({ "VimResized" }, {
-- 	callback = function()
-- 		local windows = vim.api.nvim_tabpage_list_wins(0)
-- 		if #windows == 1 then
-- 			return
-- 		end
--
-- 		-- fidget init is counted as a win when active, leading to unwanted resizes
-- 		-- when starting up rust and go workspaces
-- 		-- https://github.com/j-hui/fidget.nvim/blob/60404ba67044c6ab01894dd5bf77bd64ea5e09aa/lua/fidget/notification/window.lua#L306
-- 		-- TODO: other transient buffers may need to be caught
-- 		for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
-- 			-- if vim.api.nvim_buf_get_option(bufnr, "filetype") == "fidget" then
-- 			if vim.api.nvim_get_option_value("filetype", { buf = bufnr }) == "fidget" then
-- 				return
-- 			end
-- 		end
--
-- 		-- require("util"):resize_2_splits()
-- 		-- vim.cmd.redraw()
-- 		-- vim.cmd.norm("h")
-- 		-- vim.cmd.norm("l")
-- 	end,
-- })
