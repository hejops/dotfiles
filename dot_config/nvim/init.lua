-- TODO: root_pattern for lua; set root to .config/nvim?
-- structuring: see https://github.com/arnvald/viml-to-lua

require("util")

require("autocmds")
require("binds")
require("sets")

require("plugins")

-- plugin autocmds {{{

-- format before write, lint after write
-- do both on startup

vim.api.nvim_create_autocmd({
	"BufWritePre",
	-- "VimEnter", -- triggers erroneously on Lazy init (i.e auto-install new plugin)
	"BufReadPost",
}, {
	callback = function()
		require("conform").format()
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.sql" },
	callback = function()
		-- quite slow
		vim.cmd("silent! !sqlfluff fix --dialect sqlite \z
		--exclude-rules L028 %")
		-- vim.fn.jobstart("sqlfluff fix --dialect sqlite %")
	end,
})

-- trying to make vil files pretend to be json causes problems with both
-- prettier and biome
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.vil" },
	callback = function()
		vim.cmd([[silent! !cat % | jq | sponge %]])
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "VimEnter" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		-- must be called after any colorscheme change (i.e. not ColorSchemePre)
		-- on change, current line will not have marks, but this is not an issue
		-- if you're really picky, you could do a normal mode hl or whatever
		require("eyeliner").setup({ highlight_on_key = false }) -- always show highlights, without keypress
		vim.api.nvim_set_hl(0, "EyelinerPrimary", { underline = true })
		vim.api.nvim_set_hl(0, "EyelinerSecondary", { underline = true })

		-- enforce hl colorcolumn (citruszest unsets it)
		-- $HOME/.local/share/nvim/lazy/citruszest.nvim/lua/citruszest/highlights/init.lua:29
		-- 8:    ColorColumn = { bg = C.none }, -- used for the columns set with 'colorcolumn'
		-- TODO: should follow lualine main color
		vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#444444" })

		-- enforce diff colors
		local green = "#00CC7A"
		local red = "#FF5454"
		-- https://github.com/neovim/neovim/blob/b3109084c2c3675aa886bf16ff15f50025f30096/runtime/doc/treesitter.txt#L459
		vim.api.nvim_set_hl(0, "@diff.plus", { fg = green })
		vim.api.nvim_set_hl(0, "@diff.minus", { fg = red })
	end,
})

-- tectonic integration in vimtex is pretty poor

-- if vim.loop.fs_stat("Tectonic.toml") then
-- 	-- https://github.com/IndianBoy42/LunarVim/blob/170df925da72f617d70326b28e558502a67f1003/lua/lv-vimtex/init.lua#L12
-- 	vim.g.vimtex_compiler_tectonic = {
-- 		["options"] = { "--synctex", "--keep-logs" },
-- 	}
-- 	vim.g.vimtex_compiler_generic = { cmd = "watchexec -e tex -- tectonic --synctex --keep-logs *.tex" }
-- 	vim.g.vimtex_compiler_method = "tectonic"
-- 	-- vim.g.vimtex_view_method = "skim"
-- end

-- hacked together from exec
local function tectonic_build() -- {{{
	require("util"):close_unnamed_splits()

	-- tectonic build is slow, and should always be started in background
	vim.fn.jobstart([[
tectonic -X build 2>&1 > ./src/tectonic.log ;
lsof ./build/default/default.pdf > /dev/null 2> /dev/null || zathura ./build/default/default.pdf 2> /dev/null &
]])

	-- TODO: ensure file reloaded after build finish (currently, loads only log
	-- of previous build due to async jobstart)
	require("util"):open_split("./src/tectonic.log")
end -- }}}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.tex" },
	callback = function()
		-- relies on correct project path
		if vim.loop.fs_stat("Tectonic.toml") then
			tectonic_build()
			-- elseif in_tex() then
			-- 	vim.cmd("VimtexCompile")
			-- 	vim.cmd("VimtexClean")
		end
	end,
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = {
		"*.tex",
		-- "*.cls",
	},
	callback = function()
		if vim.loop.fs_stat("Tectonic.toml") then
			tectonic_build()
			-- elseif in_tex() then
			-- 	vim.cmd("VimtexCompile")
			-- 	vim.cmd("VimtexClean")
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.ly" },
	callback = function()
		require("util"):close_unnamed_splits()
		vim.cmd(
			vim.o.lines * 0.2
				.. " new | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! "
				.. string.format("lilypond %s 2>&1", vim.fn.expand("%"))
		)
	end,
})

-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "LazyVimStarted",
-- 	command = "lua require('lazy').sync({ show = false })",
-- 	desc = "Sync plugins",
-- })

-- https://github.com/folke/lazy.nvim/issues/1200#issuecomment-1867407116
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyCheck",
	-- pattern = "LazyVimStarted",
	desc = "Update lazy.nvim plugins",
	callback = function(event)
		-- local start_time = os.clock()
		require("lazy").sync({ wait = false, show = false })
		-- local end_time = os.clock()
		-- print("Lazy plugins synced in " .. (end_time - start_time) * 1000 .. "ms")
		-- print(vim.print(event))
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GitConflictDetected",
	callback = function()
		-- engage.conflict_buster()
		vim.notify("Conflict(s) detected in " .. vim.fn.expand("<afile>"))
		-- vim.o.foldenable = false

		vim.cmd("LspStop")
		vim.diagnostic.enable(false)
		-- vim.treesitter.stop()

		vim.cmd("norm gg")
		vim.cmd("GitConflictNextConflict")

		-- -- https://github.com/wochap/nvim/blob/60920de61ae887f04994a4f253e19c0494d33023/lua/custom/custom-plugins/configs/git-conflict.lua#L4
		-- vim.keymap.set("n", "[c", "<cmd>GitConflictPrevConflict<CR>|zz")
		-- vim.keymap.set("n", "]c", "<cmd>GitConflictNextConflict<CR>|zz")
		-- vim.keymap.set("n", "cq", "<cmd>GitConflictListQf<CR>")
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GitConflictResolved",
	callback = function()
		vim.notify("Conflict(s) resolved")
		vim.cmd("LspRestart")
		vim.diagnostic.enable()
	end,
})

vim.api.nvim_create_autocmd("TabLeave", {
	callback = function()
		vim.g.lasttab = vim.fn.tabpagenr()
	end,
})

-- https://github.com/xvzc/chezmoi.nvim?tab=readme-ov-file#treat-all-files-in-chezmoi-source-directory-as-chezmoi-files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	-- dot* excludes .git/*
	pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/dot*" },
	callback = function(ev)
		vim.schedule(function()
			require("chezmoi.commands.__edit").watch(ev.buf)
		end)
		-- print("chezmoi watching")
	end,
})

-- }}}
-- plugin binds {{{

-- vim.keymap.set("n", "<leader>gB", ":GitBlameToggle<cr>") -- must be explicitly enabled on mac (due to lacking horizontal space)
vim.keymap.set("n", "<leader>J", ":TSJToggle<cr>")
vim.keymap.set("n", "<leader>gB", ":BlameToggle<cr>")
vim.keymap.set("n", "<leader>gS", ":Gitsigns stage_buffer<cr>")
vim.keymap.set("n", "<leader>gh", ":Gitsigns stage_hunk<cr>") -- more ergonomic than gs, but my muscle memory goes to gs
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<cr>")

vim.keymap.set("n", "<leader>gb", function()
	-- vim.cmd("GitBlameOpenCommitURL") -- GitBlameOpenFileURL may produce bogus URLs (usually when files are moved), and going to the commit provides better context anyway
	-- https://github.com/f-person/git-blame.nvim/issues/103
	-- ubuntu xdg-open doesn't work
	vim.cmd("GitBlameCopyCommitURL")
	vim.fn.jobstart('sleep 0.5 ; xdg-open "$(xclip -o -sel c)" || firefox "$(xclip -o -sel c)"')
end)

vim.keymap.set("v", "gs", ":Gitsigns stage_hunk<cr>")

-- https://github.com/ThePrimeagen/refactoring.nvim#configuration-for-refactoring-operations
-- https://github.com/kentchiu/nvim-config/blob/d60768f59bfee285a26f24a3879f6b155a1c630c/lua/custom/plugins/refactory.lua#L11

vim.keymap.set({ "n", "x" }, "<leader>R", function()
	-- https://github.com/ThePrimeagen/refactoring.nvim/issues/270#issuecomment-1071037162
	-- require("telescope").extensions.refactoring.refactors({ initial_mode = "normal" })
	require("refactoring").select_refactor({ show_success_message = true })
end, {
	noremap = true,
	desc = "refactor menu",
})

-- nmap r = tab prefix
-- nmap R = rename
-- vmap r = substitute
-- vmap R = redundant with c

-- inlines actually increase code repetition, not sure when this would be desirable
vim.keymap.set("n", "rfI", ":Refactor inline_func")
vim.keymap.set("n", "rfi", ":Refactor inline_var")
vim.keymap.set("x", "Rfi", ":Refactor inline_var")

vim.keymap.set("n", "rfb", ":Refactor extract_block") -- rename current block (usually func)
vim.keymap.set("n", "rfbf", ":Refactor extract_block_to_file")
vim.keymap.set("x", "Rfe", ":Refactor extract ") -- places refactored func at top, which is less than ideal
vim.keymap.set("x", "Rff", ":Refactor extract_to_file ") -- does not update existing imports of the func; https://github.com/ThePrimeagen/refactoring.nvim/issues/426#issuecomment-1808512168
vim.keymap.set("x", "Rfv", ":Refactor extract_var ")

-- You can also use below = true here to to change the position of the printf
-- statement (or set two remaps for either one). This remap must be made in normal mode.
vim.keymap.set("n", "<leader>Rp", function()
	require("refactoring").debug.printf({ below = true, show_success_message = true })
end, { desc = "refactor printf" })

vim.keymap.set({ "x", "n" }, "<leader>Rv", function()
	require("refactoring").debug.print_var({ show_success_message = true })
end, { desc = "refactor print var" })

vim.keymap.set("n", "<leader>Rc", function()
	-- Supports only normal mode
	require("refactoring").debug.cleanup({ show_success_message = true })
end, { desc = "refactor cleanup" })

-- unlike telescope diagnostics, trouble is persistent (per tab)
vim.keymap.set("n", "<leader>j", function()
	require("trouble").open({ mode = "diagnostics" })
	require("trouble").next({ skip_groups = true, jump = true })
	-- require("trouble").close() -- causes every other invocation to error
	-- if require("trouble").is_open() then
	-- 	-- trouble can jump across files, vim.diagnostic can't
	-- 	require("trouble").next({ skip_groups = true, jump = true })
	-- else
	-- 	vim.diagnostic.goto_next()
	-- end
end, { desc = "next diagnostic message" })

vim.keymap.set("n", "<leader>k", function()
	require("trouble").open({ mode = "diagnostics" })
	require("trouble").prev({ skip_groups = true, jump = true })
end, { desc = "previous diagnostic message" })

vim.keymap.set("n", "<leader>l", function()
	require("trouble").toggle({ mode = "diagnostics", focus = true })
end)

-- google_docstrings
-- https://github.com/danymat/neogen#supported-languages
require("neogen").setup({ snippet_engine = "luasnip" })
vim.keymap.set("n", "<leader>nf", require("neogen").generate, { noremap = true, silent = true })

-- }}}
-- navigator: telescope {{{

-- must be declared after loading plugins
local telescope = require("telescope")
local telescope_b = require("telescope.builtin")

local telescope_actions = require("telescope.actions")

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- mostly to avoid find from mac home
		if vim.fn.argv(0) == "" and require("util").in_git_repo() and vim.bo.filetype ~= "man" then
			telescope_b.find_files()
		end
	end,
})

telescope.setup({

	-- :h telescope.defaults
	defaults = {

		-- https://github.com/nvim-telescope/telescope.nvim/blob/24778fd72fcf39a0b1a6f7c6f4c4e01fef6359a2/lua/telescope/config.lua#L144

		border = true, -- if false, all text is disabled!
		dynamic_preview_title = true, -- useful, since you don't have to look away from the right pane
		layout_config = { preview_cutoff = 0 },
		layout_strategy = require("util").get_layout_strategy(),
		prompt_title = false, -- this is almost always overridden anyway
		results_title = false,
		sorting_strategy = "descending", -- closest match on bottom (near prompt)
		wrap_results = true, -- doesn't apply to diagnostics; use line_width (below)

		preview = {
			-- msg_bg_fillchar = "╱",
			msg_bg_fillchar = "",
			-- borderchars = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
		},

		mappings = {

			-- https://github.com/SpaceVim/SpaceVim/blob/b462646223dfb8a7b19fb3999edffd4d0dd8aea1/bundle/telescope.nvim/lua/telescope/mappings.lua#L133
			-- https://github.com/nvim-telescope/telescope.nvim/blob/24778fd72fcf39a0b1a6f7c6f4c4e01fef6359a2/doc/telescope.txt#L2617
			i = {

				-- ["<c-i>"] = telescope_actions.preview_scrolling_up,
				-- ["<c-s-t>"] = require("trouble.sources.telescope").open(),
				-- ["<c-s-t>"] = telescope_trouble.open_with_trouble,
				-- ["<c-s>"] = telescope_actions.select_horizontal, -- open in horiz split
				-- ["<c-u>"] = telescope_actions.preview_scrolling_down,
				-- ["<c-x>"] = require("telescope.actions.layout").toggle_prompt_position,
				["<c-b>"] = telescope_actions.preview_scrolling_up,
				["<c-c>"] = telescope_actions.close,
				["<c-f>"] = telescope_actions.preview_scrolling_down,
				["<c-j>"] = telescope_actions.move_selection_next,
				["<c-k>"] = telescope_actions.move_selection_previous,
				["<c-p>"] = require("telescope.actions.layout").toggle_preview,
				["<c-t>"] = require("telescope.actions.layout").cycle_layout_next, -- TODO: why must input twice?
				["<cr>"] = telescope_actions.select_tab_drop, -- reuse tab, if buffer already open
				["<esc>"] = telescope_actions.close,

				-- ["<c-l>"] = function() -- ???
				-- 	vim.cmd("normal E")
				-- end,
			},

			n = {

				-- ["t"] = require("trouble.sources.telescope").open(),
				-- ["t"] = telescope_trouble.open_with_trouble,
				["<c-c>"] = telescope_actions.close,
				["<c-s>"] = telescope_actions.select_horizontal,
				["<cr>"] = telescope_actions.select_tab_drop,
			},
		},
	},

	-- https://github.com/RobinTruax/resolution/blob/63cbc5a50eee8df039f54e593ed377f04e60e583/lua/plugins/telescope/picker_opts.lua#L20

	-- :h telescope.builtin
	pickers = {

		colorscheme = { enable_preview = true },
		find_files = { prompt_title = "find" },
		git_branches = { show_remote_tracking_branches = false },
		live_grep = { prompt_title = "ripgrep" },
		lsp_definitions = { show_line = false },
		lsp_document_symbols = { path_display = "hidden", show_line = false },
		lsp_dynamic_workspace_symbols = { show_line = false },
		lsp_implementations = { show_line = false },
		lsp_incoming_calls = { show_line = false },
		lsp_outgoing_calls = { show_line = false },
		lsp_references = { show_line = false },
		lsp_type_definitions = { show_line = false },
		lsp_workspace_symbols = { show_line = false },

		--   -- use trouble instead
		-- diagnostics = {
		-- 	-- :h telescope.builtin.diagnostics()
		-- 	-- disable_coordinates = true,
		-- 	line_width = "full", -- important
		-- },
	},

	extensions = {

		-- -- makes code_action unusable
		-- -- waiting on https://github.com/nvim-telescope/telescope-ui-select.nvim/issues/44
		-- ["ui-select"] = {
		-- 	require("telescope.themes").get_dropdown(
		-- 		--
		-- 		-- { initial_mode = "normal" }
		-- 	),
		-- 	-- layout_config = { width = 0.4, height = 16 },
		-- },

		heading = {
			-- TODO: sort normal
			treesitter = true,
			picker_opts = {
				-- layout_config = { width = 0.8, preview_width = 0.5 },
				layout_strategy = require("util").get_layout_strategy(),
				sorting_strategy = "ascending",
			},
		},
		file_browser = {

			initial_mode = "normal",
			cwd_to_path = true,
			-- path = vim.fn.expand("%:p:h"),
			path = "%:p:h",
		},
	},
})

-- extensions must be loaded after `telescope.setup`
-- pcall(telescope.load_extension, "fzf") -- enable telescope fzf native, if installed
-- telescope.load_extension("ui-select")
-- telescope.load_extension("undo")
telescope.load_extension("file_browser")
telescope.load_extension("heading")

-- }}}
-- telescope binds {{{

-- local function merge_tables(self, other)
-- 	for k, v in pairs(other) do
-- 		self[k] = v
-- 	end
-- 	return self
-- end

vim.api.nvim_create_autocmd({ "VimEnter", "VimResized" }, {
	callback = function()
		require("telescope").setup({
			defaults = { layout_strategy = require("util").get_layout_strategy() },
		})
	end,
})

-- telescope.treesitter is less useful than telescope_b.lsp_*_symbols
-- vim.keymap.set("n", "<leader>E", telescope.extensions.chezmoi.find_files, { desc = "chezmoi" }) -- i have never used this
-- vim.keymap.set("n", "<leader>F", telescope.extensions.file_browser.file_browser) -- ls-like, usually annoying to use
-- vim.keymap.set("n", "<leader>F", telescope.oldfiles, { desc = "recently opened files" })
-- vim.keymap.set("n", "<leader>z", telescope_b.current_buffer_fuzzy_find, { desc = "grep" }) -- current buf, pre-loaded, rarely used
vim.keymap.set("n", "<leader>.", telescope.extensions.adjacent.adjacent)
vim.keymap.set("n", "<leader>/", telescope_b.live_grep, { desc = "ripgrep" }) -- entire project
vim.keymap.set("n", "<leader>?", telescope_b.keymaps, { desc = "keymaps" })
vim.keymap.set("n", "<leader>b", telescope_b.buffers, { desc = "open buffers" })
vim.keymap.set("n", "<leader>e", telescope_b.git_files, { desc = "git ls-files" })
vim.keymap.set("n", "<leader>f", telescope_b.find_files, { desc = "find" })
vim.keymap.set("n", "<leader>t", telescope.extensions["telescope-tabs"].list_tabs)

-- vim.keymap.set("n", "<leader>gC", telescope_b.git_bcommits, { desc = "git commits" })
-- vim.keymap.set("n", "<leader>gS", telescope_b.git_status, { desc = "git status" }) -- like git ls-files with diff
-- vim.keymap.set("n", "<leader>gb", telescope_b.git_branches, { desc = "git branches" }) -- generally better to switch branches in shell, due to annoying checkout hooks
vim.keymap.set("n", "<leader>gC", telescope_b.git_commits, { desc = "git commits" }) -- like :Gclog but better

-- vim.keymap.set("n", "<leader>?", telescope_b.help_tags, { desc = "search help" }) -- let's face it; i never use this
-- vim.keymap.set("n", "<leader>u", telescope.extensions.undo.undo)

vim.keymap.set("n", "<leader>h", function()
	-- inlay hints lead to -a lot- of clutter (esp in rust), so they should not
	-- be enabled by default
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "toggle inlay hints" })

-- buffer-specific LSP keymaps
local function on_attach(_, bufnr)
	local function nmap(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	require("tiny-code-action").setup()
	nmap("<leader>A", require("tiny-code-action").code_action)
	nmap("<leader>s", telescope_b.lsp_dynamic_workspace_symbols, "document symbols") -- all project files; slow in python?
	nmap("K", vim.lsp.buf.hover, "hover documentation")
	nmap("R", vim.lsp.buf.rename, "rename")

	nmap("<leader>i", function()
		-- vim.lsp.buf.references() -- tui.go|43 col 15| func (p Post) saveImage(subj string) error {
		-- vim.lsp.buf.incoming_calls() -- tui.go|385 col 19| Update

		local function get_bufnr(fname)
			for _, bn in pairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_get_name(bn) == fname then
					return bn
				end
			end
		end

		-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#entry-maker
		-- https://github.com/yuepaang/dotfiles/blob/5272e1aef2b0255535d7f575d9a5e32cd75e2cd8/nvim/lua/doodleVim/extend/lsp.lua#L3
		local function entry_maker(entry)
			local function make_display()
				return require("telescope.pickers.entry_display").create({
					separator = " ",
					items = {
						{ width = 0.1 },
						{ width = 6 },
						{ width = 0.1 },
						{ remaining = true },
					},
				})({
					require("telescope.utils").transform_path({}, entry.filename),
					{ entry.lnum, "TelescopeResultsLineNr" },
					entry.text,
					-- file at line; only correct if buffer loaded, otherwise reads from current buf
					vim.api.nvim_buf_get_lines(get_bufnr(entry.filename) or nil, entry.lnum - 1, entry.lnum, false),
				})
			end

			return {

				-- ordinal = (not opts.ignore_filename and filename or "") .. " " .. entry.text,
				-- ordinal = string.format("%s %s", entry.file, entry.preview),
				display = make_display,
				filename = entry.filename, -- or vim.api.nvim_buf_get_name(entry.bufnr),
				ordinal = entry.text,
				value = entry,

				-- these are for the preview
				bufnr = entry.bufnr,
				col = entry.col,
				finish = entry.finish,
				lnum = entry.lnum,
				start = entry.start,
				text = entry.text,
				valid = true,
			}
		end

		telescope_b.lsp_incoming_calls({ -- tui.go:385:19:Update
			-- contrary to the name, show_line only shows the name of the parent func
			-- (...:parent), but not the actual line itself. Trouble doesn't show the
			-- line either (and i don't like using trouble anyway)
			show_line = true,
			entry_maker = entry_maker,
		})
	end, "incoming calls")

	nmap("<leader>S", function()
		-- TS has no project-wide scope, too bad
		require("telescope.builtin").treesitter({ symbols = { "method", "function", "type" } })
	end, "treesitter functions")

	-- nmap("<c-k>", vim.lsp.buf.signature_help, "signature documentation") -- != buf.hover! see: https://github.com/neovim/neovim/discussions/25711#discussioncomment-7323330
	-- nmap("<leader>S", telescope_b.lsp_document_symbols, "document symbols") -- pre-loaded, curr buf only (almost never used)
	-- nmap("<leader>d", vim.lsp.buf.type_definition, "type definition")
	-- nmap("<leader>o", telescope_b.lsp_outgoing_calls, "outgoing calls") -- what does this call? less useful; think of this like goto def, but preview
	-- nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "workspace add folder")
	-- nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "workspace remove folder")
	-- nmap("gI", vim.lsp.buf.implementation, "go to implementation") -- only useful for langs where def and impl can be separate (e.g. TS)
	-- nmap("gd", vim.lsp.buf.declaration, "goto declaration") -- != definition
	-- nmap("gr", require("telescope.builtin").lsp_references, "goto references") -- goto def, but more chaotic
	-- vim.keymap.set({ "i" }, "<c-a>", vim.lsp.buf.code_action)

	-- nmap("<leader>lw", function()
	-- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	-- end, "list workspace folders")
end

-- https://github.com/fatih/dotfiles/blob/52e459c991e1fa8125fb28d4930f13244afecd17/init.lua#L748
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev) -- goto def + tabdrop
		local opts = { buffer = ev.buf }

		-- vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)

		-- https://github.com/neovim/neovim/pull/19213
		-- https://github.com/raphapr/dotfiles/blob/ecdf9771d27bfb7b2dd4574b4d7ba092fddb2c82/home/dot_config/nvim/lua/raphapr/utils.lua#L25
		-- https://github.com/Swoogan/dotfiles/blob/ecfdf4fe539682dc710c68915fd40f6c0ca033fc/nvim/.config/nvim/lua/config/lang.lua#L63

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition({
				on_list = function(options)
					-- if #options.items > 1 then
					-- 	vim.notify("Multiple items found, opening first one", vim.log.levels.WARN)
					-- end

					-- tab drop
					-- https://github.com/Swoogan/dotfiles/blob/ecfdf4fe539682dc710c68915fd40f6c0ca033fc/nvim/.config/nvim/lua/config/lang.lua#L81
					local item = options.items[1]
					vim.cmd("tab drop " .. item.filename)
					-- vim.api.nvim_win_set_cursor(win or 0, { item.start.line + 1, item.start.character })
					vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
					vim.cmd("norm zt")
				end,
			})
		end, opts)
	end,
})

-- }}}
-- lsp handler: mason {{{

-- print(vim.fn.stdpath("data"))

local function root_directory()
	local cmd = "git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " rev-parse --show-toplevel"
	local toplevel = vim.fn.system(cmd)
	if not toplevel or #toplevel == 0 or toplevel:match("fatal") then
		return vim.fn.getcwd()
	end
	return toplevel:sub(0, -2)
end

-- https://github.com/jellydn/ts-inlay-hints?tab=readme-ov-file#neovim-settings
local js_ts_hints = {
	includeInlayEnumMemberValueHints = true,
	includeInlayFunctionLikeReturnTypeHints = true,
	includeInlayFunctionParameterTypeHints = true,
	includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
	includeInlayParameterNameHintsWhenArgumentMatchesName = true,
	includeInlayPropertyDeclarationTypeHints = true,
	includeInlayVariableTypeHints = false,
}

-- :Mason
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
-- multiple LSPs lead to strange behaviour (e.g. renaming symbol twice)
-- warning: commenting out an lsp does not uninstall it!
local servers = {

	-- https://github.com/blackbhc/nvim/blob/4ae2692403a463053a713e488cf2f3a762c583a2/lua/plugins/lspconfig.lua#L399
	-- https://github.com/oniani/dot/blob/e517c5a8dc122650522d5a4b3361e9ce9e223ef7/.config/nvim/lua/plugin.lua#L157

	bashls = {},
	clangd = {}, -- TODO: suppress (?) "Call to undeclared function"
	dockerls = {},
	marksman = {}, -- why should md ever have any concept of root_dir?
	pyright = {},
	taplo = {},
	texlab = {},
	yamlls = {},
	zls = {},

	-- https://github.com/EmilianoEmanuelSosa/nvim/blob/c0a47abd789f02eb44b7df6fefa698489f995ef4/init.lua#L129
	docker_compose_language_service = {
		root_dir = require("lspconfig").util.root_pattern("docker-compose.yml"), -- add more patterns if needed
		filetypes = { "yaml.docker-compose" },
		-- single_file_support = true,
	},

	-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
	gopls = {
		settings = {
			gopls = { -- i have absolutely no idea why gopls needs to stutter

				staticcheck = true, -- https://staticcheck.io/docs/checks/
				symbolScope = "workspace", -- don't show ~/go, /usr/lib
				usePlaceholders = false,

				hints = { -- https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
			},
		},
	},

	biome = {
		root_dir = root_directory(), -- important: use root biome.json
	},

	ts_ls = {

		-- ts_ls generally does not need to be at root, but better to be consistent
		-- with biome
		root_dir = root_directory(),

		settings = {
			javascript = { inlayHints = js_ts_hints },
			typescript = { inlayHints = js_ts_hints },

			-- note: js projects will require jsconfig.json
			diagnostics = {
				-- remove unused variable diagnostic messages from tsserver
				ignoredCodes = {
					-- the -only- place these codes are documented:
					-- https://github.com/typescript-language-server/typescript-language-server/blob/master/src/utils/errorCodes.ts
					-- note: these warnings should probably be enabled for real (production) work
					6133, -- declared but never used
					6196,
				},
			},
		},
	},

	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				-- https://rust-analyzer.github.io/manual.html#configuration
				-- https://hw0lff.github.io/rust-analyzer-docs/2021-11-01/index.html
				checkOnSave = {
					enable = true,
					allFeatures = true, -- https://rust-analyzer.github.io/manual.html#features
					command = "clippy", -- https://rust-lang.github.io/rust-clippy/master/index.html
				},
				completion = {
					addCallParenthesis = true,
					-- postfix = { enable = false },
					-- addCallArgumentSnippets = false,
				},
			},
		},
	},

	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim", "mp" },
					disable = { "missing-fields" },
				},
				telemetry = { enable = false },
				workspace = { checkThirdParty = false },
			},
		},
	},

	-- -- until further notice, i have given up trying to get ruby_lsp to work
	-- -- https://github.com/Shopify/ruby-lsp/blob/main/EDITORS.md#Neovim
	-- ruby_lsp = {},
}

local mason_lspconfig = require("mason-lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()) -- wrap default capabilities with cmp

mason_lspconfig.setup({ ensure_installed = vim.tbl_keys(servers) })

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup(vim.tbl_extend("force", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		}, servers[server_name] or {}))
	end,
})

-- note: after python update, pyright must be reinstalled
require("lspconfig").pyright.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	before_init = function(_, config) -- functions cannot be merged
		-- https://github.com/Lilja/dotfiles/blob/9fd77d2f5d55352b36054bcc7b4acc232cb99dc6/nvim/lua/plugins/lsp_init.lua#L90
		local function get_python_path(workspace) -- {{{
			local util = require("lspconfig/util")

			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return util.path.join(vim.env.VIRTUAL_ENV, "bin", "python")
			end

			if vim.fn.glob(util.path.join(workspace, "poetry.lock")) ~= "" then
				local poetry = vim.fn.trim(vim.fn.system("poetry --directory " .. workspace .. " env info -p"))
				return util.path.join(poetry, "bin", "python")
			end

			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end -- }}}

		config.settings.python.pythonPath = get_python_path(config.root_dir)
	end,
})

local diagnostics_signs = { Error = "💀", Warn = "🤔", Hint = "🤓", Info = "ⓘ" }
for type, icon in pairs(diagnostics_signs) do
	-- https://github.com/folke/trouble.nvim/issues/52#issuecomment-950044538
	-- https://github.com/folke/trouble.nvim/issues/52#issuecomment-988874117
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ensure all popups have borders for better readability
-- https://vi.stackexchange.com/a/39075
local _border = "single"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = _border,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = _border,
})

vim.diagnostic.config({
	float = {
		border = _border,
		focusable = false,
	},
})

-- }}}
-- linter: nvim-lint {{{
-- to ensure all tools (linters etc) are up-to-date, it is better to keep them
-- in /nvim/mason (rather than decentralised user-installed ones)

local linters = {

	-- https://github.com/mfussenegger/nvim-lint#available-linters
	-- note: the standard rust linter is clippy, which is part of the lsp
	bash = { "shellcheck" },
	dockerfile = { "hadolint" }, -- can be quite noisy
	gitcommit = { "gitlint" },
	go = { "golangcilint" },
	html = { "markuplint" },
	htmldjango = { "djlint" },
	javascript = { "biomejs" },
	javascriptreact = { "biomejs" },
	make = { "checkmake" },
	markdown = { "markdownlint", "proselint" },
	python = { "ruff" }, -- pylint is too slow and unreliable
	ruby = { "rubocop" },
	sql = { "sqlfluff" },
	typescript = { "biomejs" },
	typescriptreact = { "biomejs" },
}

if vim.fn["globpath"](".", "commitlint.config.js") ~= "" then
	-- npm install --save-dev @commitlint/{cli,config-conventional}
	-- echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
	table.insert(linters.gitcommit, "commitlint")
end

-- https://github.com/orumin/dotfiles/blob/62d7afe8a9bf531d1b5c8b13bbb54a55592b34b3/nvim/lua/configs/plugin/lsp/linter_config.lua#L7
require("lint").linters_by_ft = linters

-- https://github.com/rrunner/dotfiles/blob/d55d90ed5d481fc1138483f76f0970d93784bf0a/nvim/.config/nvim/lua/plugins/linting.lua#L17
require("lint").linters.ruff.args = {
	"check",
	"--select=ALL",
	"--target-version=py310", -- type hints = 39, Optional (etc) = 310
	"--ignore=" .. table.concat({

		"ERA", -- allow comments
		"I001", -- ignore import sort order (handled by isort hook)
		"PD901", -- allow var name df
		"PLR0913", -- allow >5 func args
		"PLR2004", -- allow magic constant values
		"RET504", -- allow unnecessary assignment before return statement
		"S101", -- allow assert
		"SIM108", -- don't suggest ternary
		"T201", -- allow print()
		"TD", -- allow TODO
		--
	}, ","),

	"--force-exclude",
	"--quiet",
	"--stdin-filename",
	vim.api.nvim_buf_get_name(0),
	"--no-fix", -- --fix should never be used, because it destroys undos
	"--output-format=json", -- important
	"-",
}

-- https://gist.github.com/Norbiox/652befc91ca0f90014aec34eccee27b2
-- Set pylint to work in virtualenv
-- TODO: should be project root, not '.'
if vim.fn["globpath"](".", "pyproject.toml") ~= "" then
	require("lint").linters.pylint.cmd = "poetry"
	require("lint").linters.pylint.args = { "run", "pylint", "-f", "json" }
elseif vim.fn["globpath"](".", "manage.py") ~= "" then
	require("lint").linters.pylint.cmd = "python3"
	require("lint").linters.pylint.args = {
		"-m",
		"pylint",
		"-f",
		"json",
		-- https://github.com/pylint-dev/pylint-django?tab=readme-ov-file#usage
		"--load-plugins=pylint_django", -- global install
		"--django-settings-module=tutorial.settings", -- will depend on project, obviously
	}
else
	require("lint").linters.pylint.cmd = "python3"
	require("lint").linters.pylint.args = { "-m", "pylint", "-f", "json" }
end

require("lint").linters.sqlfluff.args = {
	"lint",
	-- TODO: infer dialect (either via heuristics, or some modeline equivalent)
	"--dialect",
	"sqlite",
	"--format=json",
	"--exclude-rules",
	"layout.long_lines",

	-- note: fine-grained 'rule options' can only be declared via cfg file (e.g.
	-- ~/.config/sqlfluff), which my sqlfluff install doesn't seem to recognise
	-- "--ignore_comment_lines=true",
	-- https://docs.sqlfluff.com/en/stable/reference/rules.html#rule-layout.long_lines
	-- https://docs.sqlfluff.com/en/stable/reference/rules.html#rule-references.consistent

	-- https://news.ycombinator.com/item?id=28771656
}

-- }}}
-- formatter: conform {{{

require("conform").setup({
	-- :h conform-formatters
	formatters = {
		black = {
			-- https://black.readthedocs.io/en/stable/the_black_code_style/future_style.html#preview-style
			prepend_args = { "--preview" },
		},
		isort = {
			prepend_args = { "--force-single-line-imports", "--profile", "black" },
		},

		prettier = {
			prepend_args = { "--print-width", "80" },
		},

		biome = { cwd = root_directory }, -- important: work biome.json is at top-level

		shfmt = {
			prepend_args = {
				"-i", -- always use tabs
				"0",
				"-s", -- simplify
				"-sr", -- spaces before < etc
			},
		},

		rustfmt = {
			prepend_args = {
				-- defaults:
				-- rustfmt.toml
				-- imports_granularity = Preserve
				-- fn_params_layout = Tall
				-- fn_single_line = false
				-- format_code_in_doc_comments = false
				-- group_imports = Preserve
				-- wrap_comments = false

				-- https://github.com/rust-lang/rustfmt/blob/master/Configurations.md#configuration-options
				"--config",
				"imports_granularity=Item,"
					.. "fn_params_layout=Vertical,"
					.. "fn_single_line=true,"
					.. "format_code_in_doc_comments=true,"
					.. "group_imports=StdExternalCrate,"
					.. "wrap_comments=true",
			},
		},

		dhall = { command = "dhall", args = { "format" } },
		latexindent = {
			-- extra/perl-yaml-tiny
			-- extra/perl-file-homedir
			-- extra/texlive-luatex
			-- texlive-fontsrecommended
			command = "/usr/bin/latexindent",
		},
		astyle = {
			inherit = false,
			command = "astyle",
			-- https://github.com/mellowcandle/astyle_precommit_hook/blob/master/pre-commit#L28
			prepend_args = {
				"--style=1tbs",
				"--indent=tab",
				"--align-pointer=name",
				"--add-brackets",
				"--max-code-length=80",
			},
			condition = function()
				-- don't format dwm.c; formatting may make it difficult to apply/remove patches
				-- https://github.com/folke/dot/blob/f5ba84b3a73a4e2aa4648c14707ce6847c29169b/nvim/lua/plugins/lsp.lua#L209
				local curr_file = vim.fn.expand("%")
				return string.find(curr_file, "dwm.c") == nil
			end,
		},
	},
	formatters_by_ft = {
		-- https://github.com/stevearc/conform.nvim#formatters
		-- not all are provided by Mason! (e.g. astyle)
		-- Conform will run multiple formatters sequentially

		go = {
			-- https://github.com/SingularisArt/Singularis/blob/856a938fc8554fcf47aa2a4068200bc49cad2182/aspects/nvim/files/.config/nvim/lua/modules/lsp/lsp_config.lua#L50

			"gofumpt", -- https://github.com/mvdan/gofumpt?tab=readme-ov-file#added-rules
			"golines", -- https://github.com/segmentio/golines#motivation https://github.com/segmentio/golines?tab=readme-ov-file#struct-tag-reformatting
			"goimports-reviser", -- better default behaviour (lists 1st party after 3rd party); TODO: investigate why this breaks in some dirs (e.g. linkedin)
			-- "goimports", -- required for autoimport (null_ls), but not for formatting -- https://pkg.go.dev/golang.org/x/tools/cmd/goimports
		},

		markdown = {
			-- i like that prettier clobbers italics * into _ (markdownlint doesn't)
			-- TODO: will not run from ~
			"prettier",
			"markdownlint",
			-- stop_after_first = true,
		},

		-- cpp = { "astyle" },
		-- markdown = { "mdslw" }, -- i like the idea, but not really on cargo yet
		["_"] = { "trim_whitespace" },
		bash = { "shfmt" },
		c = { "clang-format" }, -- clang-format requires config (presumably a .clang-format file) ootb
		css = { "prettier" },
		dhall = { "dhall" },
		gleam = { "gleam" }, -- apparently this works?
		html = { "prettier" }, -- need --parser html?
		htmldjango = { "djlint" },
		lua = { "stylua" },
		python = { "black", "isort" },
		ruby = { "rubocop" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		tex = { "latexindent" },
		toml = { "taplo" },
		xml = { "xmlformat" },
		yaml = { "prettier" },

		javascript = { "biome", "prettier", stop_after_first = true },
		javascriptreact = { "biome", "prettier", stop_after_first = true },
		json = { "biome", "prettier", stop_after_first = true },
		jsonc = { "biome", "prettier", stop_after_first = true },
		typescript = { "biome", "prettier", stop_after_first = true },
		typescriptreact = { "biome", "prettier", stop_after_first = true },

		-- note: none of the sql formatters seem to work; sqlfluff fix is supposed
		-- to work, but 'Root directory not found'
		-- sql = { "sqlfluff" },
	},
})

-- }}}
-- completer: nvim-cmp + luasnip {{{
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").load({
	include = {
		-- i only need snippets for languages without an lsp (e.g. htmldjango)

		"css",
		"html",
		"htmldjango",
		"jsx",
		"markdown",
		-- "javascript", -- where my jsx snippets at??
	},
})

-- https://github.com/m3idnotfree/Zkdqay9Co4/blob/f86e44c7ca3de055eb79e19e16557cea01c11bc5/nvim/snippets/gitcommit/init.lua
-- seems neat, until you see 'util.luasnip.format':
-- https://github.com/m3idnotfree/Zkdqay9Co4/blob/f86e44c7ca3de055eb79e19e16557cea01c11bc5/nvim/lua/util/luasnip/format.lua
-- luasnip.filetype_extend("gitcommit", foo)

luasnip.config.setup({})

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({

		-- ["<c-space>"] = cmp.mapping.complete({}),
		["<c-,>"] = cmp.mapping.scroll_docs(4),
		["<c-m>"] = cmp.mapping.scroll_docs(-4),

		["<c-j>"] = cmp.mapping.select_next_item(),
		["<c-k>"] = cmp.mapping.select_prev_item(),

		["<cr>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),

		["<tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		-- ["<s-tab>"] = cmp.mapping(function(fallback)
		-- 	if cmp.visible() then
		-- 		cmp.select_prev_item()
		-- 	elseif luasnip.locally_jumpable(-1) then
		-- 		luasnip.jump(-1)
		-- 	else
		-- 		fallback()
		-- 	end
		-- end, { "i", "s" }),
	}),
	sources = {
		{
			name = "nvim_lsp",
			-- disable lsp 'Snippet's (somewhat annoying for rust, e.g. 'rc~')
			-- this restriction can easily be made rust-specific
			-- https://neovim.discourse.group/t/how-to-disable-lsp-snippets/922/5
			entry_filter = function(entry)
				return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
			end,
		},
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
		-- { name = "gitcommit" }, -- dunno how this is supposed to work -- https://github.com/Cassin01/cmp-gitcommit#usage
	},
})

require("cmp-gitcommit").setup({}) -- i don't really use this

-- }}}

-- https://github.com/mfussenegger/dotfiles/blob/da93d1f7f52ea50b00199696a6977dd70a84736e/vim/dot-config/nvim/lua/me/dap.lua

local dap = require("dap")

-- vim.keymap.set({ "n", "v" }, "<leader>dh", require("dap.ui.widgets").hover)
vim.keymap.set("n", "<leader>dj", dap.continue)
vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint)
vim.keymap.set({ "n", "v" }, "<leader>dp", require("dap.ui.widgets").preview)

-- -- race condition: when calling continue and preview sequentially, continue
-- -- will advance to next breakpoint, but because preview is 'faster', it will
-- -- display whichever the line the cursor was at when `continue` was called
-- -- (usually not useful). as a result, preview must be called separately, which
-- -- is annoying.
-- vim.keymap.set("n", "<leader>dj", function()
-- 	dap.continue()
-- 	require("dap.ui.widgets").preview() -- more useful than hover since it doesn't grab focus, and the split is always reused
-- end)

vim.keymap.set("n", "<leader>dr", dap.repl.open) -- not terribly useful?

vim.keymap.set("n", "<leader>di", dap.step_into) -- https://stackoverflow.com/a/3580851
vim.keymap.set("n", "<leader>do", dap.step_out)
vim.keymap.set("n", "<leader>dv", dap.step_over)

-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
-- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#usage

require("dap-python").setup("/usr/bin/python3") -- `python3 -m debugpy --version` must work in the shell

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		-- pythonPath = "/usr/bin/python",
	},
}

require("nvim-dap-virtual-text").setup({
	virt_text_pos = "eol", -- inline is very hard to read
	-- note: current value will always be placed at the initial declaration
})

-- vim.cmd.colorscheme("citruszest")
require("util"):random_colorscheme()
vim.keymap.set("n", "<F12>", require("util").random_colorscheme)

-- }}}

-- is there a better place to put this?
vim.filetype.add({
	pattern = {
		-- https://github.com/emilioziniades/dotfiles/blob/db7b414c150d3a3ab863a0109786f7f48465dd23/nvim/init.lua#L708
		[".*/templates/.*.html"] = function(_, bufnr)
			local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			for _, line in ipairs(content) do
				if line:match("{%%") or line:match("%%}") then
					return "htmldjango"
				end
			end
		end,
		["Dockerfile.*"] = "dockerfile",
		[".+%.flux"] = "flux",
		["docker%-compose.*.yml"] = "yaml.docker-compose", -- '-' has special meaning (smh)
	},

	-- https://github.com/kennethnym/dotfiles/blob/41f03b9091181dc62ce872288685b27f001286f3/nvim/init.lua#L474
	filename = {
		["Dockerfile"] = "dockerfile",
		["docker-compose.yml"] = "yaml.docker-compose",
	},
})
