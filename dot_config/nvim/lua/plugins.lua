-- Lazy Startuptime should remain under 200 ms
-- (need a few good benchmark files, e.g. md, py, sh)

-- :Lazy profile, filter > 10 ms

local columns = 120 -- lualine, git-blame

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

		"aymericbeaumet/vim-symlink", -- TODO: can this just be an autocmd?
		"mfussenegger/nvim-lint",
		"romainl/vim-cool", -- clear highlight after search
		"stevearc/conform.nvim",
		"tpope/vim-fugitive",
		"tpope/vim-repeat",
		"tpope/vim-surround",
		-- "tpope/vim-sleuth", -- detect tabstop and shiftwidth automatically; disabled because it has unexpected side effects
		{ "akinsho/git-conflict.nvim", version = "*", opts = {} },
		{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
		{ "numtostr/comment.nvim", opts = {} }, -- replaces vim-commentary

		-- }}}

		"martineausimon/nvim-lilypond-suite",
		"yochem/jq-playground.nvim",

		-- { "tadmccorkle/markdown.nvim", ft = "markdown", opts = { mappings = false } }, -- https://github.com/tadmccorkle/markdown.nvim?tab=readme-ov-file#usage
		{ "ecridge/vim-kinesis", ft = "kinesis" }, -- KA2, *_qwerty.txt
		{ "jbyuki/quickmath.nvim", cmd = { "Quickmath" } },
		{ "johnelliott/vim-kinesis-kb900", ft = "kb900" }, -- KA FP (and 360?), layout*.txt
		{ "mbbill/undotree", cmd = { "UndoTreeToggle" } },
		{ "rhysd/vim-go-impl", ft = "go" }, -- :GoImpl m Model tea.Model (requires https://github.com/josharian/impl)
		{ "tpope/vim-dispatch", cmd = { "Dispatch", "Make" } }, -- run async processes
		{ "tpope/vim-dotenv", cmd = { "Dotenv" } },
		{ "tridactyl/vim-tridactyl", ft = "tridactyl" }, -- syntax highlighting
		{ "wansmer/treesj", opts = {}, cmd = { "TSJToggle", "TSJSplit", "TSJJoin" } }, -- very slow

		{
			"norcalli/nvim-colorizer.lua",
			config = function()
				require("colorizer").setup()
			end,
		},

		{
			"devkvlt/go-tags.nvim",
			ft = "go",
			enabled = vim.fn.executable("gomodifytags"),
			config = function()
				require("go-tags").setup({
					commands = {
						["GoTagsAddJSON"] = { "-add-tags", "json" },
						["GoTagsRemoveJSON"] = { "-remove-tags", "json" },
					},
				})
			end,
		},

		{
			"jinh0/eyeliner.nvim", -- replaces quick-scope
			config = function()
				require("eyeliner").setup({ highlight_on_key = false })
			end,
		},

		{
			"ray-x/lsp_signature.nvim",
			lazy = true,
			-- event = "LspAttach", -- the config func will NOT be run (properly), so using an event is pointless
			-- config = function()
			-- 	require("lsp_signature").setup({
			-- 		on_attach = function(_, bufnr)
			-- 			require("lsp_signature").on_attach({}, bufnr)
			-- 		end,
			-- 	})
			-- end,
		},

		-- -- uses deprecated vim.lsp.buf_get_clients
		-- {
		-- 	-- cd to repo root (else autochdir), most useful for go
		-- 	-- note: opts={} is not always equivalent to config=function()require'foo'.setup({})end, apparently
		-- 	"ahmedkhalf/project.nvim",
		-- 	config = function()
		-- 		require("project_nvim").setup({})
		-- 	end,
		-- },

		{
			"lervag/vimtex",
			ft = { "tex", "bib" },
			enabled = vim.bo.filetype == "tex" and not vim.loop.fs_stat("Tectonic.toml"),
		},

		{
			"windwp/nvim-ts-autotag",
			ft = { "html", "javascriptreact", "typescriptreact" },
			config = function()
				require("nvim-ts-autotag").setup({
					opts = {
						enable_close = true, -- Auto close tags
						enable_rename = true, -- Auto rename pairs of tags
						enable_close_on_slash = false, -- Auto close on trailing </
					},
				})
			end,
		},

		{
			"FabijanZulj/blame.nvim",
			lazy = false,
			config = function()
				require("blame").setup({
					date_format = "%Y-%m-%d",
					virtual_style = "right_align",
					-- views = {
					-- 	window = window_view,
					-- 	virtual = virtual_view,
					-- 	default = window_view,
					-- },
					focus_blame = true,
					merge_consecutive = true,
					max_summary_width = 30,
					colors = nil,
					blame_options = nil,
					commit_detail_view = "vsplit",
					-- format_fn = formats.commit_date_author_fn,
					mappings = {
						commit_info = "i",
						stack_push = "h", -- back in history
						stack_pop = "l", -- forward
						show_commit = "I",
						close = { "<esc>", "q" },
					},
				})
			end,
		},

		{
			"xvzc/chezmoi.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("chezmoi").setup({
					edit = {
						watch = true, -- automatically apply on save.
						force = true, -- force apply. Works only when watch = true.
					},
					notification = {
						on_open = true,
						on_apply = false,
						on_watch = true, -- "This file will be automatically applied"; requires on_open = true
					},
				})
			end,
		},

		-- {
		-- 	"oxy2dev/markview.nvim",
		-- 	cmd = { "Markview" },
		-- 	config = function()
		-- 		require("markview").setup({ initial_state = true })
		-- 		vim.cmd("Markview")
		-- 		-- vim.cmd("Markview disableAll")
		-- 	end,
		-- },

		{ -- mason-null-ls {{{
			-- https://roobert.github.io/2022/12/03/Extending-Neovim/#neovim-plugins-which-solve-problems
			--
			-- afaik, mason-null-ls is essentially only for installing everything
			-- automatically (mason's ensure_installed only applies to lsps). this is
			-- not essential, but nice to have
			--
			-- null-ls has been deprecated, and is now replaced by none-ls
			--
			-- https://github.com/jjangsangy/Dotfiles/blob/a96a66b1b3db191a848daed2f3f2ff498a1e96ad/astro_nvim/plugins/mason.lua#L15
			"jay-babu/mason-null-ls.nvim",
			-- overrides `require("mason-null-ls").setup(...)`
			dependencies = {
				-- "jose-elias-alvarez/null-ls.nvim", -- uses deprecated vim.tbl_add_reverse_lookup
				"nvimtools/none-ls.nvim",
			},
			opts = {
				ensure_installed = {

					-- formatters

					"biome",
					"gofumpt",
					"goimports", -- required for autoimport (reviser only performs grouping)
					"goimports-reviser",
					"golines",
					"mdslw",
					"prettier", -- for html/yaml, iirc?
					"shfmt",
					"stylua",

					-- linters

					"gitlint",
					"golangci-lint",
					"markdownlint",
					"ruff",
					-- "shellcheck",
				},

				--
			},
		}, -- }}}
		{ -- lualine {{{
			-- https://github.com/nvim-lualine/lualine.nvim#default-configuration
			"nvim-lualine/lualine.nvim",

			opts = function(_, opts)
				-- local gitblame = require("gitblame")

				opts.sections = {

					-- https://github.com/nvim-lualine/lualine.nvim#available-components
					-- https://github.com/nvim-lualine/lualine.nvim#component-specific-options

					lualine_a = {
						-- "branch",
						function()
							local f = function(cmd)
								return require("util"):get_command_output(cmd, true)
							end

							local branch = f("git branch --show-current")
							local ahead_m = f([[git rev-list --left-right --count "origin/master...HEAD" | cut -f2]])
							local ahead_b =
								f(string.format([[git rev-list --left-right --count "%s...HEAD" | cut -f2]], branch))

							if ahead_m == "0" then
								return branch
							elseif ahead_b == "0" then
								return branch .. string.format("[m+%s]", ahead_m)
							else
								return branch .. string.format("[m+%s|b+%s]", ahead_m, ahead_b)
							end
						end,
					},

					lualine_b = {
						{ "diagnostics", sources = { "nvim_workspace_diagnostic" } },
					},

					lualine_c = {
						{
							function()
								if vim.fn.expand("%") == "" then
									return "[new file]"
								end
								return vim.fn.expand("%" .. (vim.o.columns > columns and ":p" or ""))
							end,
						},

						{
							function()
								if vim.fn.expand("%") == "" then
									return ""
								end
								return string.format("%sL", vim.fn.line("$"))
							end,
						},

						{
							"diff",
							-- https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets#using-external-source-for-diff
							colored = false, -- colors are usually unsightly against bg
							source = function()
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
					},

					lualine_x = {},

					lualine_y = { "encoding", "fileformat", "filetype" },

					lualine_z = {
						-- "progress",
						-- "location",
						function() -- "0.04 n"
							local current_line = vim.fn.line(".")
							local total_line = vim.fn.line("$")
							return string.format("%.2f %s", current_line / total_line, vim.fn.mode())
							-- return vim.fn.mode()
						end,
					},
				}

				opts.winbar = {
					lualine_c = {
						{
							function()
								return require("nvim-navic").get_location()
							end,
							cond = function()
								return require("nvim-navic").is_available()
							end,
						},
					},
				}

				opts.tabline = {
					lualine_a = {

						-- {
						-- 	"buffers",
						-- 	-- show_filename_only = false, -- truncated dirs usually not useful
						-- 	mode = 2,
						-- },

						-- replaces native tab bar
						{
							"tabs", -- more configurable than buffers

							-- tab_max_length = 40, -- cannot be a func
							max_length = function()
								-- ensure tab bar is dynamically resized
								return vim.o.columns
							end,
							mode = 2, -- tab_nr + tab_name

							path = 0, -- only basename

							use_mode_colors = false,

							show_modified_status = false,

							-- symbols = {
							-- 	modified = "[+]", -- Text to show (left of fname) when the file is modified.
							-- },

							-- TODO: determine (sub)repo

							fmt = function(name, context)
								-- Show + if buffer is modified in tab
								local buflist = vim.fn.tabpagebuflist(context.tabnr)
								local winnr = vim.fn.tabpagewinnr(context.tabnr)
								local bufnr = buflist[winnr]
								local mod = vim.fn.getbufvar(bufnr, "&mod")
								return name .. (mod == 1 and " +" or "")
							end,
						},
					},
				}

				opts.options = {
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

				"LukasPietzschmann/telescope-tabs", -- do i use this?
				"nvim-lua/plenary.nvim", -- backend
				"nvim-telescope/telescope-file-browser.nvim", -- netrw-like
				"nvim-telescope/telescope-frecency.nvim",
				-- "MaximilianLloyd/adjacent.nvim",
				-- "aznhe21/actions-preview.nvim", -- https://github.com/aznhe21/actions-preview.nvim/issues/54
				-- "fcying/telescope-ctags-outline.nvim",
				-- "nvim-telescope/telescope-ui-select.nvim", -- https://github.com/nvim-telescope/telescope-ui-select.nvim/issues/44
				-- "rachartier/tiny-code-action.nvim",
				-- "tsakirist/telescope-lazy.nvim",
				{ "AckslD/nvim-neoclip.lua", opts = {} }, -- yank history; do i use this?
				{ "crispgm/telescope-heading.nvim", ft = "markdown" }, -- headings in markdown
				{ "hejops/adjacent.nvim", branch = "ignore-binary" },
			},
		},

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
					Method = "m ",

					Constant = "c ",
					Field = "f ",
					Variable = "v ",

					-- types
					Array = "[]",
					Boolean = "b ",
					Enum = "E ",
					EnumMember = "e ",
					Null = "_",
					Number = "#",
					Object = "{} ",
					String = "s ",

					Class = "C ",
					Constructor = "con ",
					Event = "ev ",
					File = "F ",
					Interface = "I ", -- trait
					Key = "k ",
					Module = "M ",
					Namespace = "N ",
					Operator = "o ",
					Package = "P ",
					Property = "p ",
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
				-- https://github.com/f-person/git-blame.nvim/blob/master/lua/gitblame/config.lua

				-- date_format = "%r | %Y-%m-%d %H:%M:%S"
				-- highlight_group = "Question",
				date_format = "%Y-%m-%d %H:%M",
				delay = 0,
				enabled = vim.o.columns > columns,
				message_template = "<author>: <summary> (<sha> <date>)",
				message_when_not_committed = "-",
				use_blame_commit_file_urls = true,
				virtual_text_column = 81, -- should be hl + 1 (2?)

				-- displaying blame in inlay is annoying, but displaying in lualine is
				-- arguably worse because the latency appears to be higher (~1s), which
				-- means you won't know which line the current blame refers to
				display_virtual_text = 1,
			},
		}, -- }}}
		{ -- lspconfig {{{
			"neovim/nvim-lspconfig",
			dependencies = {

				"williamboman/mason-lspconfig.nvim",
				{ "folke/neodev.nvim", opts = {} }, -- for init.lua only
				{ "j-hui/fidget.nvim", opts = {}, event = "LspAttach" }, -- status updates for LSP
				{
					"kosayoda/nvim-lightbulb",
					event = "LspAttach",
					opts = {
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
					},
				}, -- alert for possible code actions

				{
					"williamboman/mason.nvim",
					-- cmd = "Mason",
					opts = function(_, o)
						o.ui = {
							-- border = "rounded",
							width = 0.7,
							height = 0.7,
							keymaps = { uninstall_package = "x", toggle_help = "?" },
						}
					end,
				},
				-- "https://github.com/Zeioth/mason-extra-cmds", -- MasonUpdateAll
			},

			-- -- https://github.com/jellydn/ts-inlay-hints?tab=readme-ov-file#neovim-settings
			-- opts = {
			-- 	inlay_hints = { enabled = true },
			-- },
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
				"cassin01/cmp-gitcommit",
			},
		}, -- }}}
		{ -- nvim-dap {{{
			"mfussenegger/nvim-dap",
			dependencies = {
				"mfussenegger/nvim-dap-python",
				"thehamsta/nvim-dap-virtual-text",
			},
			ft = { "python" },
			config = function()
				-- https://github.com/mfussenegger/dotfiles/blob/da93d1f7f52ea50b00199696a6977dd70a84736e/vim/dot-config/nvim/lua/me/dap.lua

				local dap = require("dap")

				-- vim.keymap.set({ "n", "v" }, "<leader>dh", require("dap.ui.widgets").hover)
				vim.keymap.set("n", "<leader>dj", dap.continue)
				vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint)
				-- vim.keymap.set({ "n", "v" }, "<leader>dp", require("dap.ui.widgets").preview)

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
			end,
		}, -- }}}
		{ -- nvim-dbee {{{
			"kndndrj/nvim-dbee",

			-- + api is quite hackable
			-- + implements pagination (good for large queries)
			-- + query execution is async
			-- + query history
			-- + query results are copied as json
			-- - BB is a silly default binding to execute query (fixable?)
			-- - executing a query always focuses the result pane (see PR)
			-- - i dislike the 4-pane gui
			-- - table schema cannot really be viewed? (sqlite)

			ft = { "sql" },
			dependencies = { "MunifTanjim/nui.nvim" },
			build = function()
				require("dbee").install()
			end,
			config = function()
				-- https://github.com/kndndrj/nvim-dbee/blob/master/doc/dbee.txt#L136
				require("dbee").setup({

					sources = {
						require("dbee.sources").MemorySource:new(require("util"):dbee_connections()),
						-- require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
						-- require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
					},

					editor = {
						mappings = { { key = "BB", mode = "", action = "" } },
					},

					result = {
						focus_result = false,
						page_size = 10,
						mappings = { { key = "<c-c>", mode = "", action = "cancel_call" } },
					},

					-- -- https://github.com/MishimaPorte/asu-dotfiles/blob/09f5280e/.config/nvim/lua/plgs/dbee.lua#L148
					-- ui = {
					-- 	window_open_order = { "editor", "result", "drawer" },
					-- },

					-- https://github.com/kndndrj/nvim-dbee/blob/21d2cc08/lua/dbee/layouts/init.lua#L44
					window_layout = require("dbee.layouts").Default:new({
						result_height = 11, -- not dynamic!
						call_log_height = 0,
						drawer_width = 0,
					}),
				})

				local c = require("dbee").api.core.get_current_connection()
				if c then
					print(string.format("dbee: connected to database %s (%s)", c.name, c.url))
				else
					print("dbee: no connection")
				end
			end,
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
		{ -- indentmini {{{
			"nvimdev/indentmini.nvim",
			opts = {
				char = "▎",
				only_current = true, -- otherwise show all indents
			},
		}, -- }}}
		{ -- treesitter {{{
			-- in case of breakage on ubuntu, remove and reinstall snap package

			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate", -- update parsers when updating plugin
			lazy = false, -- causes all dependencies to be loaded

			dependencies = {

				{
					-- highlight symbol under cursor
					"rrethy/vim-illuminate",
					config = function()
						require("illuminate").configure({
							providers = {
								-- can be slow if only lsp; lsp+treesitter is faster than just lsp, for some reason
								"lsp", -- 11.1 s (md)
								"treesitter", -- 7.4 s
							},
							under_cursor = true,
						})
					end,
				},

				"nvim-treesitter/nvim-treesitter-textobjects", -- textobjects at the function/class level (e.g. :norm daf)
				{ "danymat/neogen", opts = {} }, -- docs generator
			},

			config = function()
				require("nvim-treesitter.configs").setup({

					-- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Extra-modules-and-plugins#extra-modules
					modules = {},
					ignore_install = {},

					-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3579#issuecomment-1278662119
					sync_install = #vim.api.nvim_list_uis() == 0,

					-- TODO: https://github.com/nwhetsell/tree-sitter-lilypond

					ensure_installed = {
						-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages

						"bash",
						"css",
						"csv",
						"diff",
						"gitcommit",
						"gitignore",
						"go",
						"gomod",
						"gosum",
						"html",
						"htmldjango",
						"javascript",
						"jsdoc",
						"json",
						"jsonc",
						"lua",
						"markdown",
						"markdown_inline",
						"muttrc",
						"python",
						"rasi",
						"rust",
						"sql",
						"toml",
						"typescript",
						"vim",
						"vimdoc",
						"yaml",
						"zig",
						-- "latex", -- requires tree-sitter-cli
						-- "scheme",
					},

					auto_install = false, -- if true, parsers will be force-installed every time
					highlight = { enable = true }, -- https://github.com/nvim-treesitter/nvim-treesitter#highlight
					indent = { enable = true },

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
								-- note: for md sections, use tadmccorkle
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
						-- swap = {
						-- 	-- only works in params, not data structures (e.g. arrays)
						-- 	--
						-- 	-- in python, swapping args is never necessary, as params should always
						-- 	-- be specified as keywords (not positionally)
						-- 	enable = true,
						-- 	swap_next = {
						-- 		["[]"] = "@parameter.inner",
						-- 		["gsj"] = "@function.outer",
						-- 	},
						-- 	swap_previous = {
						-- 		["]["] = "@parameter.inner",
						-- 		["gsk"] = "@function.outer",
						-- 	},
						-- },
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

				vim.cmd.set("foldexpr=nvim_treesitter#foldexpr()") -- https://www.jmaguire.tech/img/code_folding.png

				-- local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
				--
				-- -- -- Repeat TS movements with ; and ,
				-- -- -- ensure ; goes forward and , goes backward regardless of the last direction
				-- -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
				-- -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
				--
				-- -- vim way: ; goes to the direction you were moving.
				-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
				-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
				--
				-- -- the above keymaps make fFtT non-repeatable; correct that
				-- vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
				-- vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
				-- vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
				-- vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
			end,
		},
		{
			-- TS-aware commentstring (slow)
			"joosepalviste/nvim-ts-context-commentstring",
			ft = {
				"javascript",
				"javascriptreact",
				-- "typescript",
				"typescriptreact",
			},
			config = function()
				-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#commentnvim
				require("ts_context_commentstring").setup({ enable_autocmd = false })
				local h = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
				require("Comment").setup({ pre_hook = h })
			end,
		}, -- }}}
		-- colorschemes {{{

		{
			"zootedb0t/citruszest.nvim",
			lazy = true,
			config = function()
				require("citruszest").setup({
					option = {
						transparent = false,
						bold = false,
						italic = false,
					},
				})
			end,
		},

		{ "bluz71/vim-moonfly-colors", lazy = true }, -- pub and fn same color
		{ "iagorrr/noctis-high-contrast.nvim", lazy = true }, -- italic comments/types
		{ "ingsme/nvim-smyck.nvim", lazy = true }, -- 'hybrid', italic comments
		{ "tomasr/molokai", lazy = true }, -- italic types/funcs, bold keywords
		{ "uncleten276/dark_flat.nvim", lazy = true }, -- italic comments

		{
			"judaew/ronny.nvim",
			lazy = true,
			enabled = vim.fn.executable("git-lfs"), --  TODO: https://stackoverflow.com/a/42021818
		},

		-- "abstract-ide/abstract-cs", -- unreadable comments
		-- "ajmwagar/vim-deus", -- mono tabline
		-- "chriskempson/vim-tomorrow-theme", -- mono tabline
		-- "crusoexia/vim-monokai", -- mid contrast
		-- "danilo-augusto/vim-afterglow", -- mono tabline
		-- "dasupradyumna/midnight.nvim", -- mono tabline
		-- "dgox16/oldworld.nvim", -- inactive tab too dim
		-- "ellisonleao/gruvbox.nvim", -- mid contrast
		-- "everblush/nvim", -- comments too dim
		-- "fenetikm/falcon", -- mono tabline
		-- "gosukiwi/vim-atom-dark", -- bad lualine
		-- "hachy/eva01.vim", -- don't like the low contrast one
		-- "honamduong/hybrid.nvim", -- mid contrast (name conflicts with nvim-smyck)
		-- "jaredgorski/spacecamp", -- bad lualine
		-- "kvrohit/rasmus.nvim", -- mono tabline
		-- "lighthaus-theme/vim-lighthaus", -- mono tabline
		-- "martinsione/darkplus.nvim", -- tab/lualine too bright
		-- "mellow-theme/mellow.nvim", -- everything is purple
		-- "mofiqul/dracula.nvim", -- bad at highlighting comment
		-- "nvimdev/oceanic-material", -- mono tabline
		-- "oxfist/night-owl.nvim", -- mono tabline
		-- "pauchiner/pastelnight.nvim", -- inlay hints too dark
		-- "paulo-granthon/hyper.nvim", -- blue against black
		-- "polirritmico/monokai-nightasty.nvim", -- line column too dim
		-- "ray-x/aurora", -- mid contrast
		-- "rockyzhang24/arctic.nvim", -- requires lush
		-- "sjl/badwolf", -- mono tabline
		-- "srijs/vim-colors-rusty", -- not matched by regex
		-- "tiagovla/tokyodark.nvim", -- comment too dim
		-- "tomasiser/vim-code-dark", -- mid contrast
		-- "vague2k/vague.nvim", -- bad contrast
		-- "volbot/voltrix.vim", -- mono tabline
		-- "w0ng/vim-hybrid", -- mono tabline
		-- "xero/miasma.nvim", -- nauseating
		-- "yorickpeterse/autumn.vim", -- mono tabline
		-- "yorickpeterse/happy_hacking.vim", -- mono tabline
		-- "yorumicolors/yorumi.nvim", -- low contrast
		-- { "bluz71/vim-moonfly-colors", lazy = true }, -- italic comments
		-- { "challenger-deep-theme/vim", lazy = true }, -- mid contrast
		-- { "morhetz/gruvbox", lazy = true }, -- has bold
		-- { "nanotech/jellybeans.vim", lazy = true }, -- mid contrast
		-- { "nlcodes/my_nvim_config", lazy = true }, -- mono tabline
		-- { "shawilly/ponokai", lazy = true }, -- mid contrast

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
