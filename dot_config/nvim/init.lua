-- re-sourcing this file (and its dependents) is easy (with :source or
-- :luafile), but clearing all existing state (e.g. keybinds) is not
-- https://neovim.discourse.group/t/reload-init-lua-and-all-require-d-scripts/971/19

require("util")

require("autocmds")
require("binds")
require("filetypes")
require("sets")

require("plugins")

-- TODO: start moving sections with >200 lines out into separate files

-- plugin autocmds {{{

-- format before write, lint after write
-- do both on startup

vim.api.nvim_create_autocmd({
	"BufWritePre",
	-- "VimEnter", -- triggers erroneously on Lazy init (i.e auto-install new plugin)
	"BufReadPost",
}, {
	callback = function()
		if vim.bo.modifiable then
			require("conform").format()
		end
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

vim.api.nvim_create_autocmd({ "VimResized" }, {
	-- git blame should always be displayed inline, never in lualine
	-- git blame should be disabled in narrow windows as it is not useful
	callback = function()
		vim.cmd(vim.o.columns > 170 and "GitBlameEnable" or "GitBlameDisable")
	end,
})

-- }}}
-- plugin binds {{{

-- vim.keymap.set("n", "<leader>gB", ":GitBlameToggle<cr>") -- must be explicitly enabled on mac (due to lacking horizontal space)
vim.keymap.set("n", "<leader>J", ":TSJToggle<cr>")

vim.keymap.set("n", "<leader>gB", ":BlameToggle<cr>")
vim.keymap.set("n", "<leader>gS", ":Gitsigns stage_buffer<cr>", { desc = "stage all hunks in current buffer" }) -- same as :Gwrite?
vim.keymap.set("n", "<leader>gh", ":Gitsigns stage_hunk<cr>") -- more ergonomic than gs, but my muscle memory goes to gs
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<cr>")
vim.keymap.set("v", "gs", ":Gitsigns stage_hunk<cr>")

vim.keymap.set("n", "<leader>gb", function()
	-- vim.cmd("GitBlameOpenCommitURL") -- GitBlameOpenFileURL may produce bogus URLs (usually when files are moved), and going to the commit provides better context anyway
	-- https://github.com/f-person/git-blame.nvim/issues/103
	-- ubuntu xdg-open doesn't work
	vim.cmd("GitBlameCopyCommitURL")
	vim.fn.jobstart('sleep 0.5 ; xdg-open "$(xclip -o -sel c)" || firefox "$(xclip -o -sel c)"')
end, { desc = "view commit of current line (in browser)" })

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
		if vim.fn.argv(0) == "" and require("util"):in_git_repo() and vim.bo.filetype ~= "man" then
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
		layout_strategy = require("util"):get_layout_strategy(),
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
				layout_strategy = require("util"):get_layout_strategy(),
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

vim.api.nvim_create_autocmd({ "VimEnter", "VimResized" }, {
	callback = function()
		require("telescope").setup({
			defaults = { layout_strategy = require("util"):get_layout_strategy() },
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

-- vim.keymap.set("n", "<leader>gS", telescope_b.git_status, { desc = "git status" }) -- like git ls-files with diff
-- vim.keymap.set("n", "<leader>gb", telescope_b.git_branches, { desc = "git branches" }) -- generally better to switch branches in shell, due to annoying checkout hooks
vim.keymap.set("n", "<leader>gl", telescope_b.git_commits, { desc = "git log with commit diffs" }) -- basically gld

-- vim.keymap.set("n", "<leader>?", telescope_b.help_tags, { desc = "search help" }) -- let's face it; i never use this
-- vim.keymap.set("n", "<leader>u", telescope.extensions.undo.undo)

vim.keymap.set("n", "<leader>h", function()
	-- inlay hints lead to -a lot- of clutter (esp in rust), so they should not
	-- be enabled by default
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "toggle inlay hints" })

-- }}}
require("lsp")
-- linter: nvim-lint {{{
-- to ensure all tools (linters etc) are up-to-date, it is better to keep them
-- in /nvim/mason (rather than decentralised user-installed ones)

-- lua print(require("lint").get_running()[1])

local linters = {

	-- elixir = { "credo" }, -- where da binary at
	-- https://github.com/mfussenegger/nvim-lint#available-linters
	-- note: the standard rust linter is clippy, which is part of the lsp
	-- ruby = { "rubocop" },
	bash = { "shellcheck" },
	dockerfile = { "hadolint" }, -- can be quite noisy
	gitcommit = { "gitlint" },
	go = { "golangcilint" },
	html = { "markuplint" },
	htmldjango = { "djlint" },
	javascript = { "biomejs" },
	javascriptreact = { "biomejs" },
	make = { "checkmake" },
	markdown = {
		"markdownlint", -- https://github.com/DavidAnson/markdownlint?tab=readme-ov-file#rules--aliases
		"proselint", -- https://github.com/amperser/proselint?tab=readme-ov-file#checks
	},
	python = { "ruff" }, -- pylint is too slow and unreliable
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

-- TODO: configure linters https://golangci-lint.run/usage/linters/#asasalint
-- decorder, dogsled, errchkjson, errorlint, funlen, goconst, grouper?, iface,
-- importas, lll, nestif, nilnil, nlreturn, nolintlint, nonamedreturns,
-- tagalign, usestdlibvars, unconvert, unparam, unused, varnamelen, whitespace
-- require("lint").linters.golangci.args = {}

-- https://github.com/rrunner/dotfiles/blob/d55d90ed5d481fc1138483f76f0970d93784bf0a/nvim/.config/nvim/lua/plugins/linting.lua#L17
require("lint").linters.ruff.args = {
	"check",
	"--preview",
	"--select=ALL",
	"--target-version=py310", -- type hints = 39, Optional (etc) = 310
	"--ignore=" .. table.concat({
		-- https://docs.astral.sh/ruff/rules/

		"DOC201", -- allow docstrings to not document return type
		"ERA", -- allow comments
		"I001", -- ignore import sort order (handled by isort)
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
	"--no-fix", -- --fix should never be used for linting, because it destroys undos; fix via conform instead
	"--output-format=json", -- important
	"-",
}

local custom_gcl = vim.fn.globpath(
	-- note: on startup, starts in cwd. path is only adjusted to project root
	-- later
	-- ".",
	require("util"):root_directory(),
	"custom-gcl"
)
if custom_gcl ~= "" then
	require("lint").linters.golangcilint.cmd = custom_gcl
end

require("lint").linters.sqlfluff.args = {
	"lint",
	-- TODO: infer dialect (either via heuristics, some modeline equivalent, or sqls.nvim)
	"--dialect=sqlite",
	"--format=json",
	"--exclude-rules",
	table.concat({
		"layout.long_lines",
		"references.qualification", -- these must be ignored in sqlite
		"references.consistent",
	}, ","),

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
			prepend_args = { "--unstable" },
		},

		isort = {
			prepend_args = require("util").is_ubuntu and { "--profile", "black" } -- don't use single-line style at work
				or { "--force-single-line-imports", "--profile", "black" },
		},

		ruff_fix = {
			-- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/ruff_fix.lua
			args = {
				"check",

				-- opt-out for now
				"--select=ALL",
				"--ignore=" .. table.concat({
					-- https://docs.astral.sh/ruff/rules/
					-- only rules with wrench symbol are supported

					"F841", -- allow unused var
					"I001", -- sort imports (does not support one-per-line, unlike isort)
				}, ","),

				"--fix",
				"--force-exclude",
				"--exit-zero",
				"--no-cache",
				"--stdin-filename",
				"$FILENAME",
				"-",
			},
		},

		-- note: for <script> to be formatted properly, type= is required
		-- https://github.com/prettier/prettier/blob/main/tests/format/html/js/js.html
		prettier = {
			prepend_args = { "--print-width", "80" },
			cwd = function()
				-- for some reason, prettier will not modify file if cwd == ~ (file
				-- location is irrelevant)
				return "/tmp"
			end,
		},

		["clang-format"] = {
			-- https://clang.llvm.org/docs/ClangFormatStyleOptions.html#basedonstyle
			-- https://github.com/motine/cppstylelineup
			prepend_args = { "--style", "google" },
		},

		-- https://taplo.tamasfe.dev/configuration/formatter-options.html
		taplo = {
			args = {
				"format",
				"--option",
				"array_auto_expand=false",
				"--option",
				"compact_arrays=false",
				"--option",
				"align_entries=true", -- does not align array elements (like gofmt and struct fields)
				"--option",
				"allowed_blank_lines=1",
				"-",
			},
		},

		biome = {
			-- important: at work, use top-level biome.json
			-- note: cwd must be a func, not a string
			cwd = require("util").root_directory,
			-- TODO: if biome.json exists, leave args unchanged
			args = {
				"format",
				"--indent-style=space",
				"--stdin-file-path",
				"$FILENAME",
			},
		},

		shfmt = {
			prepend_args = {
				-- "--indent", -- always use tabs (default)
				-- "0",
				"--simplify",
				"--space-redirects",
			},
		},

		rustfmt = {
			prepend_args = {
				-- https://github.com/rust-lang/rustfmt/blob/master/Configurations.md#configuration-options
				"--config",
				table.concat({
					"fn_params_layout=Vertical", -- default: Tall
					"format_code_in_doc_comments=true", -- default: false
					"group_imports=StdExternalCrate", -- default: Preserve
					"imports_granularity=Item", -- default: Preserve
					"wrap_comments=true", -- default: false
					-- "fn_single_line=false", -- default: false
				}, ","),
			},
		},

		sqruff = {
			command = "sqruff", -- need nightly install https://github.com/quarylabs/sqruff?tab=readme-ov-file#for-other-platforms
			args = { "fix", "-" },
			stdin = true,
			exit_codes = { 0, 1 }, -- lol https://github.com/quarylabs/sqruff/issues/1134
		},

		sqlfluff = {
			-- format: more reliable; will format if no violations found
			-- fix: does nothing if 'Unfixable violations detected'
			-- in either case, no `dialect` usually leads to timeout
			args = {
				"format",
				"--processes=32", -- lol
				"--dialect=sqlite",
				"--exclude-rules",
				"layout.long_lines",
				"-",
			},
			stdin = true,
			require_cwd = false, -- else requires local .sqlfluff
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
			prepend_args = {
				-- linux kernel style
				-- https://github.com/mellowcandle/astyle_precommit_hook/blob/master/pre-commit#L28
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

		-- -- https://github.com/stevearc/conform.nvim/issues/197#issuecomment-1808807141
		-- -- "If the command accepts stdin and prints the formatted results to
		-- -- stdout, then you're done."
		-- -- it could be that sol's reading of stdin is misconfigured
		-- -- Formatter 'sol' error: time="2024-11-14T09:24:34+01:00" level=fatal msg="could not read file: open /dev/stdin: no such device or address"
		-- --
		-- -- https://github.com/noperator/sol/issues/2
		-- -- removes comments, so this is a non-starter anyway
		-- sol = {
		-- 	inherit = false,
		-- 	-- stdin = true,
		-- 	command = "sol",
		-- 	args = { "-w", "80" },
		-- 	-- args = "cat $FILENAME | sol",
		-- },
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

		python = {
			"isort",
			"black",
			"ruff_fix", -- run ruff_fix last to preserve black's unstable-style parens
		},

		-- ruby = { "rubocop" },
		["_"] = { "trim_whitespace" },
		bash = { "shfmt" },
		c = { "clang-format" }, -- provided by clangd, apparently
		cpp = { "clang-format" },
		css = { "prettier" },
		dhall = { "dhall" },
		elixir = { "mix" }, -- slow (just like elixir)
		gleam = { "gleam" }, -- apparently this works?
		html = { "prettier" }, -- need --parser html?
		htmldjango = { "djlint" },
		lua = { "stylua" },
		markdown = { "mdslw", "prettier" },
		ocaml = { "ocamlformat" },
		rust = { "rustfmt" },
		scss = { "prettier" },
		sh = { "shfmt" },
		sql = { "sqruff", "sqlfluff", stop_after_first = true },
		templ = { "templ" },
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

		["<c-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<c-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

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

require("util"):random_colorscheme()
vim.keymap.set("n", "<F12>", require("util").random_colorscheme)
