-- vim.cmd("autocmd BufNewFile,BufRead *.h setlocal filetype=c")

vim.api.nvim_create_autocmd({ "InsertEnter" }, { command = "set nocursorline | norm zz" })
vim.api.nvim_create_autocmd({ "InsertLeave" }, { command = "set cursorline" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.bo.filetype == "man" then
			return
		end
		vim.fn.chdir(vim.fs.root(0, ".git") or vim.fn.expand("%:p:h"))
	end,
})

-- restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local curr = vim.fn.line([['"]])
		if 1 < curr and curr <= vim.fn.line("$") then
			vim.cmd.norm([[g'"]]) -- :h '", :h last-position-jump
		end
		vim.cmd.norm("zz")
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
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
				"InsertCharPre",
				"InsertEnter",
				"WinLeave",
				-- "FocusLost",
			},
		})
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "cron" },
	command = [[exec "!crontab %"]],
})

local function md_to_pdf()
	local _in = vim.fn.expand("%") -- basename!
	local out = string.gsub(_in, "%.md", ".pdf")
	local compile = string.format(
		[[ lowdown -sTms %s | pdfroff -tik -Kutf8 -mspdf > %s 2>/dev/null ]], --
		vim.fn.shellescape(_in),
		vim.fn.shellescape(out)
	)
	vim.fn.jobstart(compile)
	if
		#io.popen(string.format(
			-- lsof tries to read nonsense dirs on ubuntu, and fails
			-- can't stat() overlay file system /var/lib/docker/overlay2/.../merged
			-- can't stat() nsfs file system /run/docker/netns/...
			"lsof '%s' 2>/dev/null || ps aux | grep zathura | grep '%s'", --
			out,
			out
		)):read("*a") == 0
	then
		vim.fn.jobstart(string.format("zathura %s >/dev/null 2>/dev/null", out))
	end
end

-- compile md -> pdf
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.md" },
	callback = md_to_pdf,
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
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
		table.remove(t) -- removes last element by default
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

-- FileType {{{

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "mail", "rst" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json" },
	callback = function()
		-- note: if the file is not jsonc, comments are a syntax error anyway, so
		-- this is not terribly useful
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
		-- note that these settings only affect how vim displays the text. the
		-- formatter still determines what text the file actually contains
		-- TODO: bash files may set their own values somehow, must be some plugin

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
		-- v0.25.5 is the last version that has an asset (lol)
		-- https://github.com/quarylabs/sqruff/issues/1369
		--sponge /dev/stdout |
		local sed =
			"/INSTALL_DIR/ s|/usr/local/bin|$HOME/.local/bin|; s/sudo mv/mv -v/; s|/latest||; s#\\| grep -o#| sponge /dev/stdout | grep -om1#"
		local cmd = string.format(
			[[curl -fsSL https://raw.githubusercontent.com/quarylabs/sqruff/main/install.sh | sed -r '%s' | bash -x]],
			sed
		)
		if os.execute(cmd) / 256 == 0 then
			print("installed sqruff")
		else
			print("error when installing sqruff")
		end
	end,
})

-- golangci-lint is picky about where it can be run; this is trivial to expand
-- to other langs if needed
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go" },
	callback = function()
		vim.fn.chdir(vim.fs.root(0, "go.mod"))
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex" },
	callback = function()
		-- could put chdir in tectonic_build, but this also disables vimtex
		vim.fn.chdir(vim.fs.root(0, "Tectonic.toml"))
	end,
})

-- }}}

vim.api.nvim_create_autocmd("TabClosed", {
	-- stop lsps that no longer have any bufs
	callback = function()
		-- print(vim.fn.expand("%")) -- invoked after the tab close, not before

		local special_fnames = {
			dot_bash_aliases = "sh",
		}

		local tab_fts = {}
		for _, buf_num in pairs(require("util"):get_tabs_loaded()) do
			local ft, _ = vim.filetype.match({ buf = buf_num }) -- TODO: match may fail

			-- if ft is only known via modeline (and there is no shebang), match will
			-- -always- return nil; not even contents will work!
			ft = ft or special_fnames[vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf_num), ":t")]

			if ft then
				tab_fts[ft] = buf_num
			end
		end
		-- print(vim.inspect(tab_fts))

		for _, client in pairs(vim.lsp.get_clients()) do
			local lsp_fts = {}
			for _, ft in pairs(client.config.filetypes) do
				lsp_fts[ft] = true
			end

			if not require("util"):intersect(lsp_fts, tab_fts) then
				-- vim.lsp.buf_detach_client is hard to get right
				-- vim.lsp.buf_detach_client(0, client.id)
				vim.cmd(string.format("LspStop %s", client.id))
				print("closed", vim.inspect(client._log_prefix))
			end
		end
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
