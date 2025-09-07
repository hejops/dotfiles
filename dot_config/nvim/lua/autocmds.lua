-- vim.cmd("autocmd BufNewFile,BufRead *.h setlocal filetype=c")

vim.api.nvim_create_autocmd({ "InsertEnter" }, { command = "set nocursorline | norm zz" })
vim.api.nvim_create_autocmd({ "InsertLeave" }, { command = "set cursorline" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.bo.filetype == "man" then
			return
		end
		local root_files = {
			go = "go.mod",
			tex = "Tectonic.toml",
		}
		vim.fn.chdir(vim.fs.root(0, root_files[vim.bo.filetype] or ".git") or vim.fn.expand("%:p:h"))
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

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = vim.fn.expand("~") .. "/.ssh/config",
	callback = function()
		os.execute([[sed -r -i 's/^[ \t]*/\t/g; s/^\t(Host .+)?$/\1/' ]] .. vim.fn.expand("%"))
		vim.cmd("e")
	end,
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
			-- else
			-- vim.wo.colorcolumn = ""
		end
	end,
})

-- see also https://github.com/BigAirJosh/nvim/blob/2e8dc08/lua/config/vim-dispatch.lua#L4
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.c", "*.cpp" },
	callback = function()
		if vim.uv.fs_stat("Makefile") then
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
		if vim.uv.fs_stat(parent) then
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

vim.api.nvim_create_autocmd("TermOpen", { command = "startinsert" })

vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if vim.api.nvim_buf_get_name(0):match("^term") then
			vim.cmd("startinsert")
		end
	end,
})

-- FileType {{{

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "mail" },
	callback = function()
		if require("util"):buf_contains("@[^.]+%.de", 2) then
			vim.o.spelllang = "en,de" -- no opt_local?
		end

		-- very iffy; i want abbrev to expand immediately after i type the last
		-- char of lhs, but the actual behaviour requires lhs+space or lhs+esc.
		-- furthermore, autocomplete messes with abbrev expansion
		vim.cmd(string.format("iabbrev %s %s", "bg", "Beste Grüße,<cr>"))
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "mail", "rst" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua" },
	callback = function()
		-- defaults: false, 8, 0, 8
		-- note that these settings only affect how vim displays the text. the
		-- formatter still determines what text the file actually
		-- contains; in the case of lua, this is still usually tabs

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
			not vim.uv.fs_stat(
				vim.fn.stdpath("data") .. "/mason/packages/markuplint/node_modules/@markuplint/htmx-parser"
			)
		then
			os.execute([[
				cd ~/.local/share/nvim/mason/packages/markuplint
				npm install -D @markuplint/htmx-parser
			]])
			print("installed htmx-parser")
		end

		if not vim.uv.fs_stat(".markuplintrc.json") then
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
			if vim.uv.fs_stat(other) then
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

		-- TODO: sqruff-bin now on aur

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "proto" },
	callback = function()
		if not vim.uv.fs_stat(vim.env.HOME .. "/.local/share/nvim/mason/bin/protols") then
			os.execute("rustup default nightly")
		end
	end,
})

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "sh", "bash" },
-- 	callback = function()
-- 		-- -- https://utcc.utoronto.ca/~cks/space/blog/programming/BashGoodSetEReports
-- 		-- [[
-- 		--   #!/usr/bin/env bash
-- 		-- set -euo pipefail
-- 		-- trap 'echo \`"$BASH_COMMAND"\` exited with $? \(line $LINENO\)' ERR
-- 		-- ]]
-- 	end,
-- })

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "sh", "bash" },
-- 	command = [[%g/\v^[^#].+\{\n\n/norm jdd]],
-- })

-- }}}

vim.api.nvim_create_autocmd("TabClosed", {
	-- stop lsps that no longer have any bufs. note that this is called after the
	-- tab is closed (duh)
	callback = function()
		-- print(vim.fn.expand("%")) -- invoked after the tab close, not before

		local special_fnames = {
			dot_bash_aliases = "sh",
		}

		---@type {[string]: number}
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

		-- TODO: we assume that the closed tab is the current one, but we have no
		-- way to tell whether it is a different one (e.g. via tabonly)

		for _, client in pairs(vim.lsp.get_clients()) do
			local lsp_fts = {}
			for _, ft in pairs(client.config.filetypes) do -- TODO: ignore lua_ls err
				lsp_fts[ft] = true
			end

			if not require("util"):intersect(lsp_fts, tab_fts) then
				-- vim.lsp.buf_detach_client is hard to get right (because the buf num
				-- must also be specified)
				-- vim.lsp.buf_detach_client(0, client.id)
				if not client:is_stopped() then
					-- vim.cmd(string.format("LspStop %s", client.id))
					client:stop()
					-- x = client.get_language_id
					print("closed", client._log_prefix)
				end
				-- TODO: clear/reset diagnostics
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
