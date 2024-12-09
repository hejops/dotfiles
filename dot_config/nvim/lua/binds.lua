-- vim: ts=2 sts=2 sw=2 et
-- https://vim.fandom.com/wiki/Unused_keys
-- https://stackoverflow.com/a/3806664 -- mostly visual mode
-- https://vi.stackexchange.com/a/28080

vim.g.mapleader = " " -- must be declared before declaring lazy plugins (citation needed)
vim.g.maplocalleader = " "

-- essentials
vim.keymap.set("c", "<c-h>", "<s-left>")
vim.keymap.set("c", "<c-j>", "<down>") -- defaults do nothing
vim.keymap.set("c", "<c-k>", "<up>")
vim.keymap.set("c", "<c-l>", "<s-right>")
vim.keymap.set("c", "<c-o>", "<s-tab>")
vim.keymap.set("i", "<c-c>", "<esc>", { remap = true, silent = true }) -- <c-c> kills cursorline
vim.keymap.set("i", "<c-h>", "<s-left>")
vim.keymap.set("i", "<c-j>", "<c-o>$<c-j>")
vim.keymap.set("i", "<c-l>", "<s-right>")
vim.keymap.set("n", "!", ":!")
vim.keymap.set("n", "-", "~h") -- +/- are just j/k
vim.keymap.set("n", "/", [[/\v]]) -- always use verymagic
vim.keymap.set("n", "<c-c>", "<nop>")
vim.keymap.set("n", "<c-z>", "<nop>")
vim.keymap.set("n", "<tab>", "<nop>") -- tab may be equivalent to c-i
vim.keymap.set("n", "G", "G$zz") -- because of the InsertEnter zz autocmd
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "J", "mzJ`z") -- join without moving cursor
vim.keymap.set("n", "L", "g_")
vim.keymap.set("n", "Q", ":bd<cr>")
vim.keymap.set("n", "U", ":redo<cr>")
vim.keymap.set("n", "X", '"_X')
vim.keymap.set("n", "Y", "y$") -- default is redundant with yy
vim.keymap.set("n", "ZX", ":wqa<cr>")
vim.keymap.set("n", "co", "O<esc>jo<esc>k") -- surround current line with newlines
vim.keymap.set("n", "gD", "<nop>")
vim.keymap.set("n", "gf", "<c-W>gF") -- open file under cursor in new tab, jumping to line if possible; uncommonly used
vim.keymap.set("n", "gg", "gg0")
vim.keymap.set("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true }) -- use g[jk] smartly
vim.keymap.set("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })
vim.keymap.set("n", "s", '"_d')
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "~", "~h")
vim.keymap.set("v", "<", "<gv") -- vim puts you back in normal mode by default
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "P", '"_dP')
vim.keymap.set("v", "x", '"_x')

-- https://unix.stackexchange.com/a/356407
-- large motions, jumps
-- vim.keymap.set("n", "<leader>j", "<c-f>zz")
-- vim.keymap.set("n", "<leader>k", "<c-b>zz")
vim.keymap.set("n", "<c-b>", "<c-u>zz") -- <c-u/d> is more stable than <c-b/f>
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-f>", "<c-d>zz")
vim.keymap.set("n", "<c-i>", "<c-o>zz") -- jumplist; o = forward is more intuitive
vim.keymap.set("n", "<c-j>", "<c-d>zz")
vim.keymap.set("n", "<c-k>", "<c-u>zz")
vim.keymap.set("n", "<c-o>", "<c-i>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "N", ":keepjumps normal! N<cr>zzzv", { silent = true })
vim.keymap.set("n", "n", ":keepjumps normal! n<cr>zzzv", { silent = true })
vim.keymap.set("n", "{", ":keepjumps normal! {<cr>zz", { silent = true })
vim.keymap.set("n", "}", ":keepjumps normal! }<cr>zz", { silent = true })

-- TODO: close all other splits (not tabs)
-- default r behaviour is useless (cl)
-- nmap ZF zfaft{blDkp$%bli<cR><esc>ld0<cR>zl|	" add folds around a func, like a real man, in any language
-- tabs and folds; splits are only used for exec
-- vim.keymap.set("n", "rH", ":silent! tabm -1<cr>", { silent = true }) -- do i need this?
-- vim.keymap.set("n", "rL", ":silent! tabm +1<cr>", { silent = true })
-- vim.keymap.set("n", "re", ':silent! exe "tabn ".g:lasttab<cr>', { silent = true })
vim.keymap.set("n", "<c-h>", "gT")
vim.keymap.set("n", "<c-l>", "gt")
vim.keymap.set("n", "<c-m>", ':silent! exe "tabn ".g:lasttab<cr>', { silent = true })
vim.keymap.set("n", "<c-t>", "<c-6>", { silent = true })
vim.keymap.set("n", "r", "<nop>")
vim.keymap.set("n", "rd", ":%bd|e#<cr>zz") -- delete all other buffers/tabs -- https://dev.to/believer/close-all-open-vim-buffers-except-the-current-3f6i
vim.keymap.set("n", "rh", "gT")
vim.keymap.set("n", "ri", "<c-W>_") -- maximise current split height
vim.keymap.set("n", "rj", "<c-w><c-j>")
vim.keymap.set("n", "rk", "<c-w><c-k>")
vim.keymap.set("n", "rl", "gt")
vim.keymap.set("n", "rx", ":tabo<cr>") -- close all other buffers (but not delete)
vim.keymap.set("n", "zH", "zM")
vim.keymap.set("n", "zL", "zR")
vim.keymap.set("n", "zh", "zm") -- fold
vim.keymap.set("n", "zl", "zr") -- expand

-- https://stackoverflow.com/a/2439848
-- https://vim.fandom.com/wiki/Moving_lines_up_or_down
-- i very rarely use alt nowadays
vim.keymap.set("i", "<a-j>", "<esc>:m .+1<cr>==gi")
vim.keymap.set("i", "<a-k>", "<esc>:m .-2<cr>==gi")
vim.keymap.set("n", "<a-j>", ":m .+1<cr>==")
vim.keymap.set("n", "<a-k>", ":m .-2<cr>==")
vim.keymap.set("v", "<a-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<a-k>", ":m '<-2<cr>gv=gv")

-- commands
-- vim.keymap.set("n", "<c-s>", ":keepjumps normal! mz{j:<c-u>'{+1,'}-1sort<cr>`z", { silent = true })
vim.keymap.set("n", "<c-s>", "mz{j:<c-u>'{+1,'}-1sort<cr>`z", { silent = true }) -- vim's sort n is not at all like !sort -V
vim.keymap.set("n", "<f10>", ":colo<cr>")
vim.keymap.set("n", "<leader><tab>", ":set list!<cr>")
vim.keymap.set("n", "<leader>D", [[:g/\v/d<Left><Left>]])
vim.keymap.set("n", "<leader>T", ":tabe ")
vim.keymap.set("n", "<leader>U", ":exec 'undo' undotree()['seq_last']<cr>") -- remove all undos -- https://stackoverflow.com/a/47524696
vim.keymap.set("n", "<leader>X", ":call Build()<cr>")
vim.keymap.set("n", "<leader>n", [[:%g/\v/norm <Left><Left><Left><Left><Left><Left>]])
vim.keymap.set("n", "<leader>r", [[:%s/\v/g<Left><Left>]]) -- TODO: % -> g/PATT/
vim.keymap.set("v", "D", [[:g/\v/d<Left><Left>]]) -- delete lines
vim.keymap.set("v", "n", [[:g/\v/norm <Left><Left><Left><Left><Left><Left>]])
vim.keymap.set("v", "r", [[:s/\v/g<Left><Left>]])

-- context dependent binds
-- https://github.com/neovim/neovim/blob/012cfced9b5384fefa11d74346779b1725106d07/runtime/doc/lua-guide.txt#L450
-- local exec_or_close = [[&buftype == 'nofile' ? ':bd<cr>' : ':call Exec()<cr>']]
-- vim.keymap.set("n", "<leader>x", exec_or_close, { silent = true, expr = true })
local update_or_close = [[&buftype == 'nofile' ? ':bd<cr>' : ':update<cr>']] -- close window if scratch
local x_or_close = [[&modifiable == 0 ? ':bd<cr>' : '"_x']]
vim.keymap.set("n", "<c-c>", update_or_close, { silent = true, expr = true })
vim.keymap.set("n", "<cr>", update_or_close, { silent = true, expr = true })
vim.keymap.set("n", "<leader><space>", update_or_close, { silent = true, expr = true })
vim.keymap.set("n", "x", x_or_close, { silent = true, expr = true })

-- map <2-rightmouse> <nop>
-- map <3-rightmouse> <nop>
-- map <4-leftmouse> <nop>|	" vblock mode
-- map <4-rightmouse> <nop>
-- map <A-rightmouse> <c-f>zz|	" doesn't work
-- map <c-leftmouse> <nop>
-- mouse
-- nmap <rightmouse> <cr>
vim.keymap.set("i", "<rightmouse>", "<esc>")
vim.keymap.set("n", "<rightmouse>", "<nop>")

-- vim-fugitive; the only plugin allowed in this file, because of how critical it is
-- most of fugitive's interactive features are better done via telescope (e.g. git log, git status)
vim.keymap.set("n", "<leader>ga", ":Gwrite<cr>", { desc = "add current buffer" })
vim.keymap.set("n", "<leader>gp", ":Dispatch! git push<cr>", { desc = "git push (async)" })

-- TODO: git add % + git commit --amend --no-edit

vim.keymap.set("n", "<leader>C", function()
	-- TODO: if no changes, do nothing
	vim.cmd("silent !pre-commit run --files %")
	vim.cmd("Git commit -q -v %") -- commit entire file
end, { desc = "commit current buffer" })

vim.keymap.set("n", "<leader>gc", function()
	vim.cmd("silent !pre-commit run") -- limit to staged files
	vim.cmd("Git commit -q -v") -- commit currently staged chunk(s)
end, { desc = "commit currently staged hunks" })

-- niche
vim.keymap.set("i", "<c-y>", "<esc>lyBgi") -- yank current word without moving, useful only for note taking
vim.keymap.set("n", "<leader>M", '"qp0dd') -- dump q buffer into a newline and cut it (for binding)
vim.keymap.set("n", "z/", "ZZ") -- lazy exit
vim.keymap.set("n", "<leader>y", [[:let @a=''<bar>g/\v/yank A<left><left><left><left><left><left><left>]]) -- yank lines containing
-- TODO: set mark and return to it (mz...z"ap)

local function toggle_diagnostics()
	-- only disables inlay hints; popups (and trouble) remain
	-- TODO: for python, only ruff should be toggled
	if vim.diagnostic.is_enabled() then
		vim.diagnostic.enable(false)
		vim.diagnostic.hide()
	else
		vim.diagnostic.enable(true)
		vim.diagnostic.show()
	end
end

local ft_binds = { -- {{{

	gitcommit = function()
		vim.keymap.set("n", "J", "}zz", { buffer = true })
		vim.keymap.set("n", "K", "{zz", { buffer = true })
	end,

	man = function()
		vim.keymap.set("n", "J", "<c-f>zz", { buffer = true })
		vim.keymap.set("n", "K", "<c-b>zz", { buffer = true })
	end,

	["qf,help,man,lspinfo,startuptime,Trouble,lazy"] = function()
		vim.keymap.set("n", "q", "ZZ", { buffer = true })
		vim.keymap.set("n", "x", "ZZ", { buffer = true })
		vim.keymap.set("n", "<esc>", "ZZ", { buffer = true })
	end,

	["sh,bash"] = function()
		vim.keymap.set("n", "<bar>", ":.s/ <bar> / <bar>\\r/g<cr>", { buffer = true })
	end,

	["typescript,javascript,typescriptreact,javascriptreact"] = function()
		-- replace != and ==; probably better via find+sed
		vim.keymap.set("n", "<leader>=", [[:%s/\v ([=!])\= / \1== /g|w<cr><c-o>]], { buffer = true })
		vim.keymap.set("n", "<leader>a", ":!npm install ", { buffer = true })
	end,

	rust = function()
		-- TODO: <c-l> to exit parens?

		-- vim.keymap.set("n", "<leader>A", "oassert_eq!();<esc>hi", { buffer = true })
		vim.keymap.set("i", "<c-j>", ";<cr>", { buffer = true })
		vim.keymap.set("n", "<leader>a", ":!cargo add ", { buffer = true })
	end,

	zig = function()
		vim.keymap.set("i", "<c-j>", ";<cr>", { buffer = true })
	end,

	-- TODO: also include gomod
	go = function()
		vim.keymap.set("n", "<leader>E", "oif err!=nil{panic(err)}<esc>:w<cr>o", { buffer = true }) -- https://youtube.com/watch?v=fIp-cWEHaCk&t=1437

		-- TODO: go get foo, and import foo
		-- https://github.com/ray-x/go.nvim/blob/cde0c7a110c0f65b9e4e6baf342654268efff371/lua/go/goget.lua#L23
		-- vim.keymap.set("n", "<leader>a", 'gg/import<cr>o"":!go get github.com/', { buffer = true })

		function GoGet(pkg)
			local url = "github.com/" .. pkg

			-- 1. go get github...
			vim.system(
				{ "go", "get", url },
				{},
				-- on_exit
				function(obj)
					if obj.code == 0 then
						print("ok: " .. pkg)
						os.execute("notify-send " .. pkg)
					else
						print(obj.signal)
						print(obj.stdout)
						print(obj.stderr)
					end
				end
			):wait()
			-- 2. add import statement (_ "github.com/..."), save
			-- 3. go mod tidy
		end

		vim.keymap.set("n", "<leader>a", ":lua GoGet''<left>", { buffer = true })
		vim.keymap.set("n", "<leader>t", function()
			vim.system({ "go", "mod", "tidy" })
			vim.cmd("LspRestart")
			vim.cmd("Trouble refresh")
		end, { buffer = true })

		-- switch to early return to reduce nesting, assumes return block is 1-line
		-- note: this does -not- invert the condition
		vim.keymap.set("n", "<leader>N", "$m`%dddj``p:w<cr>", { buffer = true })
	end,

	python = function()
		-- TODO: try_lint may stop working after a file is written?
		-- https://github.com/mfussenegger/nvim-lint/issues/553#issuecomment-2041042145
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.reset(nil, 0)
			require("lint").linters_by_ft = {
				python = #require("lint").linters_by_ft.python > 0 and {} or { "ruff" },
			}
			require("lint").try_lint()
		end)
	end,

	markdown = function()
		-- TODO: if checkbox item (`- [ ]`), toggle check
		-- https://github.com/tadmccorkle/markdown.nvim#lists

		local function mn()
			require("markdown.nav").next_heading()
			vim.cmd.norm("zz")
		end

		local function mp()
			require("markdown.nav").prev_heading()
			vim.cmd.norm("zz")
		end

		vim.keymap.set("n", "<leader>d", toggle_diagnostics)

		-- vim.keymap.set("n", "J", mn, { buffer = true, remap = true })
		-- vim.keymap.set("n", "K", mp, { buffer = true, remap = true }) -- TS hover
		-- vim.keymap.set("n", "gk", require("markdown.nav").prev_heading, { buffer = true, remap = true })
		vim.keymap.set("n", "<c-k>", "ysiw]Ea()<esc>Pgqq", { buffer = true, remap = true }) -- wrap in hyperlink
		vim.keymap.set("n", "<leader>s", require("telescope").extensions.heading.heading, { buffer = true })
		-- vim.keymap.set("n", "[[", mp, { buffer = true, remap = true })
		-- vim.keymap.set("n", "]]", mn, { buffer = true, remap = true })
	end,
}

for ft, callback in pairs(ft_binds) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = callback,
	})
end

-- }}}

-- run current file and dump stdout to scratch buffer
local function exec()
	-- {{{
	-- running tests is better left to the terminal itself (e.g. wezterm)
	if vim.bo.filetype == "nofile" then
		return
	end
	-- TODO: async (Dispatch)
	local front = "new | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! "
	local wide = vim.o.columns > 150
	if wide then -- vsplit if wide enough
		local w = math.floor(vim.o.columns * 0.33)
		front = w .. " v" .. front
	else
		local h = vim.o.lines * 0.2
		front = h .. front
	end

	local curr_file = vim.fn.shellescape(vim.fn.expand("%")) -- relative to cwd
	local cwd = vim.fn.getcwd()

	local function get_sql_cmd(file)
		local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)
		local db = string.gsub(first_line[1], "^-- ", "")
		-- TODO: check file exists

		-- litecli has nicer (tabular) output, but some ill-placed comments will
		-- cause syntax error
		local cmd = string.format("cat %s | litecli -t %s", file, db)
		-- local cmd = string.format("cat %s | sqlite3 %s", file, db)
		-- print(cmd)
		return cmd
	end

	-- if the js file newer than the ts file, the ts file can be said to be
	-- compiled
	local function ts_is_compiled(js, ts)
		local f1 = io.popen("stat -c %Y " .. js)
		local js_epoch = f1:read()
		f1:close()

		local f2 = io.popen("stat -c %Y " .. ts)
		local ts_epoch = f2:read()
		f2:close()

		return js_epoch > ts_epoch
	end

	-- attempt to run .ts file
	local function get_ts_runner(file)
		-- -- https://old.reddit.com/r/neovim/comments/mq4pxn/best_way_to_get_current_buffer_content_as_a_lua/gufgtv8/
		-- if require("util"):buf_contains("@observablehq/plot") then
		-- 	local tmpfile = "/tmp/foo.html"
		-- 	-- vim.cmd(front .. runner .. " | tee " .. tmpfile)
		-- 	vim.cmd(string.format("%s %s | tee %s", front, runner, tmpfile))
		-- 	os.execute("firefox " .. tmpfile)
		-- 	vim.cmd.wincmd("k")
		-- 	vim.cmd.wincmd("h")
		-- 	return
		-- end

		local js = string.gsub(file, ".ts", ".js")

		-- cd first, so that child's node_modules/tsx can be found
		-- this assumes that node_modules and file.ts are at the same level
		vim.fn.chdir(vim.fn.expand("%:p:h")) -- abs dirname (:h %:p)
		file = vim.fn.expand("%:.") -- relative to child dir

		if vim.loop.fs_stat(".env") and vim.loop.fs_stat("~/.local/bin/node23") then
			return "node23 --no-warnings --import=tsx --env-file=.env " .. file
		elseif vim.loop.fs_stat(js) and ts_is_compiled(js, file) then
			-- fastest, but requires already compiled js (which is slow)
			return "node " .. js -- 0.035 s
		elseif vim.loop.fs_stat("./node_modules/tsx") then
			-- run with node directly (without transpilation); requires tsx
			-- npm install --save-dev tsx
			-- https://nodejs.org/api/typescript.html#full-typescript-support
			-- --enable-source-maps doesn't seem to report source line number correctly
			return "node --no-warnings --import=tsx " .. file
		elseif vim.loop.fs_stat("./node_modules/@types/node") then
			-- https://stackoverflow.com/a/78148646
			os.execute("tsc " .. file) -- ts -> js, 1.46 s
			return "node " .. js
		else
			-- TODO: force install?
			error("No suitable ts runner; try npm install --save-dev tsx")
		end
	end

	local runners = {

		-- the great langs
		gleam = "gleam run",
		rust = "RUST_BACKTRACE=1 cargo run", -- TODO: if vim.fn.line(".") >= line num of first match of '#[cfg(test)]', run 'cargo test' instead

		-- the normal langs
		dhall = "dhall-to-json --file " .. curr_file,
		elvish = "elvish " .. curr_file,
		html = "firefox " .. curr_file,
		javascript = "node " .. curr_file,
		kotlin = "kotlinc -script " .. curr_file, -- extremely slow due to jvm (2.5 s for noop?!)
		python = "python3 " .. curr_file,
		ruby = "ruby " .. curr_file,
		sh = "env bash " .. curr_file,
		zig = "zig run " .. curr_file,

		-- the iffy langs
		-- typescript = "NO_COLOR=1 deno run --check=all " .. curr_file,
		sql = get_sql_cmd, --(curr_file),
		typescript = get_ts_runner, --(curr_file),

		-- -- note that :new brings us to repo root (verify with :new|pwd), so we need
		-- -- to not only know where we used to be, but also run the basename.go
		-- -- correctly
		-- go = string.format("cd %s; ", cwd)
		-- 	-- https://stackoverflow.com/a/43953582
		-- 	.. "ls *.go | " -- import functions from same package
		-- 	.. "grep -v _test | " -- ignore test files (ugh)
		-- 	.. "xargs go run",

		-- TODO: it is not clear which cmd should be used
		go = string.format([[ go run "$(dirname %s)"/*.go ]], curr_file),

		-- -- the... kotlin
		-- -- https://kotlinlang.org/docs/command-line.html#create-and-run-an-application
		-- kotlin = string.format(
		-- 	"kotlinc %s -include-runtime -d %s ; java -jar %s",
		-- 	curr_file,
		-- 	string.gsub(curr_file, ".kt", ".jar"),
		-- 	string.gsub(curr_file, ".kt", ".jar")
		-- ),
	}

	local ft = vim.bo.filetype
	local runner = runners[ft]

	if runner == nil then
		print("No runner configured for " .. ft)
		return
	elseif type(runner) == "function" then
		runner = runner(curr_file)
	elseif vim.loop.fs_stat(cwd .. "/pyproject.toml") then
		-- if pyproject.toml, prepend poetry run
		runner = "poetry run " .. runner
	elseif vim.loop.fs_stat(cwd .. "/manage.py") then -- django
		runner = "./manage.py shell < " .. curr_file
		-- elseif string.find(curr_file, "grammar.js") ~= nil then
		-- 	-- runner = "tree-sitter generate ; tree-sitter parse ./testfile 2>/dev/null"
		-- 	-- runner = "tree-sitter generate ; tree-sitter test" -- hard to diff without color
		-- 	runner = "tsfmt testfile"
	end

	-- close all unnamed splits
	for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(bufnr) == "" then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end

	-- print(front .. runner)
	vim.cmd(front .. runner)
	vim.cmd.wincmd(wide and "h" or "k") -- return focus to main split
end -- }}}
vim.keymap.set("n", "<leader>x", exec, { silent = true })

local function init()
	-- {{{
	-- if not saved yet (no filename), force save
	if vim.fn.expand("%") == "" then
		vim.ui.input({
			prompt = "filename: ",
		}, function(input)
			-- early return here only applies to the inner scope (closure)
			if input ~= "" and input ~= nil then
				vim.cmd("w " .. input)
			end
		end)
	end
	if vim.fn.expand("%") == "" then
		return
	end

	local ft = vim.bo.filetype
	-- yes, default ft is empty string...
	ft = (ft == "" or ft == "conf") and "sh" or ft

	-- TODO: double newlines get removed due to splitting
	local templates = {
		python = [[\
#!/usr/bin/env python3

# from glob import glob
# from pprint import pprint
# import logging
# import os
# import re
# import shutil
# import sys
# import urllib

# import pandas as pd
# import requests
# import streamlit as st

# if __name__ == "__main__":
#     main()
]],
		-- rust style string literal
		sh = [=[
#!/usr/bin/env bash
set -euo pipefail

usage() {
        cat << EOF
Usage: $(basename "$0") [options]

EOF
        exit
}

[[ $# -eq 0 ]] && usage
# [[ ${1:-} = --help ]] && usage

# while getopts "<++>" opt; do
#       case ${opt} in
#       \?) usage ;;
#       esac
# done
# shift $((OPTIND - 1))
]=],
	}

	local template = templates[ft]
	if template == nil then
		-- print("No template for", ft)
		return
	end

	-- vim.cmd("0read !cat " .. template)

	-- https://stackoverflow.com/a/32847589
	local lines = {}
	-- note: this strips empty lines
	for l in template:gmatch("[^\r\n]+") do
		table.insert(lines, l)
	end
	vim.api.nvim_buf_set_lines(0, 0, 0, true, lines)
	vim.cmd("w")

	vim.cmd("e")
	vim.cmd("startinsert")
end -- }}}
vim.keymap.set("n", "<leader>I", init, { silent = true })

-- a crappy hack meant for copying a serde `Value` and turning it into a struct
local function replace_selection()
	-- {{{
	-- https://github.com/mfussenegger/dotfiles/blob/fa58149048db153fc27c38e5c815d40a7d637851/vim/dot-config/nvim/lua/me/term.lua#L180
	local mode = vim.api.nvim_get_mode()
	local pos1
	local pos2
	if vim.tbl_contains({ "v", "V", "" }, mode.mode) then
		pos1 = vim.fn.getpos("v")
		pos2 = vim.fn.getpos(".")
	else
		return
	end

	-- https://neovim.io/doc/user/builtin.html#getregion()
	local lines = vim.fn.getregion(pos1, pos2, { type = mode.mode })

	-- replace lines
	local new = table.concat(lines, "\n")
	local foo = [[\([^)]+\)]]
	local types = {
		-- TODO: serde type -> rust type
		Number = "usize",
		Array = "Vec",
		["["] = "<",
		["]"] = ">",
		['"'] = "",
		[foo] = "",
	}
	for k, v in pairs(types) do
		new = vim.fn.substitute(new, k, v, "g")
	end

	-- replace current v selection with new lines
	vim.api.nvim_paste(new .. "\n", false, -1)
end -- }}}
vim.keymap.set("v", "C", replace_selection, { silent = true })

local function debug_print()
	-- {{{
	local filetypes = {

		-- python = 'print(f"{@=}")',
		-- zig = 'std.debug.print("{}\n",.{});',
		go = "fmt.Println(@)",
		javascript = "console.log(@);",
		lua = "print(@)",
		python = "print(@)",
		rust = 'println!("{:#?}", @);',
		typescript = "console.log(@);",
	}

	local ft = vim.bo.filetype
	local cmd = filetypes[ft]
	if ft == nil then
		return
	end

	local cmd_split = {}
	for s in string.gmatch(cmd, "([^@]+)") do
		-- print(s)
		table.insert(cmd_split, s)
	end

	local left = cmd_split[1]
	local right = cmd_split[2]

	vim.cmd.norm("o" .. left .. right)
	if string.len(right) > 1 then
		vim.cmd.norm(string.len(right) - 1 .. "h")
	end
	vim.cmd.startinsert()
end -- }}}
vim.keymap.set("n", "<leader>p", debug_print, { silent = true })

-- example output:
-- `lua/binds.lua:394	local function yank_path()`
local function yank_path()
	local path = vim.fn.expand("%")
	local lnum = vim.fn.line(".")
	local line = vim.fn.trim(vim.api.nvim_get_current_line())
	local str = path .. ":" .. lnum .. "\t" .. line .. "\n"
	vim.fn.setreg("+", str)
end
vim.keymap.set("n", "yp", yank_path, { silent = true })
