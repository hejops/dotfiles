-- vim: ts=2 sts=2 sw=2 et
-- ~/.local/share/nvim/lazy

-- Lazy Startuptime should remain under 200 ms

-- :Lazy profile, filter > 1 ms
-- LuaSnip 3.27ms
-- LuaSnip/plugin/luasnip.lua 3.07ms
-- comment.nvim 1.03ms
-- git-blame.nvim 1.3ms
-- indent-blankline.nvim 3.14ms
-- lualine.nvim 7.81ms
-- mason-null-ls.nvim 6.41ms
-- mason.nvim 1.07ms
-- nvim-cmp 4.53ms
-- nvim-lspconfig 2.83ms
-- nvim-treesitter 4ms
-- nvim-treesitter-textobjects 3.41ms
-- nvim-treesitter-textobjects/plugin/nvim-treesitter-textobjects.vim 3.14ms
-- refactoring.nvim 6.91ms
-- telescope.nvim 1.15ms
-- vim-illuminate 1.13ms
-- vim-matchup 2.39ms
-- vim-matchup/plugin/matchup.vim 2.31ms

-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
	{
		-- essentials {{{

		"ahmedkhalf/project.nvim", -- cd to repo root (else autochdir), most useful for go
		"aymericbeaumet/vim-symlink", -- TODO: can this just be an autocmd?
		"ecridge/vim-kinesis",
		"jbyuki/quickmath.nvim", -- :Quickmath
		"jinh0/eyeliner.nvim", -- replaces quick-scope
		"johnelliott/vim-kinesis-kb900", -- syntax
		"joosepalviste/nvim-ts-context-commentstring", -- TS-aware commentstring
		"kosayoda/nvim-lightbulb", -- alert for possible code actions (rarely used)
		"mbbill/undotree",
		"romainl/vim-cool", -- clear highlight after search
		"rrethy/vim-illuminate", -- highlight symbol under cursor
		"tpope/vim-dispatch",
		"tpope/vim-fugitive",
		"tpope/vim-repeat",
		"tpope/vim-sleuth", -- detect tabstop and shiftwidth automatically
		"tpope/vim-surround",
		"tridactyl/vim-tridactyl", -- syntax highlighting
		"wansmer/treesj", -- :TS[Join|Split|Toggle], very useful for go
		"windwp/nvim-ts-autotag", -- i don't like autoclosing parens, but i do like autoclosing (and renaming!) tags
		-- "Zeioth/garbage-day.nvim", -- kill lsps that hog memory (tsserver?)
		-- "lewis6991/satellite.nvim", -- i hate scrollbars
		-- "nvim-tree/nvim-tree.lua", -- :NvimTree (rarely used; just fuzzy find)
		-- "simrat39/symbols-outline.nvim", -- like github's (almost never used; workspace symbols is more intuitive)
		-- { "tadmccorkle/markdown.nvim", ft = "markdown", opts = {} }, -- meh; https://github.com/tadmccorkle/markdown.nvim?tab=readme-ov-file#usage
		{ "akinsho/git-conflict.nvim", version = "*", config = true },
		{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} }, -- https://github.com/folke/todo-comments.nvim?tab=readme-ov-file#-trouble-todo
		{ "lervag/vimtex", ft = { "tex", "bib" } },
		{ "numtostr/comment.nvim", opts = {} }, -- replaces vim-commentary

		-- {
		-- 	"toppair/peek.nvim", -- requires deno (95 MB), slow, and ugly
		-- 	ft = "markdown",
		-- 	-- event = { "VeryLazy" },
		-- 	build = "deno task --quiet build:fast",
		-- 	config = function()
		-- 		require("peek").setup()
		-- 		vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
		-- 		vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
		-- 	end,
		-- },

		{
			-- https://github.com/ray-x/lsp_signature.nvim/issues/311
			"ray-x/lsp_signature.nvim", -- highlight current param in signature
			-- event = "VeryLazy",
			opts = {},
			config = function(_, opts)
				require("lsp_signature").setup(opts)
			end,
		},

		{
			"xvzc/chezmoi.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("chezmoi").setup({
					edit = {
						watch = true, -- Set true to automatically apply on save.
						force = true, -- Set true to force apply. Works only when watch = true.
					},
					notification = {
						on_open = true,
						on_apply = false,
						on_watch = true, -- "This file will be automatically applied"; requires on_open = true
					},
				})
			end,
		},

		-- }}}

		{ -- mason-null-ls {{{
			-- https://roobert.github.io/2022/12/03/Extending-Neovim/#neovim-plugins-which-solve-problems
			--
			-- afaik, mason-null-ls is essentially only for installing everything
			-- automatically (mason's ensure_installed only applies to lsps). this is not
			-- essential, but nice to have
			--
			-- null-ls has been deprecated, and is now replaced by none-ls
			--
			-- https://github.com/jjangsangy/Dotfiles/blob/a96a66b1b3db191a848daed2f3f2ff498a1e96ad/astro_nvim/plugins/mason.lua#L15
			"jay-babu/mason-null-ls.nvim",
			-- overrides `require("mason-null-ls").setup(...)`
			dependencies = {
				"jose-elias-alvarez/null-ls.nvim",
				"mfussenegger/nvim-lint",
				"stevearc/conform.nvim",
			},
			opts = {
				ensure_installed = {

					-- formatters

					"black",
					"gofumpt",
					"goimports", -- required for autoimport (reviser only performs grouping)
					"goimports-reviser",
					"golines",
					"prettier",
					"shfmt",
					"stylua",
					-- "astyle",
					-- "clang_format",
					-- "rustfmt", -- 'use rustup instead'

					-- linters

					"gitlint",
					"golangci-lint",
					"markdownlint",
					"pylint",
					"shellcheck",
					-- "ruff",
				},

				--
			},
		}, -- }}}
		{ -- lualine {{{
			-- https://github.com/nvim-lualine/lualine.nvim#default-configuration
			"nvim-lualine/lualine.nvim",

			opts = function(_, opts)
				local gitblame = require("gitblame")

				opts.sections = {

					-- https://github.com/nvim-lualine/lualine.nvim#available-components
					-- https://github.com/nvim-lualine/lualine.nvim#component-specific-options

					lualine_a = { "mode" },
					lualine_b = { "branch", "filename" }, -- TODO: suppress if main?
					lualine_c = {
						"diff",
						{ "diagnostics", sources = { "nvim_workspace_diagnostic" } },
					},

					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = {
						-- "progress",
						function()
							local current_line = vim.fn.line(".")
							local total_line = vim.fn.line("$")
							return string.format("%.2f", current_line / total_line)
						end,
					},
					lualine_z = { "location" },
				}

				-- if vim.o.columns > 170 then
				-- 	table.insert(opts.sections.lualine_c, {
				-- 		gitblame.get_current_blame_text,
				-- 		-- gitblame.get_current_blame_text(), -- func or func call ok, apparently
				-- 		cond = gitblame.is_blame_text_available, -- cond must be a func, not bool!
				-- 	})
				-- end

				-- opts.message_when_not_committed = "  Not Committed Yet"
				-- opts.enabled = false

				opts.options = {
					-- message_when_not_committed = "  Not Committed Yet",

					component_separators = "|",
					icons_enabled = false,
					section_separators = "",
					theme = "auto", -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
				}
			end,
		}, -- }}}
		{ -- telescope {{{
			"nvim-telescope/telescope.nvim",
			dependencies = {
				-- https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions#different-plugins-with-telescope-integration

				"aznhe21/actions-preview.nvim",
				-- "rachartier/tiny-code-action.nvim",

				"AckslD/nvim-neoclip.lua", -- yank history; do i use this?
				"LukasPietzschmann/telescope-tabs", -- do i use this?
				"MaximilianLloyd/adjacent.nvim",
				"nvim-lua/plenary.nvim", -- backend
				"nvim-telescope/telescope-file-browser.nvim", -- netrw-like
				"rachartier/tiny-code-action.nvim", -- https://github.com/rachartier/tiny-code-action.nvim/issues/11
				-- "debugloop/telescope-undo.nvim", -- i don't really use this
				-- "fcying/telescope-ctags-outline.nvim",
				-- "nvim-telescope/telescope-ui-select.nvim", -- https://github.com/nvim-telescope/telescope-ui-select.nvim/issues/44
				-- "tsakirist/telescope-lazy.nvim",
				{ "crispgm/telescope-heading.nvim", ft = { "markdown" } }, -- headings in markdown
			},
		},

		-- {
		-- 	"nvim-telescope/telescope-fzf-native.nvim",
		-- 	build = "make",
		-- 	cond = function()
		-- 		return vim.fn.executable("make") == 1
		-- 	end,
		-- },
		-- }}}
		{ -- trouble {{{
			"folke/trouble.nvim",
			opts = {

				open_no_results = false,
				warn_no_results = false,

				height = 10,
				group = true, -- group results by file
				padding = false, -- don't add extra new line on top of the list
				cycle_results = true, -- cycle item list when reaching beginning or end of list
				action_keys = {
					close = { "<c-c>", "q" }, -- don't take action, close Trouble
					cancel = "x", -- don't take action, but leave Trouble open
					refresh = "R", -- manually refresh
					jump = "g", -- jump to the diagnostic (or open / close folds), without closing Trouble
					-- jump_close = { "<cr>" }, -- jump to the diagnostic and close the list
					open_tab = "T", -- open buffer in new tab
					open_tab_drop = "<cr>", -- https://github.com/folke/trouble.nvim/pull/374
					toggle_mode = "t", -- toggle between "workspace" and "document" diagnostics mode
					-- hover = "K", -- only useful if multiline = false
					preview = "p", -- preview the diagnostic location
					open_code_href = "c", -- if present, open a URI with more information about the diagnostic error
					close_folds = "zh", -- close all folds
					open_folds = "zl", -- open all folds
					toggle_fold = "Z", -- toggle fold of current file
					help = "?", -- help menu
				},
				multiline = true, -- render multi-line messages
				win_config = { border = "single" }, -- window configuration for floating windows. See |nvim_open_win()|.
				auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
				include_declaration = {
					"lsp_references",
					"lsp_implementations",
					"lsp_definitions",
				}, -- for the given modes, include the declaration of the current symbol in the results

				-- icons = false,
				fold_open = "v", -- icon used for open folds
				fold_closed = ">", -- icon used for closed folds
				indent_lines = false, -- add an indent guide below the fold icons
				use_diagnostic_signs = true, -- use the signs defined in lsp client
			},
		}, -- }}}
		{ -- navic {{{
			"SmiteshP/nvim-navic", -- context

			opts = {
				icons = {

					Function = "(f)",

					Constant = "c ",
					Field = "f ",
					Variable = "v ",

					Array = "[]",
					Null = "_",
					Number = "#",

					Boolean = "b ",
					Class = "c ",
					Constructor = "c ",
					Enum = "E ",
					EnumMember = "e ",
					Event = "ev ",
					File = "F ",
					Interface = "I ", -- trait
					Key = "k ",
					Method = "m ",
					Module = "M ",
					Namespace = "n ",
					Object = "O ", -- {}?
					Operator = "o ",
					Package = "P ",
					Property = "p ",
					String = "s ",
					Struct = "S ",
					TypeParameter = "t ",
				},

				-- separator = " > ",
				-- separator = ".",
				click = false,
				depth_limit = 0,
				depth_limit_indicator = "||",
				highlight = true,
				lazy_update_context = false,
				lsp = { auto_attach = true },
				safe_output = true,
				separator = " | ",
			},
		}, -- }}}
		{ -- git-blame {{{
			"f-person/git-blame.nvim",

			opts = {

				enabled = false,
				date_format = "%r",
				display_virtual_text = 1, -- display in statusline by default
				highlight_group = "Question",
				-- message_template = "[<summary> :: <date> :: <author>]",
				message_template = "<summary> | <date> | <author>",
				message_when_not_committed = "---",
				use_blame_commit_file_urls = true,
				-- virtual_text_column = 81,
			},
		}, -- }}}
		{ -- refactoring {{{
			"ThePrimeagen/refactoring.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
			config = function()
				require("refactoring").setup({

					-- https://github.com/ThePrimeagen/refactoring.nvim/tree/master/lua/refactoring/tests/debug/print_var/py/multiple-statements
					printf_statements = {
						python = {
							-- https://github.com/kentchiu/nvim-config/blob/d60768f59bfee285a26f24a3879f6b155a1c630c/lua/custom/plugins/refactory.lua#L69
							'print(f"🟥 %s")',
						},
					},
					print_var_statements = {
						python = {
							-- 'print(f"custom print_var %s {str(%s)}")',
							'print(f"🟥 %s {str(%s)}")',
						},
					},
					prompt_func_param_type = { python = true },
					prompt_func_return_type = { python = true },
					show_success_message = true,
				})
			end,
		}, -- }}}
		{ -- lspconfig {{{
			"neovim/nvim-lspconfig",
			dependencies = {

				"folke/neodev.nvim", -- for init.lua and plugin development only
				"williamboman/mason-lspconfig.nvim",
				-- "rcarriga/nvim-notify", -- does not affect fidget
				{ "j-hui/fidget.nvim", tag = "legacy", opts = {} }, -- status updates for LSP
				{
					"williamboman/mason.nvim",
					-- config = true,
					-- cmd = "Mason",
					opts = function(_, o)
						-- local icons = require("lib.icons")
						o.ui = {
							-- border = "rounded",
							width = 0.7,
							height = 0.7,
							-- icons = {
							-- 	package_installed = icons.package_manager.done_sym,
							-- 	package_pending = icons.package_manager.working_sym,
							-- 	package_uninstalled = icons.package_manager.removed_sym,
							-- },
							keymaps = {
								uninstall_package = "x",
								toggle_help = "?",
							},
						}
					end,
				},
				-- "https://github.com/Zeioth/mason-extra-cmds", -- MasonUpdateAll
			},
		}, -- }}}
		{ -- nvim-cmp {{{
			"hrsh7th/nvim-cmp", -- Autocompletion
			dependencies = {

				"L3MON4D3/LuaSnip", -- Snippet Engine (general?)
				"saadparwaiz1/cmp_luasnip", -- its associated nvim-cmp source

				"hrsh7th/cmp-buffer", -- buffer text
				"hrsh7th/cmp-nvim-lsp", -- LSP completion
				"hrsh7th/cmp-path", -- file paths

				-- "norcalli/snippets.nvim",
				"rafamadriz/friendly-snippets", -- user-friendly snippets
			},
		}, -- }}}

		{ -- gitsigns {{{
			"lewis6991/gitsigns.nvim",
			opts = {
				-- See `:help gitsigns.txt`
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
			},
		}, -- }}}
		{
			"nvimdev/indentmini.nvim",
			opts = {
				char = "▎",
				only_current = true, -- otherwise show all indents
			},
		},
		-- { -- indent-blankline {{{
		-- 	-- dims the current indent when you are inside a block, otherwise
		-- 	-- highlights all indents at the "same level" (e.g. when you are on an
		-- 	-- `if`); this is quite weird/unintuitive, now that i think about it
		-- 	"lukas-reineke/indent-blankline.nvim",
		-- 	-- https://github.com/lukas-reineke/indent-blankline.nvim/wiki/Migrate-to-version-3
		-- 	main = "ibl",
		-- 	-- See `:help indent_blankline.txt`
		-- 	opts = {
		-- 		-- char = "┊",
		-- 		-- show_trailing_blankline_indent = false,
		-- 		-- show_current_context = true,
		-- 		-- show_current_context_start = true,
		-- 	},
		-- }, -- }}}
		{ -- treesitter {{{
			"nvim-treesitter/nvim-treesitter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects", -- textobjects at the function/class level (e.g. :norm daf)
				-- "JoosepAlviste/nvim-ts-context-commentstring", -- context-aware comment char, e.g. markdown embed?
				{ "danymat/neogen", config = true }, -- docs generator
			},
			build = ":TSUpdate",
			lazy = false,
		}, -- }}}
		-- colorschemes {{{

		-- many colorschemes don't highlight diffs properly -- this is the fault of the colorscheme, not treesitter
		-- ack -i diffadd ~/.local/share/nvim/lazy/
		-- find ~/.local/share/nvim/lazy/ -name '*lua' | \xargs ack 'text.diff.add'
		-- find ~/.local/share/nvim/lazy/ | grep -P '/colors/.+(vim|lua)' | sort
		-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3701#issuecomment-1288166768

		"oxfist/night-owl.nvim", -- no name
		"paulo-granthon/hyper.nvim",
		"volbot/voltrix.vim",
		-- "yorumicolors/yorumi.nvim", -- low contrast
		"zootedb0t/citruszest.nvim",
		-- https://github.com/topics/neovim-theme?l=lua&o=desc&s=updated
		-- https://vimcolorschemes.com/i/new/b.dark
		-- }}}
	},

	{ -- config {{{
		-- https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
		-- https://github.com/ecosse3/nvim/blob/e8418eb65af4471891ea9a5b74a94205804c49aa/lua/config/lazy.lua#L14C41-L34C2
		checker = {
			enabled = true,
			notify = false,
		},
		-- defaults = { lazy = true },
		install = {
			missing = true,
			-- colorscheme = { "tokyonight" },
		},
		-- performance = {
		-- 	rtp = {
		-- 		disabled_plugins = {
		-- 			"gzip",
		-- 			"netrwPlugin",
		-- 			"tarPlugin",
		-- 			"tohtml",
		-- 			"tutor",
		-- 			"zipPlugin",
		-- 		},
		-- 	},
		-- },
		-- debug = false,
		-- ui = {
		-- 	border = EcoVim.ui.float.border,
		-- },
	} -- }}}
)

-- nvim-tree - might remove {{{
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- require("nvim-tree").setup({
-- 	-- maybe this will get me to be less reliant on ranger...
-- 	-- TODO: open in tab
-- 	-- https://github.com/alex-courtis/arch/blob/b5f24e0e7b6554b338e40b3d60f1be437f273023/config/nvim/lua/amc/nvim-tree.lua
-- 	-- create_in_closed_folder = true,
-- 	hijack_cursor = false,
-- 	-- open_on_setup = true,
-- 	-- open_on_setup_file = true,
-- 	-- focus_empty_on_setup = true,
-- 	sync_root_with_cwd = true,
-- 	view = {
-- 		adaptive_size = false,
-- 		-- mappings = {
-- 		-- 	list = {
-- 		-- 		{ key = { "<2-RightMouse>", "<C-]>" }, action = "" }, -- cd
-- 		-- 		{ key = "<C-v>", action = "" }, -- vsplit
-- 		-- 		{ key = "<C-x>", action = "" }, -- split
-- 		-- 		{ key = "<C-t>", action = "" }, -- tabnew
-- 		-- 		{ key = "<BS>", action = "" }, -- close_node
-- 		-- 		{ key = "<Tab>", action = "" }, -- preview
-- 		-- 		{ key = "D", action = "" }, -- trash
-- 		-- 		{ key = "[e", action = "" }, -- prev_diag_item
-- 		-- 		{ key = "]e", action = "" }, -- next_diag_item
-- 		-- 		{ key = "[c", action = "" }, -- prev_git_item
-- 		-- 		{ key = "]c", action = "" }, -- next_git_item
-- 		-- 		{ key = "-", action = "" }, -- dir_up
-- 		-- 		{ key = "s", action = "" }, -- system_open
-- 		-- 		{ key = "W", action = "" }, -- collapse_all
-- 		-- 		{ key = "g?", action = "" }, -- toggle_help
-- 		--
-- 		-- 		{ key = "d", action = "cd" }, -- remove
-- 		-- 		{ key = "x", action = "remove" }, -- cut
-- 		--
-- 		-- 		{ key = "t", action = "cut" },
-- 		-- 		{ key = "<Space>p", action = "prev_diag_item" },
-- 		-- 		{ key = "<Space>.", action = "next_diag_item" },
-- 		-- 		{ key = "<Space>k", action = "prev_git_item" },
-- 		-- 		{ key = "<Space>j", action = "next_git_item" },
-- 		-- 		{ key = "u", action = "dir_up" },
-- 		-- 		{ key = "'", action = "close_node" },
-- 		-- 		{ key = '"', action = "collapse_all" },
-- 		-- 		{ key = "?", action = "toggle_help" },
-- 		-- 	},
-- 		-- },
-- 	},
-- 	renderer = {
-- 		full_name = true,
-- 		group_empty = true,
-- 		special_files = {},
-- 		symlink_destination = false,
-- 		indent_markers = {
-- 			enable = true,
-- 		},
-- 		icons = {
-- 			git_placement = "signcolumn",
-- 			show = {
-- 				file = true,
-- 				folder = false,
-- 				folder_arrow = false,
-- 				git = true,
-- 			},
-- 		},
-- 	},
-- 	update_focused_file = {
-- 		enable = true,
-- 		update_root = true,
-- 		ignore_list = { "help" },
-- 	},
-- 	diagnostics = {
-- 		enable = true,
-- 		show_on_dirs = true,
-- 	},
-- 	filters = {
-- 		custom = {
-- 			"^.git$",
-- 		},
-- 	},
-- 	actions = {
-- 		change_dir = {
-- 			enable = false,
-- 			restrict_above_cwd = true,
-- 		},
-- 		open_file = {
-- 			resize_window = true,
-- 			window_picker = {
-- 				chars = "aoeui",
-- 			},
-- 		},
-- 		remove_file = {
-- 			close_window = false,
-- 		},
-- 	},
-- 	log = {
-- 		enable = false,
-- 		truncate = true,
-- 		types = {
-- 			all = false,
-- 			config = false,
-- 			copy_paste = false,
-- 			diagnostics = false,
-- 			git = false,
-- 			profile = false,
-- 			watcher = false,
-- 		},
-- 	},
-- }) -- }}}
-- require("symbols-outline").setup({ -- {{{
-- 	-- https://github.com/simrat39/symbols-outline.nvim#configuration
-- 	highlight_hovered_item = true, -- only for hover in main, high cpu usage
-- 	show_guides = true,
-- 	auto_preview = false, -- ugly
-- 	position = "right", -- not ideal for narrow screens
-- 	relative_width = true,
-- 	width = 25,
-- 	auto_close = false,
-- 	-- show_numbers = false,
-- 	-- show_relative_numbers = false,
-- 	-- show_symbol_details = true,
-- 	preview_bg_highlight = "Pmenu",
-- 	autofold_depth = nil,
-- 	auto_unfold_hover = true,
-- 	fold_markers = { "", ">" },
-- 	wrap = false,
-- 	keymaps = {
-- 		close = { "<Esc>", "q" },
-- 		goto_location = "<Cr>",
-- 		focus_location = "o",
-- 		hover_symbol = "<C-space>",
-- 		toggle_preview = "K",
-- 		rename_symbol = "R",
-- 		code_actions = "a",
-- 		fold = "h",
-- 		unfold = "l",
-- 		fold_all = "H",
-- 		unfold_all = "L",
-- 		fold_reset = "z",
-- 	},
-- 	lsp_blacklist = {},
-- 	symbol_blacklist = {},
-- 	symbols = {
--
-- 		Array = { icon = "array", hl = "@constant" },
-- 		Boolean = { icon = "bool", hl = "@boolean" },
-- 		Class = { icon = "class", hl = "@type" },
-- 		Component = { icon = "component", hl = "@function" },
-- 		Constant = { icon = "const", hl = "@constant" },
-- 		Constructor = { icon = "constructor", hl = "@constructor" },
-- 		Enum = { icon = "enum", hl = "@type" },
-- 		Enummember = { icon = "enum_mem", hl = "@field" },
-- 		Event = { icon = "event", hl = "@type" },
-- 		Field = { icon = "field", hl = "@field" },
-- 		File = { icon = "file", hl = "@text.uri" },
-- 		Fragment = { icon = "fragment", hl = "@constant" },
-- 		Function = { icon = "func", hl = "@function" },
-- 		Interface = { icon = "interface", hl = "@type" },
-- 		Key = { icon = "key", hl = "@type" },
-- 		Method = { icon = "method", hl = "@method" },
-- 		Module = { icon = "module", hl = "@namespace" },
-- 		Namespace = { icon = "namespace", hl = "@namespace" },
-- 		Null = { icon = "null", hl = "@type" },
-- 		Number = { icon = "num", hl = "@number" },
-- 		Object = { icon = "obj", hl = "@type" },
-- 		Operator = { icon = "op", hl = "@operator" },
-- 		Package = { icon = "package", hl = "@namespace" },
-- 		Property = { icon = "prop", hl = "@method" },
-- 		String = { icon = "str", hl = "@string" },
-- 		Struct = { icon = "struct", hl = "@type" },
-- 		Typeparameter = { icon = "type_param", hl = "@parameter" },
-- 		Variable = { icon = "var", hl = "@constant" },
-- 	},
-- }) -- }}}

require("illuminate").configure({ providers = { "lsp", "treesitter" }, under_cursor = true })
require("neoclip").setup()
require("neodev").setup()
require("project_nvim").setup()
require("treesj").setup({})

require("nvim-lightbulb").setup({
	autocmd = { enabled = true },
	sign = {
		-- may distract from gitsigns
		enabled = true,
		text = "!",
		-- text = "ⓘ",
	},
	float = {
		enabled = false, -- messes with diagnostic floats (esp in rust)
		-- text = "!",
		text = "ⓘ",
		hl = "LightBulbFloatWin", -- Highlight group to highlight the floating window.
		win_opts = { focusable = false },
	},
})

local navic = require("nvim-navic")
require("lualine").setup({
	winbar = {
		lualine_c = {
			{
				function()
					return navic.get_location()
				end,
				cond = function()
					return navic.is_available()
				end,
			},
		},
	},
})

-- https://github.com/f-person/git-blame.nvim/blob/master/lua/gitblame/config.lua
vim.g.gitblame_message_when_not_committed = ""
vim.g.gitblame_message_template = "<author>: <summary> (<sha> <date>)"
-- vim.g.gitblame_date_format = "%r | %Y-%m-%d %H:%M:%S"
vim.g.gitblame_date_format = "%Y-%m-%d %H:%M"
vim.g.gitblame_virtual_text_column = 80

if vim.o.columns > 170 then
	-- must be enabled here, apparently
	vim.cmd("GitBlameEnable")
	-- displaying blame in inlay is annoying, but displaying in lualine is arguably
	-- worse because the latency appears to be higher (~1s), which means you won't
	-- know which line the current blame refers to
	vim.g.gitblame_display_virtual_text = 1
end

require("lsp_signature").setup()
-- print(vim.inspect(require("chezmoi.commands").list()))
