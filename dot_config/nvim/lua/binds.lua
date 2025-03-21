-- https://vim.fandom.com/wiki/Unused_keys

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
vim.keymap.set("n", "<F12>", require("util").random_colorscheme)
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
vim.keymap.set("v", "ZZ", "<esc>ZZ")
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
-- tabs
-- vim.keymap.set("n", "<c-m>", ':silent! exe "tabn ".g:lasttab<cr>', { silent = true })
-- vim.keymap.set("n", "rH", ":silent! tabm -1<cr>", { silent = true }) -- do i need this?
-- vim.keymap.set("n", "rL", ":silent! tabm +1<cr>", { silent = true })
-- vim.keymap.set("n", "re", ':silent! exe "tabn ".g:lasttab<cr>', { silent = true })
vim.keymap.set("n", "<c-;>", "g<tab>")
vim.keymap.set("n", "<c-h>", "gT")
vim.keymap.set("n", "<c-l>", "gt")
vim.keymap.set("n", "<c-t>", "<c-6>") -- overridden by wezterm!
vim.keymap.set("n", "r", "<nop>")
vim.keymap.set("n", "rd", ":%bd|e#<cr>zz") -- unload all other buffers/tabs -- https://dev.to/believer/close-all-open-vim-buffers-except-the-current-3f6i
vim.keymap.set("n", "rx", ":tabonly<cr>") -- close all other buffers/tabs (but not delete)

-- splits are only used for exec
vim.keymap.set("n", "rd", ":%bd|e#<cr>zz") -- delete all other buffers/tabs -- https://dev.to/believer/close-all-open-vim-buffers-except-the-current-3f6i
vim.keymap.set("n", "rh", "<c-w><c-h>")
vim.keymap.set("n", "ri", "<c-w>_") -- maximise current split height
vim.keymap.set("n", "rj", "<c-w><c-j>")
vim.keymap.set("n", "rk", "<c-w><c-k>")
vim.keymap.set("n", "rl", "<c-w><c-l>")

-- folds
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
-- vim.keymap.set("n", "<leader><tab>", ":set list!<cr>")
-- vim.keymap.set("n", "<leader>T", ":tabe " .. vim.fn.expand("%:p:h")) -- expanded only once!
vim.keymap.set("n", "<c-s>", "mz{j:<c-u>'{+1,'}-1sort<cr>`z", { silent = true }) -- vim's sort n is not at all like !sort -V
vim.keymap.set("n", "<f10>", ":colo<cr>")
vim.keymap.set("n", "<leader><tab>", ":set list!<cr>")
vim.keymap.set("n", "<leader>D", [[:g/\v/d<Left><Left>]])
vim.keymap.set("n", "<leader>U", ":exec 'undo' undotree()['seq_last']<cr>") -- remove all undos -- https://stackoverflow.com/a/47524696
vim.keymap.set("n", "<leader>n", [[:%g/\v/norm <Left><Left><Left><Left><Left><Left>]])
vim.keymap.set("n", "<leader>r", [[:%s/\v/g<Left><Left>]]) -- TODO: % -> g/PATT/
vim.keymap.set("v", "D", [[:g/\v/d<Left><Left>]]) -- delete lines
vim.keymap.set("v", "n", [[:g/\v/norm <Left><Left><Left><Left><Left><Left>]])
vim.keymap.set("v", "r", [[:s/\v/g<Left><Left>]])

vim.keymap.set("n", "<leader>T", function()
	vim.api.nvim_feedkeys(
		":tabe " .. vim.fn.expand("%:p:h"), -- .. "/",
		"n",
		false
	)
end)

-- context dependent binds
-- https://github.com/neovim/neovim/blob/012cfced9b5/runtime/doc/lua-guide.txt#L450

-- close window if scratch
local function update_or_close()
	vim.cmd(
		-- expr must be false, else 'not allowed to change text'
		(vim.bo.buftype == "nofile" or vim.bo.buftype == "help") and "bd"
			-- see also: shortmess
			or "silent update"
	)
end

vim.keymap.set("n", "<c-c>", update_or_close, { silent = true })
vim.keymap.set("n", "<cr>", update_or_close, { silent = true })
vim.keymap.set("n", "<leader><space>", update_or_close, { silent = true })
vim.keymap.set("n", "x", function()
	return vim.bo.modifiable == 0 and ":bd<cr>" or '"_x'
end, { silent = true, expr = true })

for _, vmode in pairs({ "i", "n", "x" }) do
	for _, mod in pairs({ "", "c-", "a-" }) do
		for _, n in pairs({ "", "2-", "3-", "4-" }) do
			vim.keymap.set(vmode, string.format("<%s%smiddlemouse>", mod, n), "<nop>")
			vim.keymap.set(vmode, string.format("<%s%srightmouse>", mod, n), "<nop>")
		end
	end
end

for _, n in pairs({ "2-", "3-", "4-", "c-", "a-" }) do
	vim.keymap.set("i", string.format("<%sleftmouse>", n), "<nop>")
	vim.keymap.set("n", string.format("<%sleftmouse>", n), "<nop>")
end

-- vim-fugitive; the only plugin allowed in this file, because of how critical it is
-- most of fugitive's interactive features are better done via telescope (e.g. git log, git status)
vim.keymap.set("n", "<leader>ga", ":Gwrite<cr>", { desc = "add current buffer" })
vim.keymap.set("n", "<leader>gp", ":Dispatch! git push<cr>", { desc = "git push (async)" })

local function commit_staged()
	-- {{{
	if not require("util"):in_git_repo() then
		print("not in git repo")
	elseif -- any changes have been staged (taken from gc)
		-- commit currently staged chunk(s)
		require("util"):get_command_output("git diff --name-only --cached --diff-filter=M | grep .") ~= ""
	then
		vim.cmd("Git commit --quiet -v")
	elseif -- current file has changes
		-- commit entire file
		-- exits with 1 if there were differences
		not require("util"):command_ok("git diff --quiet " .. vim.api.nvim_buf_get_name(0))
	then
		-- do i ever need to commit a whole file while there are staged chunks? remains to be seen
		vim.cmd("Git commit --quiet -v %")
	else
		print("no changes to stage")
	end
end -- }}}

vim.keymap.set("n", "<leader>C", commit_staged, { desc = "commit current buffer/hunks" })
vim.keymap.set("n", "<leader>c", commit_staged, { desc = "commit current buffer/hunks" })

vim.keymap.set("n", "<leader>gc", function()
	print("deprecated; use <leader>c or <leader>C")
end, { desc = "deprecated" })

-- TODO: git add % + git commit --amend --no-edit
vim.keymap.set("n", "<leader>gC", function()
	if require("util"):command_ok("git status --porcelain | grep -q '^M'") then
		vim.cmd("Git commit --quiet --amend --no-edit")
		print(
			string.format(
				"Added hunk(s) to previous commit: %s",
				require("util"):get_command_output("git log -n 1 --pretty=format:%s")
			)
		)
	else
		print("No hunks staged")
	end
end, { desc = "append currently staged hunks to previous commit" })

vim.keymap.set("n", "<leader>gd", function()
	vim.cmd("vertical Git -p diff master...HEAD") -- J and K are smartly remapped, apparently
end, { desc = "diff current HEAD against master" })

-- niche
vim.keymap.set("i", "<c-y>", "<esc>lyBgi") -- yank current word without moving, useful only for note taking
vim.keymap.set("n", "<leader>I", [[:lua print(vim.inspect())<left><left>]])
vim.keymap.set("n", "<leader>M", '"qp0dd') -- dump q buffer into a newline and cut it (for binding)
vim.keymap.set("n", "<leader>y", [[:let @a=''<bar>g/\v/yank A<left><left><left><left><left><left><left>]]) -- yank lines containing
vim.keymap.set("n", "z/", "ZZ") -- lazy exit

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

-- subs = { { pat = str, rep = str } }
--
-- substitutions are applied in sequential order
local function apply_substitutions(subs)
	for _, sub in pairs(subs) do
		pcall(function() -- ignore all errors
			vim.cmd("%" .. string.format("s/\\v%s/%s/g", sub.pat, sub.rep))
			-- vim.api.
		end)
	end
end

local function get_c_doc()
	-- {{{
	-- requires man-pages (c) and cppman (cpp)
	local cmd = (vim.bo.filetype == "c" and "man 3" or "cppman") .. " " .. vim.fn.expand("<cword>")
	cmd = "vnew | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! " .. cmd
	vim.cmd(cmd)
	vim.cmd.norm("gg")
	vim.cmd.setlocal("ft=man")
	vim.keymap.set("n", "J", "}zz", { buffer = true })
	vim.keymap.set("n", "K", "{zz", { buffer = true })
end -- }}}

-- note: this will fail the first time (after startup) selection a made, for
-- unknown reasons
local function surround_selection(left, right)
	-- {{{
	local line_start = vim.fn.getpos("'<")[2]
	local line_end = vim.fn.getpos("'>")[2]
	if line_start == 0 then
		return
	end

	local lines = vim.fn.getline(line_start, line_end)
	assert(type(lines) == "table")
	table.insert(lines, 1, left)
	table.insert(lines, right)
	vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, lines)
end -- }}}

local function serde_value_to_struct()
	-- {{{
	-- https://github.com/mfussenegger/dotfiles/blob/fa58149048/vim/dot-config/nvim/lua/me/term.lua#L180
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

local function debug_print(cmd)
	-- {{{
	local filetypes = {

		c = "printf(@);",
		elixir = "IO.puts(@)",
		gleam = "io.debug(@)",
		go = "fmt.Println(@)", -- fmt.Printf("%+v\n", @)
		javascript = "console.log(@);",
		javascriptreact = "console.log(@);",
		lua = "print(@)", -- print(vim.inspect(@))
		python = "print(@)",
		rust = 'println!("{:?}", @);', -- println!("{:#?}", @);
		sh = 'echo "$@"',
		typescript = "console.log(@);",
		typescriptreact = "console.log(@);",
		zig = [[std.debug.print("{any}\n", .{@});]],
	}

	local ft = vim.bo.filetype
	cmd = cmd or filetypes[ft]
	if cmd == nil then
		print("No printer configured for " .. ft)
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

-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#documenting-types
---@type {[string]: { mode: string, lhs: string, rhs: string|function, opts: table? }[]}
local ft_binds = { -- {{{

	git = {
		{ "n", "<cr>", ":q<cr>" },
		{ "n", "j", "J", { remap = true } }, -- https://github.com/tpope/vim-fugitive/blob/320b18fba/autoload/fugitive.vim#L8019
		{ "n", "k", "K", { remap = true } },
	},

	["gitcommit,diff"] = {
		{
			"n",
			"J",
			function()
				vim.fn.search("^@@", "W")
				vim.cmd.norm("zt")
			end,
		},
		{
			"n",
			"K",
			function()
				vim.fn.search("^@@", "Wb")
				vim.cmd.norm("zt")
			end,
		},
		{
			"n",
			"{",
			function()
				vim.fn.search("^diff", "Wb")
				vim.cmd.norm("zt")
			end,
		},
		{
			"n",
			"}",
			function()
				vim.fn.search("^diff", "W")
				vim.cmd.norm("zt")
			end,
		},
	},

	man = {
		{ "n", "J", "<c-f>zz" },
		{ "n", "K", "<c-b>zz" },
	},

	yaml = {
		{
			"n",
			")",
			function()
				vim.fn.search([[^\S\+:]], "W")
				vim.cmd.norm("zt")
			end,
		},
		{
			"n",
			"(",
			function()
				vim.fn.search([[^\S\+:]], "Wb")
				vim.cmd.norm("zt")
			end,
		},
	},

	sql = {

		-- -- not very useful, hover is still more informative
		-- {
		-- 	"n",
		-- 	"?",
		-- 	function() -- view table schema
		-- 		local t = vim.fn.expand("<cword>")
		-- 		-- TODO: suppress connection_get_columns error
		-- 		local cols = require("dbee").api.core.connection_get_columns(
		-- 			require("dbee").api.core.get_current_connection().id,
		-- 			{ table = t, schema = "public", materialization = "table" }
		-- 		)
		-- 		-- only one print statement (the last) can be displayed, so use
		-- 		-- vim.notify to display multiline string
		-- 		local s = {}
		-- 		for _, col in pairs(cols) do
		-- 			table.insert(s, string.format("%s: %s", col.name, col.type))
		-- 		end
		-- 		-- TODO: display in float window
		-- 		vim.notify(table.concat(s, "\n"))
		-- 	end,
		-- },

		{
			"n",
			")",
			function()
				if require("dbee").is_open() then
					-- TODO: wrap page
					require("dbee").api.ui.result_page_next()
				else
					-- api.nvim_input and cmd.norm are recursive (cmd.norm at least errors noisily)
					vim.api.nvim_feedkeys(")", "n", false)
				end
			end,
		},
		{
			"n",
			"(",
			function()
				if require("dbee").is_open() then
					require("dbee").api.ui.result_page_prev()
				else
					vim.api.nvim_feedkeys("(", "n", false)
				end
			end,
		},

		{ "n", "<leader>H", require("pickers").devdocs },
		{ "n", "<leader>dc", require("pickers").dbee_connections },
	},

	["qf,help,man,lspinfo,startuptime,Trouble,lazy"] = {
		{ "n", "q", "ZZ" },
		{ "n", "x", "ZZ" },
		{ "n", "<esc>", "ZZ" },
	},

	["sh,bash"] = {
		{ "n", "<bar>", ":.s/ <bar> / <bar>\\r/g<cr>" },
		{ "n", "<leader>X", ":!chmod +x %<cr>" }, -- TODO: shebang
	},

	["typescript,javascript,typescriptreact,javascriptreact"] = {
		{ "n", "<leader>a", ":!npm install " }, -- TODO: yarn.lock -> yarn
		{ "n", "<leader>d", "O/**  */<left><left><left>" }, -- neogen always documents class, not field

		-- replace != and ==; probably better via find+sed, or better still, biome auto fix
		{ "n", "<leader>=", [[:%s/\v ([=!])\= / \1== /g|w<cr><c-o>]] },

		{
			"n",
			"<leader>X",
			function()
				-- turn inline comment (of current line) into jsdoc
				-- https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html
				-- for large scale changes, consider doing this in sed:
				-- rg -t typescript '^(  [^: ]+:.+) // (.+)' .
				-- /** \2 */\n\1
				local line = vim.fn.getline(".")
				local stmt, comment = line:match("(.+) // (.+)")
				-- local lnum = vim.fn.getpos(".")[2]
				local lnum = vim.fn.line(".")
				vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, {
					string.format("/** %s */", comment),
					stmt,
				})
			end,
		},

		{
			"n",
			"<leader>at",
			function()
				apply_substitutions({
					-- ava -> vitest

					-- %s/\v.+t\.throwsAsync\((.+)\);/await expect(async () => { await \1 }).rejects.toThrowError();/g
					-- { pat = [[]], rep = [[]] },
					{ pat = [[\(t\)]], rep = [[()]] },
					{ pat = [[\.serial]], rep = [[]] },
					{ pat = [[t\.(true|false)([^;]+)]], rep = [[expect\2.toBe(\1)]] },
					{ pat = [[t\.is\(([^,]+), ([^)]+)\)]], rep = [[expect\(\1).toBe(\2)]] },
					{ pat = [[t\.not\(([^,]+), ([^)]+)\)]], rep = [[expect\(\1).not.toBe(\2)]] },

					{ pat = [[ !\= null(, [^)]+)?\).toBe\(true\)]], rep = [[\1).toBeTruthy()]] },
				})
			end,
		},

		-- arrow methods -> regular methods (use with caution)
		-- %s/\v^  (\w+) \= (async )?(.+)\=\>/\2\1\3/g

		{
			"n",
			"<leader>)", -- leader A = code action
			function()
				debug_print("(async () => {@})();")
			end,
		},

		-- {
		-- 	"x",
		-- 	"A",
		-- 	function()
		-- 		if vim.fn.mode() == "V" then
		-- 			surround_selection("(async () => {", "})();")
		-- 		end
		-- 	end,
		-- },
	},

	rust = {

		-- {"n", "<leader>A", "oassert_eq!();<esc>hi", {  }},
		{ "i", "<c-j>", ";<cr>" },
		{ "i", "<c-l>", "<c-o>f)<c-o>l" }, -- exit parens (idk)
		{ "n", "<leader>a", ":!cargo add " },
		{ "v", "C", serde_value_to_struct },
	},

	zig = {
		{ "i", "<c-j>", ";<cr>" },
	},

	c = {
		-- TODO: switch between .c and .h (vim-fswitch, maybe clangd already has this)

		-- https://en.wikipedia.org/wiki/C_POSIX_library
		-- pacman -Ql glibc | grep -Po '/usr/include/.+\.h'

		{
			"n",
			"<leader>I", -- <leader>i reserved for lsp incoming
			function()
				local line = vim.fn.input("include: ")
				vim.api.nvim_buf_set_lines(0, 0, 0, false, { string.format("#include <%s.h>", line) })
				vim.cmd.w()
			end,
		},

		-- TODO: #include <cFOO> -> #include <FOO.h>

		-- {
		-- 	"n",
		-- 	"<leader>E",
		-- 	-- TODO: selecting a declaration is not trivial (e.g. func param)
		-- 	function()
		-- 		local decl = vim.api.nvim_get_current_line()
		-- 		print(string.format([[cdecl <(echo 'explain %s')]], decl))
		-- 	end,
		-- },

		{ "n", "<leader>H", get_c_doc },

		{
			"n",
			"<leader>E",
			function()
				-- add error handling to fallible func call
				local line = vim.api.nvim_get_current_line()
				if not string.find(line, ";$") then
					print("cannot wrap multi-line func")
					return
				end

				local func = string.match(line, "%S[^(]+")
				local repl = string.format([[if (%s == -1) { die("%s"); };]], string.gsub(line, ";$", ""), func)
				vim.api.nvim_set_current_line(repl)
				vim.cmd.w()
			end,
		},
	},

	cpp = {
		{ "n", "<leader>H", get_c_doc },
	},

	-- TODO: also include gomod
	go = {

		-- go-logging -> slog
		-- %s/\v(log\.\w+)f\(("[^"]+"), ([^)]+)/\1(\2, "\3", \3/g

		-- camel -> snake
		-- https://stackoverflow.com/a/28795550
		-- sed -i -r '/^\t+".*[A-Z]/ s/([a-z0-9])([A-Z])/\1_\L\2/g; s/"([A-Z])/"\L\1/g' file.go

		{ "n", "<leader>E", "oif err!=nil{panic(err)}<esc>:w<cr>o" }, -- https://youtube.com/watch?v=fIp-cWEHaCk&t=1437

		{
			"n",
			"<leader>t",
			function()
				vim.system({ "go", "mod", "tidy" })
				vim.cmd("LspRestart")
				vim.cmd("Trouble refresh")
			end,
		},

		-- switch to early return to reduce nesting, assumes return block is 1-line
		-- note: this does -not- invert the condition
		{ "n", "<leader>N", "$m`%dddj``p:w<cr>" },

		-- TODO: go get foo, and import foo
		-- https://github.com/ray-x/go.nvim/blob/cde0c7a110c0f65b9e4e6baf342654268efff371/lua/go/goget.lua#L23
		-- {"n", "<leader>a", 'gg/import<cr>o"":!go get github.com/', {  }},

		-- function GoGet(pkg)
		-- 	local url = "github.com/" .. pkg
		--
		-- 	-- 1. go get github...
		-- 	vim.system(
		-- 		{ "go", "get", url },
		-- 		{},
		-- 		-- on_exit
		-- 		function(obj)
		-- 			if obj.code == 0 then
		-- 				print("ok: " .. pkg)
		-- 				os.execute("notify-send " .. pkg)
		-- 			else
		-- 				print(obj.signal)
		-- 				print(obj.stdout)
		-- 				print(obj.stderr)
		-- 		}
		-- 	}
		-- 	):wait()
		-- 	-- 2. add import statement (_ "github.com/..."), save
		-- 	-- 3. go mod tidy
		-- { "n", "<leader>a", ":lua GoGet''<left>" },
	},

	python = {
		{
			"n",
			"<leader>dd",
			function() -- toggle ruff
				vim.diagnostic.reset(nil, 0)
				require("lint").linters_by_ft = {
					python = #require("lint").linters_by_ft.python > 0 and {} or { "ruff" },
				}
				require("lint").try_lint()
			end,
		},

		{
			"n",
			"<leader>P",
			function()
				apply_substitutions({ -- os -> Path
					{ pat = [[os.remove\((.+)\)]], rep = [[Path(\1).unlink()]] },
					-- os.path.isdir\((.+)\)/Path(\1).is_dir()
					-- os.path.isfile\((.+)\)/Path(\1).is_file()
				})
			end,
		},
	},

	markdown = {
		-- TODO: if checkbox item (`- [ ]`), toggle check
		-- https://github.com/tadmccorkle/markdown.nvim#lists

		-- local function mn()
		-- 	require("markdown.nav").next_heading()
		-- 	vim.cmd.norm("zz")
		-- end
		-- local function mp()
		-- 	require("markdown.nav").prev_heading()
		-- 	vim.cmd.norm("zz")
		-- end

		-- {"n", "J", mn, { remap = true }},
		-- {"n", "K", mp, { remap = true }}, -- TS hover
		-- {"n", "[[", mp, { remap = true }},
		-- {"n", "]]", mn, { remap = true }},
		-- {"n", "gk", require("markdown.nav").prev_heading, { remap = true }},
		{ "n", "<c-k>", "ysiw]Ea()<esc>Pgqq", { remap = true } }, -- wrap in hyperlink
		{ "n", "<leader>d", toggle_diagnostics },
		{
			"n",
			"<leader>s",
			function()
				-- 'plain' require('foo').func requires 'foo' to be available
				require("telescope").extensions.heading.heading()
			end,
		},
	},
} -- }}}

for ft, binds in pairs(ft_binds) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = function()
			for _, bind in pairs(binds) do
				if #bind >= 4 then
					bind[4]["buffer"] = true
				else
					table.insert(bind, { buffer = true })
				end
				vim.keymap.set(unpack(bind))
			end
		end,
	})
end

local function c_compiler_cmd()
	-- {{{
	-- if vim.fn.executable("tcc") then
	-- 	return "tcc"
	-- end

	-- allegedly, gcc/g++ prioritises fast runtime (slow compile time), clang(++)
	-- prioritises fast compile time (slow runtime).
	-- https://github.com/nordlow/compiler-benchmark
	--
	-- however, with my limited testing, this is not true; gcc compile time is
	-- about 65% that of clang. in doubt, profile compile times on your machine.

	local cmds = {
		clang = {
			-- https://clang.llvm.org/docs/index.html
			-- https://clang.llvm.org/docs/ClangCommandLineReference.html#target-independent-compilation-options

			"-fsanitize="
				.. table.concat({
					"undefined", -- https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#ubsan-checks
					"leak", -- included in address https://clang.llvm.org/docs/LeakSanitizer.html

					-- clang does not specify whether sanitizers are incompatible.
					-- however, they do provide estimates of expected slowdown

					-- "address", -- 2x https://clang.llvm.org/docs/AddressSanitizer.html
					-- "memory", -- 3x https://clang.llvm.org/docs/MemorySanitizer.html
					-- "realtime", -- not general purpose
					-- "thread", -- 5x https://clang.llvm.org/docs/ThreadSanitizer.html
					-- "type", -- experimental https://clang.llvm.org/docs/TypeSanitizer.html
				}, ","),
		},

		gcc = {

			-- "-O0",
			-- "-coverage",
			-- "-fdiagnostics-format=vi", -- clang and gcc have different options
			-- "-ferror-limit=0", -- clang-only
			-- "-ggdb",

			-- https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html

			"-fno-omit-frame-pointer",
			"-ftrivial-auto-var-init=zero",

			-- https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#index-fstrict-aliasing
			-- https://danso.ca/blog/strict-aliasing/
			"-fstrict-aliasing",

			-- https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#index-fsanitize_003daddress
			-- several sanitizers are incompatible with each other (e.g. address and leak)

			"-fsanitize=address,leak,pointer-compare,undefined",
		},
	}

	local cmd = "gcc"
	return cmd .. " " .. table.concat(cmds[cmd], " ")
end -- }}}

local function ts_is_compiled(js, ts)
	-- {{{
	-- if the js file newer than the ts file, the ts file can be said to be
	-- compiled

	local f1 = assert(io.popen("stat -c %Y " .. js))
	local js_epoch = f1:read()
	f1:close()

	local f2 = assert(io.popen("stat -c %Y " .. ts))
	local ts_epoch = f2:read()
	f2:close()

	return js_epoch > ts_epoch
end -- }}}

local function get_ts_runner(file)
	-- {{{
	local node_version = require("util"):get_command_output("node -v")

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

	-- if vim.loop.fs_stat(".env") and vim.fn.executable("node23") then
	-- 	return "node23 --no-warnings --import=tsx --env-file=.env " .. file

	-- TODO: must use tsx if any file imports are needed; node imports must
	-- specify file ext (fixable at top-level imports, but not at subsequent
	-- imports)

	if node_version >= "v22.7.0" then -- 2x faster than tsx, but not guaranteed to work
		-- https://nodejs.org/en/learn/typescript/run-natively#running-typescript-natively
		return "node --experimental-strip-types --experimental-transform-types " .. file
	elseif node_version >= "v22.6.0" then
		return "node --experimental-strip-types " .. file
	elseif vim.loop.fs_stat(js) and ts_is_compiled(js, file) then
		-- fastest, but requires already compiled js (which is slow)
		return "node " .. js -- 0.035 s
	--experimental-transform-types
	elseif vim.loop.fs_stat("./node_modules/tsx") then
		-- run with node directly (without transpilation); requires tsx
		-- https://nodejs.org/api/typescript.html#full-typescript-support
		-- --enable-source-maps doesn't seem to report source line number correctly
		-- node --import=tsx is significantly faster than yarn tsx (avoids unnecessary overhead)
		return "node --no-warnings --import=tsx " .. file
	elseif vim.fn.executable("tsc") == 1 and vim.loop.fs_stat("./node_modules/@types/node") then
		-- https://stackoverflow.com/a/78148646
		os.execute("tsc " .. file) -- ts -> js, 1.46 s
		return "node " .. js
	elseif vim.loop.fs_stat("./package.json") then
		-- TODO: print is shown after execute
		print("installing tsx...") -- ts-node is not just single binary
		-- npm install --save-dev tsx
		os.execute("yarn add --dev tsx >/dev/null")
		-- vim.fn.jobstart("yarn add --dev tsx") -- possibly bad recursion, high memory
		return get_ts_runner(file)
	else
		error("need npm init")
	end
end -- }}}

local function start_dbee()
	-- {{{
	local dbee = require("dbee")
	local scratch_dir = os.getenv("HOME") .. "/.local/state/nvim/dbee/notes/memory_source_memory1"
	local scratch_path = scratch_dir .. "/" .. vim.fn.expand("%:t")

	-- ensure note is synced to the file
	local cmd = string.format([[ln -sf %s %s/]], vim.fn.expand("%:p"), scratch_dir)
	os.execute(cmd)

	-- file -> note -> id
	local id = require("dbee").api.ui.editor_search_note_with_file(scratch_path).id
	dbee.api.ui.editor_set_current_note(id)

	local function buffer_to_string()
		local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
		return table.concat(content, "\n")
	end
	dbee.execute(buffer_to_string())
	vim.cmd.wincmd("|") -- hide drawer+call log (hacky)
end -- }}}

-- run current file and dump stdout to scratch buffer
local function exec()
	-- {{{
	-- running tests is better left to the terminal itself (e.g. wezterm)

	-- relative to cwd
	local curr_file = vim.fn.expand("%")
	local ft = vim.bo.filetype

	if vim.bo.filetype == "nofile" then
		return
	elseif vim.bo.filetype == "sql" then
		-- local script = curr_file:gsub("%.sql$", "")
		if require("dbee").is_open() then
			require("dbee").api.ui.editor_do_action("run_file")
		elseif require("util"):buf_contains("-- name: ") then
			print("cannot exec sqlc file")
		else
			start_dbee()
		end
		return
	end

	-- TODO: async (Dispatch)
	local front = "new | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! "
	local wide = vim.o.columns > 150

	-- split dimensions -must- be declared in the [v]new command. attempting to
	-- shrink a main split will not enlarge the secondary split!
	if wide then -- vsplit if wide enough
		local w = math.floor(vim.o.columns * 0.33)
		front = w .. " v" .. front
	else
		local h = vim.o.lines * 0.2
		front = h .. front
	end

	curr_file = vim.fn.shellescape(curr_file)
	local cwd = vim.fn.getcwd()

	local function get_py_runner()
		if vim.fn.executable("uv") and require("util"):buf_contains("# /// script") then
			-- ~/.cache/uv
			return "uv run "
		elseif vim.loop.fs_stat(cwd .. "/pyproject.toml") then
			return "poetry run python3 "
		else
			return "python3 "
		end
	end

	local runners = {

		-- the great langs
		gleam = "gleam run",
		rust = "RUST_BACKTRACE=1 cargo run", -- TODO: if vim.fn.line(".") >= line num of first match of '#[cfg(test)]', run 'cargo test' instead

		-- jq = string.format("jq -f %s %s", curr_file, curr_file:gsub(".jq", ".json")),
		-- the normal langs
		dhall = "dhall-to-json --file " .. curr_file,
		elixir = "elixir " .. curr_file, -- note: time elixir -e "" takes 170 ms lol
		elvish = "elvish " .. curr_file,
		haskell = "runghc " .. curr_file,
		html = "firefox " .. curr_file,
		javascript = "node " .. curr_file,
		kotlin = "kotlinc -script " .. curr_file, -- extremely slow due to jvm (2.5 s for noop?!)
		ocaml = "ocaml " .. curr_file,
		python = get_py_runner() .. curr_file,
		ruby = "ruby " .. curr_file,
		sh = "env bash " .. curr_file,
		zig = "zig run " .. curr_file,

		-- the iffy langs
		-- typescript = "NO_COLOR=1 deno run --check=all " .. curr_file,
		-- sql = get_sql_cmd, --(curr_file),
		typescript = get_ts_runner, --(curr_file),

		["javascript.mongo"] = string.format(
			-- -f FILE requires FILE to be mongosh (not js)
			[[mongosh %s --authenticationDatabase admin --quiet --eval < %s | sed -r 's/^\S+>[ .]*//g']],
			-- .. [[ | node --eval "console.log(JSON.stringify($(< /dev/stdin)))" | jq]],
			vim.env.MONGO_URL,
			curr_file
		),

		-- note that :new brings us to repo root (verify with :new|pwd), so we need
		-- to not only know where we used to be, but also run the basename.go
		-- correctly
		-- inexplicably, go 1.24 (?) may no longer write to stdout from within nvim shell
		go = string.format([[ cd %s; go run ./*.go 2>&1 | sponge /dev/stdout ]], cwd),
		-- .. "ls *.go | " -- import functions from same package; https://stackoverflow.com/a/43953582
		-- .. "grep -v _test | " -- ignore test files (ugh)
		-- .. "xargs go run",

		-- -- TODO: it is not clear which cmd should be used
		-- go = string.format([[ go run "$(dirname %s)"/*.go ]], curr_file),

		-- note: -static generates a fully self-contained binary. this roughly
		-- doubles compile time, and makes the binary about 50x bigger

		-- note: -W flags should be passed to clangd directly
		-- optional: checksec --file=main --output=json | jq .
		-- optional: strace ./main

		c = string.format(
			[[ %s %s -o %s && ./%s 2>&1 ]],
			c_compiler_cmd(),
			curr_file,
			string.gsub(curr_file, ".c", ""),
			string.gsub(curr_file, ".c", "")
		),

		-- should use make/cmake/ccache:
		-- hello: hello.cpp
		-- 	g++ hello.cpp -o hello
		cpp = vim.loop.fs_stat("Makefile") and string.format([[ make && ./%s ]], string.gsub(curr_file, ".cpp", ""))
			or string.format(
				[[ time g++ %s -O0 -o %s && ./%s ]],
				curr_file,
				string.gsub(curr_file, ".cpp", ""),
				string.gsub(curr_file, ".cpp", "")
			),

		-- -- the... kotlin
		-- -- https://kotlinlang.org/docs/command-line.html#create-and-run-an-application
		-- kotlin = string.format(
		-- 	"kotlinc %s -include-runtime -d %s ; java -jar %s",
		-- 	curr_file,
		-- 	string.gsub(curr_file, ".kt", ".jar"),
		-- 	string.gsub(curr_file, ".kt", ".jar")
		-- ),
	}

	local runner = runners[ft]

	if ft == "" then
		return
	elseif runner == nil then
		print("No runner configured for " .. ft)
		return
	elseif type(runner) == "function" then
		runner = runner(curr_file)
		-- elseif vim.loop.fs_stat(cwd .. "/manage.py") then -- django
		-- 	runner = "./manage.py shell < " .. curr_file
		-- elseif string.find(curr_file, "grammar.js") ~= nil then
		-- 	-- runner = "tree-sitter generate ; tree-sitter parse ./testfile 2>/dev/null"
		-- 	-- runner = "tree-sitter generate ; tree-sitter test" -- hard to diff without color
		-- 	runner = "tsfmt testfile"
	end

	require("util"):close_unnamed_splits()
	-- print(front .. runner)
	vim.cmd(front .. runner)
	vim.cmd.norm("gg")
	vim.cmd.wincmd(wide and "h" or "k") -- return focus to main split
	require("util"):resize_2_splits()
end -- }}}
vim.keymap.set("n", "<leader>x", exec, { silent = true })

vim.keymap.set("n", "<leader>p", debug_print, { silent = true })

local function yank_path()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("yanked:", path)
end
vim.keymap.set("n", "yp", yank_path, { silent = true })

-- example output:
-- `lua/binds.lua:394	local function yank_path()`
local function yank_line_and_path()
	local path = vim.fn.expand("%")
	local lnum = vim.fn.line(".")
	local line = vim.fn.trim(vim.api.nvim_get_current_line())
	local str = path .. ":" .. lnum .. "\t" .. line .. "\n"
	vim.fn.setreg("+", str)
end
vim.keymap.set("n", "yP", yank_line_and_path, { silent = true })

-- [[#!/usr/bin/env bash
-- set -euo pipefail]]
