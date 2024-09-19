-- TODO: root_pattern for lua; set root to .config/nvim?
-- structuring: see https://github.com/arnvald/viml-to-lua

require("binds")
require("sets")
require("autocmds")

require("_lazy")

vim.api.nvim_set_keymap("n", "<leader>nf", ":lua require('neogen').generate()<cr>", { noremap = true, silent = true })
-- https://github.com/danymat/neogen#supported-languages
-- google_docstrings
-- i can't remember why i placed this so far up
require("neogen").setup({ snippet_engine = "luasnip" })

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

vim.api.nvim_create_autocmd({ "BufWritePost", "VimEnter" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		-- must be called after any colorscheme change
		-- on change, current line will not have marks, but this is not an issue
		-- if you're really picky, you could do a normal mode hl or whatever
		require("eyeliner").setup({ highlight_on_key = false }) -- always show highlights, without keypress
		vim.api.nvim_set_hl(0, "EyelinerPrimary", { underline = true })
		vim.api.nvim_set_hl(0, "EyelinerSecondary", { underline = true })

		-- enforce hl colorcolumn (citruszest unsets it)
		-- $HOME/.local/share/nvim/lazy/citruszest.nvim/lua/citruszest/highlights/init.lua:29
		-- 8:    ColorColumn = { bg = C.none }, -- used for the columns set with 'colorcolumn'
		vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#48D1CC" })

		-- TODO: set lualine?
	end,
})

-- autocmd User VimtexEventInitPost VimtexView
-- autocmd User VimtexEventQuit call vimtex#compiler#clean(0)
-- autocmd VimLeave *.tex silent exec "!sh ~/scripts/fkill %"

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.tex" },
	command = "VimtexClean",
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = {
		"*.tex",
		-- "*.cls",
	},
	command = "VimtexCompile",
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
		local start_time = os.clock()
		require("lazy").sync({ wait = false, show = false })
		local end_time = os.clock()
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

		-- https://github.com/wochap/nvim/blob/60920de61ae887f04994a4f253e19c0494d33023/lua/custom/custom-plugins/configs/git-conflict.lua#L4
		vim.keymap.set("n", "[c", "<cmd>GitConflictPrevConflict<CR>|zz")
		vim.keymap.set("n", "]c", "<cmd>GitConflictNextConflict<CR>|zz")
		vim.keymap.set("n", "cq", "<cmd>GitConflictListQf<CR>")
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

-- }}}
-- plugin binds {{{

-- vim.keymap.set("n", "<leader>T", ":NvimTreeToggle<cr>")
-- vim.keymap.set("n", "<leader>o", ":SymbolsOutline<cr>")
-- vim.keymap.set("n", "<leader>p", ":Lazy profile<cr>")
vim.keymap.set("n", "<leader>J", ":TSJToggle<cr>")
vim.keymap.set("n", "<leader>T", ":tabe ")
vim.keymap.set("n", "<leader>gB", ":GitBlameToggle<cr>") -- must be explicitly enabled on mac (due to lacking horizontal space)
vim.keymap.set("n", "<leader>gS", ":Gitsigns stage_buffer<cr>")
vim.keymap.set("n", "<leader>gh", ":Gitsigns stage_hunk<cr>") -- more ergonomic than gs, but my muscle memory goes to gs
vim.keymap.set("n", "<leader>go", ":GitBlameOpenCommitURL<cr>") -- more useful than GitBlameOpenFileURL
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<cr>")
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
	-- TODO: next works, but previous doesn't; not sure if this is related:
	-- https://github.com/folke/trouble.nvim/issues/494
	require("trouble").open({ mode = "diagnostics" })
	require("trouble").prev({ skip_groups = true, jump = true })
end, { desc = "previous diagnostic message" })

vim.keymap.set("n", "<leader>l", function()
	require("trouble").toggle({ mode = "diagnostics", focus = true })
end)

-- }}}
-- navigator: telescope {{{

-- must be declared after loading plugins
local telescope = require("telescope")
local telescope_b = require("telescope.builtin")

local telescope_actions = require("telescope.actions")

local function in_git_repo()
	-- https://www.reddit.com/r/neovim/comments/y2t9rt/comment/is4wjmb/
	-- https://www.reddit.com/r/neovim/comments/vkckjb/comment/idosy7m/
	-- maybe use this cond to lazy-start gitsigns
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- mostly to avoid find from mac home
		if vim.fn.argv(0) == "" and in_git_repo() and vim.bo.filetype ~= "man" then
			telescope_b.find_files()
		end
	end,
})

-- local telescope_trouble = require("trouble.providers.telescope")

telescope.setup({

	-- :h telescope.defaults
	defaults = {

		-- https://github.com/nvim-telescope/telescope.nvim/blob/24778fd72fcf39a0b1a6f7c6f4c4e01fef6359a2/lua/telescope/config.lua#L144

		border = true, -- if false, all text is disabled!
		dynamic_preview_title = true, -- useful, since you don't have to look away from the right pane
		layout_config = { preview_cutoff = 0 },
		layout_strategy = "horizontal",
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

				-- ["<c-o>"] = telescope_actions.select_tab_drop,
				-- ["<c-s>"] = telescope_actions.select_horizontal, -- open in horiz split
				-- ["<c-x>"] = require("telescope.actions.layout").toggle_prompt_position,
				["<c-j>"] = telescope_actions.move_selection_next,
				["<c-k>"] = telescope_actions.move_selection_previous,
				["<c-l>"] = function()
					vim.cmd("normal E")
				end,

				-- ["<c-i>"] = telescope_actions.preview_scrolling_up,
				-- ["<c-u>"] = telescope_actions.preview_scrolling_down,
				["<c-b>"] = telescope_actions.preview_scrolling_up,
				["<c-f>"] = telescope_actions.preview_scrolling_down,

				["<c-c>"] = telescope_actions.close,
				["<c-d>"] = telescope_actions.select_tab_drop, -- reuse tab, if buffer already open
				["<c-e>"] = telescope_actions.select_tab_drop,
				["<c-p>"] = require("telescope.actions.layout").toggle_preview,
				-- ["<c-s-t>"] = telescope_trouble.open_with_trouble,
				-- ["<c-s-t>"] = require("trouble.sources.telescope").open(),
				["<c-t>"] = require("telescope.actions.layout").cycle_layout_next, -- TODO: why must input twice?
				["<cr>"] = telescope_actions.select_tab_drop,
				["<esc>"] = telescope_actions.close,
			},

			n = {

				["<c-c>"] = telescope_actions.close,
				["<c-s>"] = telescope_actions.select_horizontal,
				["<cr>"] = telescope_actions.select_tab_drop,
				-- ["t"] = telescope_trouble.open_with_trouble,
				-- ["t"] = require("trouble.sources.telescope").open(),
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
				layout_strategy = "center",
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
-- telescope.load_extension("undo")
telescope.load_extension("file_browser")
telescope.load_extension("heading")
-- telescope.load_extension("ui-select")

-- }}}
-- telescope binds {{{

-- local function merge_tables(self, other)
-- 	for k, v in pairs(other) do
-- 		self[k] = v
-- 	end
-- 	return self
-- end

local function get_layout_strategy()
	-- "vertical" is recommended if file previews are important, e.g. git diff,
	-- symbol search, or if window is narrow
	--
	-- "center" is recommended if previews are unimportant (or irrelevant)
	--
	-- for everything else, "horizontal" is a good fallback. having said that,
	-- thinking about layouts is cognitive load and should be avoided
	if vim.o.lines > 60 or vim.o.columns < 100 then
		return "vertical"
	else
		return "horizontal"
	end
end

vim.api.nvim_create_autocmd({ "VimEnter", "VimResized" }, {
	callback = function()
		require("telescope").setup({
			defaults = { layout_strategy = get_layout_strategy() },
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
vim.keymap.set("n", "<leader>gC", telescope_b.git_commits, { desc = "git commits" }) -- like :Gclog but better
vim.keymap.set("n", "<leader>gb", telescope_b.git_branches, { desc = "git branches" })

-- vim.keymap.set("n", "<leader>?", telescope_b.help_tags, { desc = "search help" }) -- let's face it; i never use this
-- vim.keymap.set("n", "<leader>u", telescope.extensions.undo.undo)

vim.keymap.set("n", "<leader>h", function()
	-- inlay hints lead to -a lot- of clutter (esp in rust), so they should not
	-- be enabled by default
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "toggle inlay hints" })

-- buffer-specific LSP keymaps
local function on_attach(_, bufnr)
	-- This function gets run when an LSP connects to a particular buffer,
	-- defining mappings specific for LSP related items. It sets the mode, buffer
	-- and description for us each time.
	local function nmap(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>a", vim.lsp.buf.code_action, "code action") -- i only want to use code_action for refactoring (extract_function), but it just doesn't work in rust; needs nightly?
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
					-- file at line; only works if buffer loaded
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
		require("telescope.builtin").treesitter({ symbols = { "method", "function" } })
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
	callback = function(ev)
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

-- -- https://neovim.io/doc/user/lsp.html#lsp-inlay_hint -- requires 0.10
-- -- https://vinnymeller.com/posts/neovim_nightly_inlay_hints/#globally
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	-- group = vim.api.nvim_create_augroup("UserLspConfig", {}),
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
-- 		if client.server_capabilities.inlayHintProvider then
-- 			vim.lsp.inlay_hint.enable(args.buf, true)
-- 		end
-- 		-- whatever other lsp config you want
-- 	end,
-- })

-- print(vim.fn.stdpath("data"))

-- :Mason
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
-- multiple LSPs lead to strange behaviour (e.g. renaming symbol twice)
-- warning: commenting out an lsp does not uninstall it!
local servers = {

	-- https://github.com/blackbhc/nvim/blob/4ae2692403a463053a713e488cf2f3a762c583a2/lua/plugins/lspconfig.lua#L399
	-- https://github.com/oniani/dot/blob/e517c5a8dc122650522d5a4b3361e9ce9e223ef7/.config/nvim/lua/plugin.lua#L157

	bashls = {},
	biome = {},
	marksman = {}, -- TODO: md should never have any concept of root_dir
	taplo = {},
	yamlls = {},
	zls = {},

	-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
	gopls = {
		gopls = { -- i have absolutely no idea why we need a gopls table

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

	tsserver = {
		-- note: js projects will require jsconfig.json
		diagnostics = {
			-- remove unused variable diagnostic messages from tsserver
			ignoredCodes = {
				-- declared but never used
				-- TODO: these warnings should probably be enabled for real (production) work
				6133,
				6196,
			},
		},
	},

	sqls = {
		filetypes = { "sql" },
		-- on_attach = function(client, bufnr)
		-- 	client.resolved_capabilities.execute_command = true
		-- 	highlight.diagnositc_config_sign()
		-- 	require("sqls").setup({ picker = "telescope" }) -- or default
		-- end,
		flags = {
			allow_incremental_sync = true,
			debounce_text_changes = 500,
		},
		settings = {
			-- cmd = { "sqls", "-config", "$HOME/.config/sqls/config.yml" },
			-- alterantively:
			-- connections = {
			--   {
			--     driver = 'postgresql',
			--     datasourcename = 'host=127.0.0.1 port=5432 user=postgres password=password dbname=user_db sslmode=disable',
			--   },
			-- },
		},
	},

	rust_analyzer = {
		["rust-analyzer"] = {
			-- https://rust-analyzer.github.io/manual.html#configuration
			-- https://hw0lff.github.io/rust-analyzer-docs/2021-11-01/index.html
			checkOnSave = {
				enable = true,
				allFeatures = true,
				command = "clippy", -- https://rust-lang.github.io/rust-clippy/master/index.html
			},
			completion = {
				-- addCallParenthesis is great 90% of the time, but the 10% of the time
				-- that i don't want it (println), the parens are extremely frustrating
				addCallParenthesis = true,
				-- postfix = { enable = false },
				-- addCallArgumentSnippets = false,
			},
		},
	},

	lua_ls = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
				disable = { "missing-fields" },
			},
			telemetry = { enable = false },
			workspace = { checkThirdParty = false },
		},
	},

	-- -- until further notice, i have given up trying to get ruby_lsp to work
	-- -- https://github.com/Shopify/ruby-lsp/blob/main/EDITORS.md#Neovim
	-- ruby_lsp = {},
}

local mason_lspconfig = require("mason-lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

mason_lspconfig.setup({
	-- Ensure the servers above are installed
	ensure_installed = vim.tbl_keys(servers), -- lsps
})

mason_lspconfig.setup_handlers({
	function(server_name)
		-- print(servers[server_name])
		require("lspconfig")[server_name].setup({
			-- get additional completion capabilities from nvim-cmp
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		})
	end,
})

require("lspconfig").gleam.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- because ruby paths are a mess, tools should not be installed by mason
require("lspconfig")["sorbet"].setup({
	-- https://sorbet.org/docs/adopting
	--
	-- despite being billed as a 'type checker', sorbet actually provides a lot
	-- of useful LSP functionality, such as function autocomplete and hover; the
	-- ruby-lsp equivalents are very limited in comparison.
	capabilities = capabilities,
	on_attach = on_attach,
	-- requires '# typed: true'
	cmd = { "srb", "tc", "--lsp", "--disable-watchman", "." },
})

-- https://github.com/Lilja/dotfiles/blob/9fd77d2f5d55352b36054bcc7b4acc232cb99dc6/nvim/lua/plugins/lsp_init.lua#L106
local function get_python_path(workspace) -- {{{
	local util = require("lspconfig/util")
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		return util.path.join(vim.env.VIRTUAL_ENV, "bin", "python")
	end

	-- Find and use virtualenv from poetry in workspace directory.
	-- important: for `poetry env info` to detect venv,
	-- ~/.cache/pypoetry/virtualenvs/proj-xyz-<version> and
	-- version declared in ~/.cache/pypoetry/virtualenvs/envs.toml
	-- must correspond
	-- https://stackoverflow.com/a/65376300
	-- if this separation between code and packages is not desired, run
	-- poetry config virtualenvs.in-project true
	-- this reverts to the 'traditional' way of keeping a .venv directory in the project
	local poetryMatch = vim.fn.glob(util.path.join(workspace, "poetry.lock"))
	if poetryMatch ~= "" then
		local poetry = vim.fn.trim(vim.fn.system("poetry --directory " .. workspace .. " env info -p"))
		-- print(util.path.join(poetry, "bin", "python"))
		return util.path.join(poetry, "bin", "python")
	end

	-- Fallback to system Python.
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end -- }}}

-- note: after python update, pyright must be reinstalled
require("lspconfig").pyright.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	before_init = function(_, config)
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
	-- https://github.com/mfussenegger/nvim-lint/issues?q=is%3Aissue+vale+
	-- markdown = { "proselint" }, -- doesn't work
	-- markdown = { "vale" }, -- riddled with errors
	-- note: the standard rust linter is clippy, which is part of the lsp
	bash = { "shellcheck" },
	dockerfile = { "hadolint" },
	gitcommit = { "gitlint" },
	go = { "golangcilint" },
	html = { "markuplint" },
	htmldjango = { "djlint" },
	javascript = { "biomejs" },
	markdown = { "markdownlint", "proselint" },
	ruby = { "rubocop" },
	typescript = { "biomejs" },

	python = {
		"ruff",
		-- "pylint", -- https://github.com/mfussenegger/nvim-lint/issues/606
	},

	-- # a good litmus test:
	-- foo = "%s" % 111
	-- bar = list([x for x in range(3)])
	-- if 1:
	--     raise ValueError
	-- else:
	--     pass
}

-- https://github.com/orumin/dotfiles/blob/62d7afe8a9bf531d1b5c8b13bbb54a55592b34b3/nvim/lua/configs/plugin/lsp/linter_config.lua#L7
require("lint").linters_by_ft = linters

-- https://github.com/rrunner/dotfiles/blob/d55d90ed5d481fc1138483f76f0970d93784bf0a/nvim/.config/nvim/lua/plugins/linting.lua#L17
require("lint").linters.ruff.args = {
	"check",
	"--select=ALL",
	"--ignore="
		.. "ERA" -- allow comments
		.. ",PD901" -- allow var name df
		.. ",PLR0913" -- allow >5 func args
		.. ",PLR2004" -- allow magic constant values
		.. ",RET504" -- allow unnecessary assignment before return statement
		.. ",T201", -- allow print()
	"--force-exclude",
	"--quiet",
	"--stdin-filename",
	vim.api.nvim_buf_get_name(0),
	"--no-fix", -- --fix won't work in nvim
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

-- }}}
-- formatter: formatter {{{

require("conform").setup({
	-- :h conform-formatters
	-- why are linters (e.g. shellcheck) listed here?
	formatters = {
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
		black = {
			-- https://black.readthedocs.io/en/stable/the_black_code_style/future_style.html#preview-style
			prepend_args = { "--preview" },
		},
		prettier = {
			prepend_args = { "--print-width", "80" },
		},
		rustfmt = {
			prepend_args = {
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
		shfmt = {
			prepend_args = {
				"-i", -- always use tabs
				"0",
				"-s", -- simplify
				"-sr", -- spaces before < etc
			},
		},
		dhall = { command = "dhall", args = { "format" } },
	},
	formatters_by_ft = {
		-- https://github.com/stevearc/conform.nvim#formatters
		-- not all are provided by Mason! (e.g. astyle)
		-- Conform will run multiple formatters sequentially

		-- -- biome uses hard tabs by default, which is crazy
		-- -- https://biomejs.dev/formatter/#options
		-- javascript = { { "biome", "biome-check", "prettierd", "prettier" } },
		-- javascriptreact = { { "biome", "biome-check", "prettierd", "prettier" } },
		-- typescript = { { "biome", "biome-check", "prettierd", "prettier" } },
		-- typescriptreact = { { "biome", "biome-check", "prettierd", "prettier" } },

		go = {
			-- https://github.com/SingularisArt/Singularis/blob/856a938fc8554fcf47aa2a4068200bc49cad2182/aspects/nvim/files/.config/nvim/lua/modules/lsp/lsp_config.lua#L50

			"gofumpt", -- https://github.com/mvdan/gofumpt?tab=readme-ov-file#added-rules
			"golines", -- https://github.com/segmentio/golines#motivation
			"goimports-reviser", -- better default behaviour (lists 1st party after 3rd party)
			-- "goimports", -- https://pkg.go.dev/golang.org/x/tools/cmd/goimports
		},

		markdown = {
			-- i like that prettier clobbers italics * into _ (markdownlint doesn't)
			-- TODO: will not run from ~
			"prettier",
			"markdownlint",
			-- stop_after_first = true,
		},

		-- markdown = { "mdslw" }, -- i like the idea, but not really on cargo yet
		["_"] = { "trim_whitespace" },
		bash = { "shfmt" },
		c = { "astyle" }, -- clang-format requires config ootb
		cpp = { "astyle" }, -- clang-format requires config ootb
		css = { "prettier" },
		dhall = { "dhall" },
		gleam = { "gleam" }, -- apparently this works?
		html = { "prettier" }, -- need --parser html?
		htmldjango = { "djlint" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		lua = { "stylua" },
		python = { "black" },
		ruby = { "rubocop" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		sql = { "sql-formatter", "sqlfmt", "sqlfluff", stop_after_first = true },
		tex = { "latexindent" },
		toml = { "taplo" },
		typescript = { "prettier" },
		xml = { "xmlformat" },
		yaml = { "prettier" },
	},
})

-- }}}
-- parser: treesitter {{{
-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
require("nvim-treesitter.configs").setup({

	modules = {},
	ignore_install = {},

	-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3579#issuecomment-1278662119
	sync_install = #vim.api.nvim_list_uis() == 0,

	ensure_installed = { -- parsers

		-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1097#issuecomment-1329917848
		-- :checkhealth nvim-treesitter

		"bash",
		"css",
		"csv",
		"diff", -- warning: highlighting may break if spell is enabled
		"gitcommit",
		"gitignore",
		"go",
		"html",
		"htmldjango",
		"lua",
		"python",
		"rasi",
		"rust",
		"vim",
		"vimdoc",
		-- "scheme",
	},

	auto_install = false, -- if true, parsers will be force-installed every time
	highlight = { enable = true }, -- https://github.com/nvim-treesitter/nvim-treesitter#highlight
	indent = { enable = true },

	-- tree_docs = {
	-- 	-- https://github.com/nvim-treesitter/nvim-tree-docs
	-- 	-- doesn't work
	-- 	enable = true,
	-- 	keymaps = {
	-- 		doc_node_at_cursor = "yd",
	-- 		-- doc_all_in_range = "<leader>GDD",
	-- 	},
	-- },

	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim probably need autocmd
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				-- Define your own text objects mappings, similar to `ip` (inner paragraph)
				["aa"] = "@parameter.outer",
				["ac"] = "@class.outer",
				["af"] = "@function.outer", -- game-changer
				["ia"] = "@parameter.inner",
				["ic"] = "@class.inner",
				["if"] = "@function.inner",
			},
		},

		move = { -- more like jump
			enable = true,
			set_jumps = false, -- whether to set jumps in the jumplist
			goto_next_start = {
				-- TODO: zz after? probably need autocmd
				["gj"] = "@function.outer", -- default gj behavior is now in j
				["gJ"] = "@class.outer", -- default gJ (join with spaces) is never desired
			},
			goto_previous_start = {
				["gk"] = "@function.outer",
				["gK"] = "@class.outer",
			},
			goto_next_end = {
				["gl"] = "@function.outer",
				["gL"] = "@class.outer",
			},
			goto_previous_end = {
				["gh"] = "@function.outer",
				["gH"] = "@class.outer",
			},
		},
		swap = {
			-- only works in params, not data structures (e.g. arrays)
			-- in python, swapping args is never necessary, as params should always be specified as keywords (not positionally)
			-- in rust, swapping args may be useful in one-off instances, static typing + function signature help
			enable = true,
			swap_next = {
				["[]"] = "@parameter.inner",
				["gsj"] = "@function.outer",
			},
			swap_previous = {
				["]["] = "@parameter.inner",
				["gsk"] = "@function.outer",
			},
		},
	},

	incremental_selection = { -- need to see a demo
		enable = true,
		keymaps = {
			-- - init_selection: in normal mode, start incremental selection.
			-- - node_decremental: in visual mode, decrement to the previous named node.
			-- - node_incremental: in visual mode, increment to the upper named parent.
			-- - scope_incremental: in visual mode, increment to the upper scope
			init_selection = "<c-space>", -- viw
			node_decremental = "grm",
			node_incremental = "grn",
			scope_incremental = "grc", -- ??
		},
	},
})

vim.cmd("set foldexpr=nvim_treesitter#foldexpr()") -- https://www.jmaguire.tech/img/code_folding.png

local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

-- Repeat TS movements with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- vim way: ; goes to the direction you were moving.
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- the above keymaps make fFtT non-repeatable; correct that
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)

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

luasnip.config.setup({})

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({

		-- ["<C-Space>"] = cmp.mapping.complete({}),
		-- ["<C-n>"] = cmp.mapping.select_next_item(),
		-- ["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-h>"] = cmp.mapping.scroll_docs(-4),
		["<C-l>"] = cmp.mapping.scroll_docs(4),

		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-k>"] = cmp.mapping.select_prev_item(),

		["<cr>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
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
	},
})

-- }}}
function random_colorscheme() -- {{{
	-- sliced and diced from tssm/nvim-random-colors

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
		local function run_21(f, xs)
			for _, x in ipairs(xs) do
				f(x)
			end
			-- return nil
		end
		local result = {}
		local function _0_(xs)
			for _, x in ipairs(xs) do
				table.insert(result, x)
			end
			return nil
		end
		run_21(_0_, { ... })
		return result
	end

	local packpath = "~/.local/share/nvim/lazy/"
	local path_template = "*/colors/*.%s"

	local globpath = vim.fn["globpath"]

	local paths = concat(
		globpath(packpath, string.format(path_template, "lua"), false, true),
		globpath(packpath, string.format(path_template, "vim"), false, true)
	)

	-- :t tail (basename)
	-- :r root (strip extension)
	local function scheme_name(path)
		return vim.fn["fnamemodify"](path, ":t:r")
	end

	local all_schemes = map(scheme_name, paths)
	local scheme = all_schemes[((os.time() % #all_schemes) + 1)]

	-- vim.cmd("echom '" .. scheme .. "'")
	-- vim.api.nvim_exec(("colorscheme " .. scheme), false)
	vim.cmd("colorscheme " .. scheme)
end

-- must be called before setting `colorscheme`
require("citruszest").setup({
	option = {
		transparent = false,
		bold = false,
		italic = false, -- requiring explicit disable is lamentable; kitty can override italic, but wezterm can't!
	},
})

random_colorscheme()

vim.keymap.set("n", "<F12>", random_colorscheme)

-- }}}

require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true, -- Auto close tags
		enable_rename = true, -- Auto rename pairs of tags
		enable_close_on_slash = false, -- Auto close on trailing </
	},
})

vim.filetype.add({
	pattern = {
		-- https://github.com/emilioziniades/dotfiles/blob/db7b414c150d3a3ab863a0109786f7f48465dd23/nvim/init.lua#L708-L724
		[".*/templates/.*.html"] = function(_, bufnr)
			local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			for _, line in ipairs(content) do
				if line:match("{%%") or line:match("%%}") then
					return "htmldjango"
				end
			end
		end,
		["Dockerfile.*"] = "dockerfile",
	},
})

local function get_bufs_loaded()
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
