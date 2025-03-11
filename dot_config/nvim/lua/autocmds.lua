-- vim.cmd("autocmd BufNewFile,BufRead *.h setlocal filetype=c")

vim.api.nvim_create_autocmd({ "InsertEnter" }, { command = "set nocursorline | norm zz" })
vim.api.nvim_create_autocmd({ "InsertLeave" }, { command = "set cursorline" })

-- restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		vim.cmd.norm([[g'"]]) -- :h '", :h last-position-jump
		vim.cmd.norm("zz")
	end,
})

-- highlight yanked text
-- local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	-- group = highlight_group,
	-- pattern = "*",
})

-- prevent cursor movement when yanking
-- https://github.com/neovim/neovim/issues/12374#issuecomment-2121867087
vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = { "n:no", "no:n" }, -- :h mode()
	callback = function(ev)
		if vim.v.operator ~= "y" then
			return
		end

		if ev.match == "n:no" then -- on y
			vim.b.user_yank_last_pos = vim.fn.getpos(".") -- store current pos in buffer variable
		elseif ev.match == "no:n" and vim.b.user_yank_last_pos then
			vim.fn.setpos(".", vim.b.user_yank_last_pos)
			vim.b.user_yank_last_pos = nil
		end
	end,
})

-- vim.api.nvim_create_autocmd("ModeChanged", {
-- 	pattern = { "V:n", "n:V", "v:n", "n:v" },
-- 	callback = function(ev)
-- 		local match = ev.match
-- 		if vim.tbl_contains({ "n:V", "n:v" }, match) then
-- 			-- vim.b.user_yank_last_pos = vim.fn.getpos(".")
-- 			vim.b.user_yank_last_pos = vim.api.nvim_win_get_cursor(0)
-- 		else
-- 			-- if vim.tbl_contains({ "V:n", "v:n" }, match) then
-- 			if vim.v.operator == "y" then
-- 				local last_pos = vim.b.user_yank_last_pos
-- 				if last_pos then
-- 					-- vim.fn.setpos(".", last_pos)
-- 					vim.api.nvim_win_set_cursor(0, last_pos)
-- 				end
-- 			end
-- 			vim.b.user_yank_last_pos = nil
-- 			-- end
-- 		end
-- 	end,
-- })

-- show line diagnostics on hover
-- TODO: disable the virtual line (since it's redundant and only shows the last diagnostic)
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = false,
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
	pattern = { "lua", "javascript", "typescript" },
	callback = function()
		-- defaults: false, 8, 0, 8

		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.tabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html" },
	callback = function()
		if not require("util"):buf_contains("htmx.org", 20) then
			return
		end

		if
			-- TODO: project node_modules might make more sense?
			not vim.loop.fs_stat(
				vim.fn.stdpath("data") .. "/mason/packages/markuplint/node_modules/@markuplint/htmx-parser"
			)
		then
			os.execute([[
				cd ~/.local/share/nvim/mason/packages/markuplint
				npm install -D @markuplint/htmx-parser
			]])
			print("installed htmx-parser")
		end

		if not vim.loop.fs_stat(".markuplintrc.json") then
			os.execute([[
				echo '{
					"extends": ["markuplint:recommended"],
					"parser": {"\\.html$": "@markuplint/htmx-parser"},
					"specs": {"\\.html$": "@markuplint/htmx-parser/spec"}
				}' > .markuplintrc.json
			]])
			print("generated .markuplintrc.json")
		end
	end,
})

-- see also https://github.com/BigAirJosh/nvim/blob/2e8dc08/lua/config/vim-dispatch.lua#L4
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.c", "*.cpp" },
	callback = function()
		if vim.loop.fs_stat("Makefile") then
			vim.cmd("Dispatch!")
		end

		-- technically, this should belong in plugin autocmds
		local t = require("conform").formatters_by_ft.cpp
		table.insert(t, "clang-tidy")
		require("conform").format({ async = true })
		table.remove(t, #require("conform").formatters_by_ft.cpp)
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

-- https://github.com/Virus288/Neovim-Config/blob/5cb7f321/lua/configs/lspConfig.lua#L95
-- WARN: this applies -all- code actions, even ones that are undesired (e.g.
-- export default), so this is almost always a bad idea
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	pattern = { "*.ts" },
-- 	callback = function()
-- 		vim.lsp.buf.code_action({
-- 			apply = true,
-- 			context = {
-- 				diagnostics = {},
-- 				only = { "refactor" },
-- 			},
-- 		})
-- 		vim.cmd("write")
-- 	end,
-- })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c" },
	callback = function()
		-- vim.cmd([[badd %<.c]]) -- adds buffer, but clangd cannot access it

		vim.keymap.set("n", "<c-c>", function()
			local c = string.find(vim.fn.expand("%"), "%.c$")
			local other = vim.fn.expand("%<") .. (c and ".h" or ".c")
			if vim.loop.fs_stat(other) then
				vim.cmd("tab drop " .. other)
				vim.cmd.norm("zz")
			end

			-- -- vim.cmd([[e %<.c]]) -- no syntax hl, and tends to race with gitsigns
			-- vim.cmd([[tabe %<.c]])
			-- -- vim.cmd("ClangdSwitchSourceHeader") -- like e, but without race
			-- -- vim.cmd.e("#") -- enable syntax hl (somehow)
		end, { buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sql" },
	callback = function()
		if vim.fn.executable("sqruff") then
			return
		end

		-- may need nightly install https://github.com/quarylabs/sqruff?tab=readme-ov-file#for-other-platforms
		print("installing sqruff...")
		local cmd =
			[[curl -fsSL https://raw.githubusercontent.com/quarylabs/sqruff/main/install.sh | sed -r '/INSTALL_DIR/ s|/usr/local/bin|$HOME/.local/bin|; s/sudo mv/mv -v/' | bash -x]]
		os.execute(cmd)
	end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
	callback = function()
		local parent = vim.fn.expand("%:p:h")
		if vim.loop.fs_stat(parent) then
			return
		end

		local prompt = string.format("Directory %s does not exist. Create? ", parent)
		vim.ui.input({ prompt = prompt }, function(choice)
			if choice == "y" then
				os.execute("mkdir -p " .. vim.fn.shellescape(parent))
			end
		end)
	end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	command = "Lazy clean",
	-- callback = function()
	-- 	vim.cmd("Lazy clean")
	-- 	os.execute("notify-send bye")
	-- end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	pattern = { "*.tex" },
	callback = function()
		os.execute("pkill zathura")
	end,
})
