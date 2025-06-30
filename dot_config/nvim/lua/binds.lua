-- https://vim.fandom.com/wiki/Unused_keys

-- :!neomutt -i % -s <subj> -- <email>

vim.g.mapleader = " " -- must be declared before declaring lazy plugins (citation needed)
vim.g.maplocalleader = " "

-- essentials
-- vim.keymap.set("n", "?>", ":wqa<cr>")
vim.keymap.set("c", "<c-h>", "<s-left>")
vim.keymap.set("c", "<c-j>", "<down>") -- defaults do nothing
vim.keymap.set("c", "<c-k>", "<up>")
vim.keymap.set("c", "<c-l>", "<s-right>")
vim.keymap.set("c", "<c-o>", "<s-tab>")
vim.keymap.set("i", "<c-c>", "<esc>", { remap = true, silent = true }) -- <c-c> kills cursorline
vim.keymap.set("i", "<c-h>", "<s-left>") -- TODO: would be good to be able to switch tabs
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
vim.keymap.set("v", "ZZ", "<esc>ZZ")
vim.keymap.set("v", "x", '"_x')

vim.keymap.set("n", "Z?", function()
	-- close all terminals, possibly dangerous? safe behaviour is to switch to
	-- first tab containing term
	for _, b in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(b):match("^term") then
			vim.cmd("bd! " .. b)
		end
	end

	vim.cmd("wqa")
end)

for i = 1, 12 do -- lua ranges are inclusive (lol)
	vim.keymap.set({ "i", "n" }, string.format("<f%d>", i), function() end)
end

-- https://unix.stackexchange.com/a/356407
-- large motions, jumps
vim.keymap.set("n", "<c-i>", "<c-o>zz") -- jumplist; o = forward is more intuitive
vim.keymap.set("n", "<c-j>", "<c-d>zz") -- <c-u/d> is more stable than <c-b/f>
vim.keymap.set("n", "<c-k>", "<c-u>zz")
vim.keymap.set("n", "<c-o>", "<c-i>zz")
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
vim.keymap.set("n", "r", "<nop>")
vim.keymap.set("n", "rd", ":%bd|e#<cr>zz") -- unload all other buffers/tabs -- https://dev.to/believer/close-all-open-vim-buffers-except-the-current-3f6i
vim.keymap.set("n", "rx", ":tabonly<cr>") -- close all other buffers/tabs (but not delete)

-- vim.keymap.set("t", "<c-.>", "<c-\\><c-n>gt") -- navigate tab from term; c-h/c-l are taken by readline
-- vim.keymap.set("t", "<c-x>", "<c-\\><c-n>gT") -- not very ergonomic tbh

-- splits are used for exec/term/Dispatch
-- vim.keymap.set("t", "<c-x>", "<c-\\><c-n><c-w>_i") -- c-i conflicts with tab
vim.keymap.set("n", "rh", "<c-w><c-h>")
vim.keymap.set("n", "ri", "<c-w>_") -- maximise current split height
vim.keymap.set("n", "rj", "<c-w><c-j>")
vim.keymap.set("n", "rk", "<c-w><c-k>")
vim.keymap.set("n", "rl", "<c-w><c-l>")

local function is_wide()
	local wide = vim.o.columns > 150
	if wide then
		return true, math.floor(vim.o.columns * 0.33)
	else
		return false, vim.o.lines * 0.2
	end
end

local last_win = nil

-- check all bufs for a terminal. if one is found, get the tab (and window) it
-- belongs to, and switch to it. in other words, there can effectively only
-- ever be a single terminal in nvim
local function open_terminal()
	for _, t in pairs(vim.api.nvim_list_tabpages()) do
		-- if current tab contains a term, close it OR go to it
		for _, w in pairs(vim.api.nvim_tabpage_list_wins(t)) do
			-- print(vim.inspect(vim.api.nvim_win_get_config(w)))
			local b = vim.api.nvim_win_get_buf(w)
			if vim.api.nvim_buf_get_name(b):match("^term") then
				-- vim.cmd("bd! " .. b) -- close
				-- vim.api.nvim_set_current_tabpage(t) -- go to tab (not necessary)
				-- vim.cmd.wincmd(wide and "l" or "j") -- go to split (also not necessary)
				last_win = vim.api.nvim_get_current_win()
				vim.api.nvim_set_current_win(w)
				return
			end
		end
	end

	local wide, ratio = is_wide()
	vim.cmd(ratio .. (wide and "v" or "") .. "split|terminal")
end

-- vim.keymap.set("n", "<c-e>", open_terminal, { silent = true })
vim.keymap.set("n", "<c-t>", open_terminal, { silent = true })

-- scrollback is also nice (handled by terminal itself), but less important

vim.keymap.set(
	"t",
	"<c-t>",
	-- "<c-\\><c-n>g<tab>" -- always goes to another tab
	-- "<c-\\><c-n><c-6>"

	-- switch to most recently used tab, basically like ctrl-6
	function()
		-- bdelete bypasses annoying 'process exited with' message
		-- vim.cmd("bdelete! " .. vim.fn.expand("<abuf>"))

		-- decent?
		if last_win then
			vim.api.nvim_set_current_win(last_win)
			return
		end

		local wide, _ = is_wide()
		vim.cmd.wincmd(wide and "h" or "k")
	end
)

-- the previous bind usually works nicely the first time (since we remain in
-- the same tab), but can become somewhat annoying once we start jumping
-- between tabs. this ensures we remain in the same tab
vim.keymap.set("t", "<c-e>", function()
	local wide, _ = is_wide()
	vim.cmd.wincmd(wide and "h" or "k")
end)

-- vim.keymap.set("t", "<c-z>", function() end) -- wezterm takes precedence
vim.keymap.set("t", "<c-i>", "<nop>")
vim.keymap.set("t", "<c-o>", "<nop>")

-- folds
vim.keymap.set("n", "zH", "zM")
vim.keymap.set("n", "zL", "zR")
vim.keymap.set("n", "zh", "zm") -- fold
vim.keymap.set("n", "zl", "zr") -- expand

-- mouse
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

-- commands
-- vim.keymap.set("n", "<c-s>", ":keepjumps normal! mz{j:<c-u>'{+1,'}-1sort<cr>`z", { silent = true })
-- vim.keymap.set("n", "<f12>", require("util").random_colorscheme)
-- vim.keymap.set("n", "<leader><tab>", ":set list!<cr>")
-- vim.keymap.set("n", "<leader>T", ":tabe " .. vim.fn.expand("%:p:h")) -- expanded only once!
-- vim.keymap.set("n", "cp", ":colo<cr>")
-- vim.keymap.set("n", "cr", require("util").random_colorscheme)
vim.keymap.set("n", "<c-s>", "mz{j:<c-u>'{+1,'}-1sort<cr>`z", { silent = true }) -- vim's sort n is not at all like !sort -V
vim.keymap.set("n", "<leader>D", [[:g/\v/d<Left><Left>]])
vim.keymap.set("n", "<leader>U", ":exec 'undo' undotree()['seq_last']<cr>") -- remove all undos -- https://stackoverflow.com/a/47524696
vim.keymap.set("n", "<leader>n", [[:%g/\v/norm <Left><Left><Left><Left><Left><Left>]])
vim.keymap.set("n", "<leader>r", [[:%s/\v/g<Left><Left>]]) -- TODO: % -> g/PATT/
vim.keymap.set("n", "<s-tab>", ":set list!<cr>")
vim.keymap.set("n", "<tab><tab>", ":set list!<cr>")
vim.keymap.set("v", "D", [[:g/\v/d<Left><Left>]]) -- delete lines
vim.keymap.set("v", "n", [[:g/\v/norm <Left><Left><Left><Left><Left><Left>]])
vim.keymap.set("v", "r", [[:s/\v/g<Left><Left>]])

vim.keymap.set("n", "<leader>h", function()
	-- inlay hints lead to -a lot- of clutter (esp in rust), so they should not
	-- be enabled by default
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "toggle inlay hints" })

vim.keymap.set("n", "cr", function()
	require("util"):random_colorscheme()
	vim.cmd("colo")
end)

-- vim.keymap.set("n", "<leader>T", ":tabe " .. vim.fn.expand("%:p:h")) -- expands only to first opened file!

vim.keymap.set("n", "<leader>T", function()
	-- return ":tabe " .. vim.fn.expand("%:p:h") -- doesn't do anything
	require("util"):literal_keys(":tabe " .. vim.fn.expand("%:p:h"))
end)

-- context dependent binds
-- https://github.com/neovim/neovim/blob/012cfced9b5/runtime/doc/lua-guide.txt#L450

-- close window if scratch
local function update_or_close()
	if vim.fn.getcmdwintype() == ":" then -- in cmdline (e.g. q:) -- quite rare
		vim.cmd("q")
	elseif
		vim.bo.buftype == "nofile" -- scratch split
		or vim.bo.buftype == "help"
	then
		vim.cmd.bd()
	else
		-- expr must be false, else 'not allowed to change text'
		vim.cmd("silent update") -- see also: shortmess
	end
end

vim.keymap.set("n", "<cr>", update_or_close, { silent = true })
vim.keymap.set("n", "x", '"_x', { silent = true })

-- niche
vim.keymap.set("i", "<c-y>", "<esc>lyBgi") -- yank current word without moving, useful only for note taking
vim.keymap.set("n", "<leader>I", [[:lua print(vim.inspect())<left><left>]])
vim.keymap.set("n", "<leader>M", '"qp0dd') -- dump q buffer into a newline and cut it (for binding)
vim.keymap.set("n", "<leader>y", [[:let @a=''<bar>g/\v/yank A<left><left><left><left><left><left><left>]]) -- yank lines containing
vim.keymap.set("n", "z/", "ZZ") -- lazy exit

-- substitutions are applied in sequential order
---@param subs { pat: string, rep: string }[]
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

		bash = 'echo "$@"',
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

-- mode: string|string[], lhs: string, rhs: string|function, opts?: vim.keymap.set.Opts

-- TODO: move out to separate file (almost 400 lines!)
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

		-- {
		-- 	"n",
		-- 	")",
		-- 	function()
		-- 		if require("dbee").is_open() then
		-- 			-- TODO: wrap page
		-- 			require("dbee").api.ui.result_page_next()
		-- 		else
		-- 			-- api.nvim_input and cmd.norm are recursive (cmd.norm at least errors noisily)
		-- 			vim.api.nvim_feedkeys(")", "n", false)
		-- 		end
		-- 	end,
		-- },
		-- {
		-- 	"n",
		-- 	"(",
		-- 	function()
		-- 		if require("dbee").is_open() then
		-- 			require("dbee").api.ui.result_page_prev()
		-- 		else
		-- 			vim.api.nvim_feedkeys("(", "n", false)
		-- 		end
		-- 	end,
		-- },
		-- { "n", "<leader>dc", require("pickers").dbee_connections },

		{ "n", "<leader>H", require("pickers").devdocs },
	},

	["qf,help,man,lspinfo,startuptime,Trouble,lazy"] = {
		{ "n", "q", "ZZ" },
		{ "n", "x", "ZZ" },
		{ "n", "<esc>", "ZZ" },
	},

	["sh,bash"] = {
		{ "n", "<bar>", ":.s/ <bar> / <bar>\\r/g|w<cr>" },
		{ "n", "<leader>H", [[:.s/\v -H/ \\\r&/g|w<cr>]] },
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

					-- %s/\vexpect\((.+) instanceof ([^)]+)\)\.toBe\(true\)/expectTypeOf(\1).toBe\2()/g

					-- within ava
					-- %s/\vtrue\((\S+) !\= null\)/truthy(\1)/g
					-- %s/\vtrue\((\S+) \=\= null\)/falsy(\1)/g
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

		{
			"n",
			"<leader>:",
			[[:'{+2,'}s/\v\t+(\w+).+/\1: foo.\1,/g<cr>]], -- struct def -> struct instantiation
		},

		{ "n", "<leader>B", ":!go build -x<cr>" },
		{ "n", "<leader>C", ":.s/\vif([^{]+)/case \1:/g<cr>" },

		{
			"n",
			"<leader>E",
			-- TODO: could be BufWritePost autocmd...
			function() -- handle error
				-- https://youtube.com/watch?v=fIp-cWEHaCk&t=1437

				local lnum = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
				local curr_line = vim.fn.getline(lnum)

				-- note: lua has no 'word boundary' pattern
				-- https://stackoverflow.com/a/6192354
				if not vim.fn.getline("."):match("err") then
					print("no err")
					return
				end

				local next_line = vim.fn.getline(lnum + 1)
				lnum = lnum - 1 -- adjust for 0-indexing

				local err_check = "if %.*err [!=]= nil"
				if curr_line:match(err_check) then
					print("err already handled")
					return
				elseif next_line:match(err_check) then -- merge err decl and err check
					vim.api.nvim_buf_set_lines(0, lnum, lnum + 2, false, { -- 0-indexed, [start,end)
						string.format("if %s; err!= nil {", curr_line), -- TODO: reuse [!=]=
					})
				else
					vim.api.nvim_buf_set_lines(0, lnum + 1, lnum + 1, false, { "if err!=nil{panic(err)}" })
				end

				vim.cmd.w()
			end,
		},

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
	},

	["go.sqlc"] = {
		{
			"n",
			"<leader>t",
			function()
				local base = vim.fn.expand("%:t:r")
				local sql = require("util"):get_command_output(string.format("git ls-files | grep -m1 /%s$"), base)
				-- tabdrop (see c header switch?)
				print(sql)
			end,
		},
	},

	python = {
		{
			"n",
			"<leader>d",
			function() -- toggle ruff
				local ruff_active = require("lint").linters_by_ft.python ~= {}
				if ruff_active then
					require("lint").linters_by_ft.python = {}
					vim.diagnostic.reset(nil, 0)
					print("disabled ruff")
				else
					require("lint").linters_by_ft.python = { "ruff" }
					require("lint").try_lint()
					print("enabled ruff")
				end
				vim.cmd("e") -- force lsp to reload
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

		{
			"n",
			"(",
			function()
				-- require("markdown.nav").next_heading() -- tadmccorkle/markdown.nvim
				vim.fn.search("^#", "Wb")
				vim.cmd.norm("zz")
			end,
			{ remap = true },
		},

		{
			"n",
			")", -- K will override this
			function()
				vim.fn.search("^#", "W")
				vim.cmd.norm("zz")
			end,
			{ remap = true },
		},

		{ "n", "<c-k>", "ysiw]Ea()<esc>Pgqq", { remap = true } }, -- wrap in hyperlink

		{
			"n",
			"<leader>d",
			function()
				-- only disables inlay hints; popups (and trouble) remain
				if vim.diagnostic.is_enabled() then
					vim.diagnostic.enable(false)
					vim.diagnostic.hide()
				else
					vim.diagnostic.enable(true)
					vim.diagnostic.show()
				end
			end,
		},

		{
			"n",
			"<leader>s",
			function()
				-- 'plain' require('foo').func requires 'foo' to be available at definition time
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
			"-ftime-trace", -- dump compilation profile to <file>.json (https://github.com/aras-p/ClangBuildAnalyzer, ninjatracing)
			-- "-fbounds-safety", -- 21.0: https://clang.llvm.org/docs/BoundsSafetyAdoptionGuide.html
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
			-- "-ftime-report", -- not as good as -ftime-trace https://stackoverflow.com/a/77319664
		},
	}

	local cmd = "gcc"
	return cmd .. " " .. table.concat(cmds[cmd], " ")
end -- }}}

-- run current file and dump stdout to scratch buffer
local function exec() -- {{{
	local ft = vim.bo.filetype
	if ft == "nofile" or ft == "" then
		return
	end

	local curr_file = vim.fn.expand("%:p")
	curr_file = vim.fn.shellescape(curr_file)
	local cwd = vim.fn.getcwd() -- only for go

	---@type {[string]: string|function}
	local runners = {

		-- the great langs
		gleam = "gleam run",
		rust = "RUST_BACKTRACE=1 cargo run", -- TODO: if vim.fn.line(".") >= line num of first match of '#[cfg(test)]', run 'cargo test' instead

		-- jq = string.format("jq -f %s %s", curr_file, curr_file:gsub(".jq", ".json")),
		-- jsonl = "jq -r < " .. curr_file, -- -f just waits for stdin for some reason
		-- lua = "luafile " .. curr_file,
		-- the normal langs
		d = "dmd -run " .. curr_file,
		dhall = "dhall-to-json --file " .. curr_file,
		elixir = "elixir " .. curr_file, -- note: time elixir -e "" takes 170 ms lol
		elvish = "elvish " .. curr_file,
		haskell = "runghc " .. curr_file,
		html = "firefox " .. curr_file,
		javascript = "node " .. curr_file,
		kotlin = "kotlinc -script " .. curr_file, -- extremely slow due to jvm (2.5 s for noop?!)
		ocaml = "ocaml " .. curr_file,
		ruby = "ruby " .. curr_file,
		sh = "env bash " .. curr_file,
		zig = "zig run " .. curr_file,

		-- the iffy langs

		sql = function()
			return string.format(
				[[psql %s --expanded --file='%s']],
				assert(require("util"):sql_connections().work, "POSTGRES_URL not set"),
				curr_file
			)
		end,

		-- note that :new brings us to repo root (verify with :new|pwd), so we need
		-- to not only know where we used to be, but also run the basename.go
		-- correctly
		go = string.format(
			-- inexplicably, go run may sometimes not write to stdout from within
			-- nvim shell. this might just be an ubuntu problem?
			-- [[ cd %s; go run ./*.go 2>&1 | sponge /dev/stdout ]],
			[[ cd %s; go run ./*.go 2>&1 ]],
			cwd
		),
		-- .. "ls *.go | " -- import functions from same package; https://stackoverflow.com/a/43953582
		-- .. "grep -v _test | " -- ignore test files (ugh)
		-- .. "xargs go run",

		python = function()
			-- local root = require("util"):root_directory()
			local cmd
			if vim.fn.executable("uv") and require("util"):buf_contains("# /// script") then
				-- ~/.cache/uv
				cmd = "uv run "
			-- elseif root and vim.uv.fs_stat(root .. "/pyproject.toml") then
			elseif vim.fs.root(0, "pyproject.toml") then
				-- vim.uv.fs_stat(require("util"):root_directory() .. ".venv")
				-- poetry install -vv
				cmd = "poetry run python3 "
			else
				cmd = "python3 "
			end
			return cmd .. curr_file
		end,

		-- local js = vim.fn.fnamemodify(curr_file, ":r") .. ".js"
		typescript = function()
			-- cd first, so that child's node_modules/tsx can be found
			-- this assumes that node_modules and file.ts are at the same level
			vim.fn.chdir(vim.fn.expand("%:p:h")) -- abs dirname (:h %:p)
			-- local ts = vim.fn.expand("%:.") -- relative to child dir

			-- if vim.uv.fs_stat(".env") and vim.fn.executable("node23") then
			-- 	return "node23 --no-warnings --import=tsx --env-file=.env " .. file

			-- TODO: must use tsx if any file imports are needed; node imports must
			-- specify file ext (fixable at top-level imports, but not at subsequent
			-- imports)

			local node_version = require("util"):get_command_output("node -v")
			if node_version >= "v22.7.0" then -- 2x faster than tsx, but not guaranteed to work
				-- https://nodejs.org/en/learn/typescript/run-natively#running-typescript-natively
				return "node --no-warnings --experimental-strip-types --experimental-transform-types " .. curr_file
			elseif node_version >= "v22.6.0" then
				return "node --no-warnings --experimental-strip-types " .. curr_file
			elseif vim.uv.fs_stat("./node_modules/tsx") then
				-- run with node directly (without transpilation); requires tsx
				-- https://nodejs.org/api/typescript.html#full-typescript-support
				-- --enable-source-maps doesn't seem to report source line number correctly
				-- node --import=tsx is significantly faster than yarn tsx (avoids unnecessary overhead)
				return "node --no-warnings --import=tsx " .. curr_file
			elseif vim.fs.root(0, "package.json") then
				-- TODO: print is shown after execute
				-- print("installing tsx...") -- ts-node is not just single binary
				-- npm install --save-dev tsx
				-- os.execute("yarn add --dev tsx >/dev/null")
				error("need install tsx")
				-- vim.fn.jobstart("yarn add --dev tsx") -- possibly bad recursion, high memory
				-- return get_ts_runner(file)
			else
				error("no package.json found; need npm init")
			end
		end, --(curr_file),

		["javascript.mongo"] = string.format(
			-- -f FILE requires FILE to be mongosh (not js)
			[[mongosh %s --authenticationDatabase admin --quiet --eval < %s | sed -r 's/^\S+>[ .]*//g']],
			-- .. [[ | node --eval "console.log(JSON.stringify($(< /dev/stdin)))" | jq]],
			vim.env.MONGO_URL,
			curr_file
		),

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
		cpp = (function()
			local base = vim.fn.fnamemodify(curr_file, ":r") .. ".cpp"

			if vim.uv.fs_stat("Makefile") then
				return string.format([[ make && ./%s ]], base)
			end

			return string.format([[ time g++ %s -O0 -o %s && ./%s ]], curr_file, base, base)
		end)(),
	}

	local runner = runners[ft]
	if not runner then
		print("No runner configured for " .. ft)
		return
	elseif type(runner) == "function" then
		runner = runner(curr_file)
	end

	require("util"):close_unnamed_splits()

	-- TODO: async (Dispatch)
	local front = "new | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! "

	-- split dimensions -must- be declared in the [v]new command. attempting to
	-- shrink a main split will not enlarge the secondary split!

	local wide, ratio = is_wide()
	front = ratio .. (wide and "v" or "") .. front

	-- if true then
	-- 	print(front .. runner)
	-- 	return
	-- end

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

local function test()
	local ft = vim.bo.filetype
	if ft == "nofile" then
		return
	end

	-- TODO: if ./Makefile detected, close all Dispatch tabs, prompt for test,
	-- then call Dispatch

	local watchers = {

		go = [[bash -c "find . -name '*.go' | entr -cr go test ./..."]],
		python = [[bash -c "find . -name '*.py' | entr -cr poetry run pytest -x -vv"]],
		rust = "cargo watch -x check -x test",
	}

	local watcher = watchers[ft]

	if watcher == nil then
		print("No test runner configured for " .. ft)
		return
	end

	-- TODO: consider using Dispatch instead
	local cmd = string.format("wezterm start --cwd=. %s 2>/dev/null", watcher)
	-- print(cmd)
	os.execute(cmd)
end
vim.keymap.set("n", "<leader>w", test, { silent = true })
