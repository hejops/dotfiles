-- Lazy Startuptime should remain under 200 ms
-- (need a few good benchmark files, e.g. md, py, sh)

-- :Lazy profile, filter > 10 ms

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
		"tpope/vim-sleuth", -- detect tabstop and shiftwidth automatically
		"tpope/vim-surround",
		{ "akinsho/git-conflict.nvim", version = "*", opts = {} },
		{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
		{ "numtostr/comment.nvim", opts = {} }, -- replaces vim-commentary

		-- }}}

		{ "ecridge/vim-kinesis", ft = "kinesis" }, -- KA2, *_qwerty.txt
		{ "jbyuki/quickmath.nvim", cmd = { "Quickmath" } },
		{ "johnelliott/vim-kinesis-kb900", ft = "kb900" }, -- KA FP (and 360?), layout*.txt
		{ "mbbill/undotree", cmd = { "UndoTreeToggle" } },
		{ "rhysd/vim-go-impl", ft = "go" }, -- :GoImpl m Model tea.Model (requires https://github.com/josharian/impl)
		{ "tadmccorkle/markdown.nvim", ft = "markdown", opts = { mappings = false } }, -- https://github.com/tadmccorkle/markdown.nvim?tab=readme-ov-file#usage
		{ "tpope/vim-dispatch", cmd = { "Dispatch", "Make" } }, -- run async processes
		{ "tpope/vim-dotenv", cmd = { "Dotenv" } },
		{ "tridactyl/vim-tridactyl", ft = "tridactyl" }, -- syntax highlighting
		{ "wansmer/treesj", opts = {}, cmd = { "TSJToggle", "TSJSplit", "TSJJoin" } }, -- very slow

		{
			"jinh0/eyeliner.nvim", -- replaces quick-scope
			config = function()
				require("eyeliner").setup({ highlight_on_key = false })
			end,
		},

		{
			"nanotee/sqls.nvim",
			ft = "sql",
			config = function()
				require("lspconfig").sqls.setup({
					on_attach = function(client, bufnr)
						local cfg = vim.env.HOME .. "/.config/sqls/config.yml"
						if not vim.loop.fs_stat(cfg) then
							print("Warning: one or more connections must be defined in", cfg)
						end
						require("sqls").on_attach(client, bufnr)
					end,
				})
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

		{
			-- cd to repo root (else autochdir), most useful for go
			-- note: opts={} is not always equivalent to config=function()require'foo'.setup({})end, apparently
			"ahmedkhalf/project.nvim",
			config = function()
				require("project_nvim").setup({})
			end,
		},

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
			dependencies = { "jose-elias-alvarez/null-ls.nvim" },
			opts = {
				ensure_installed = {

					-- formatters

					"black",
					"gofumpt",
					"goimports", -- required for autoimport (reviser only performs grouping)
					"goimports-reviser",
					"golines",
					"isort",
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
					"ruff",
					"shellcheck",
				},

				--
			},
		}, -- }}}
		{ -- lualine {{{
			-- https://github.com/nvim-lualine/lualine.nvim#default-configuration
			"nvim-lualine/lualine.nvim",

			opts = function(_, opts)
				local navic = require("nvim-navic")
				-- local gitblame = require("gitblame")

				opts.sections = {

					-- https://github.com/nvim-lualine/lualine.nvim#available-components
					-- https://github.com/nvim-lualine/lualine.nvim#component-specific-options

					lualine_a = {
						"branch",
					},

					lualine_b = {
						{ "diagnostics", sources = { "nvim_workspace_diagnostic" } },
					},

					lualine_c = {
						{
							-- not dynamic on resize: https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#filename-component-options
							function()
								return vim.o.columns > 170 and vim.fn.expand("%:p:h") or vim.fn.expand("%")
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
						function()
							local current_line = vim.fn.line(".")
							local total_line = vim.fn.line("$")
							return string.format("%.2f %s", current_line / total_line, vim.fn.mode())
						end,
					},
				}

				opts.winbar = {
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

							-- tab_max_length = 40,
							max_length = vim.o.columns,
							mode = 2, -- tab_nr + tab_name

							-- 0: just shows the filename
							-- 1: shows the relative path and shorten $HOME to ~
							-- 2: shows the full path
							-- 3: shows the full path and shorten $HOME to ~
							path = 0,

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
				-- "MaximilianLloyd/adjacent.nvim",
				{ "hejops/adjacent.nvim", branch = "ignore-binary" },
				"nvim-lua/plenary.nvim", -- backend
				"nvim-telescope/telescope-file-browser.nvim", -- netrw-like
				-- "aznhe21/actions-preview.nvim", -- https://github.com/aznhe21/actions-preview.nvim/issues/54
				-- "fcying/telescope-ctags-outline.nvim",
				-- "nvim-telescope/telescope-ui-select.nvim", -- https://github.com/nvim-telescope/telescope-ui-select.nvim/issues/44
				-- "rachartier/tiny-code-action.nvim",
				-- "tsakirist/telescope-lazy.nvim",
				{ "AckslD/nvim-neoclip.lua", opts = {} }, -- yank history; do i use this?
				{ "crispgm/telescope-heading.nvim", ft = "markdown" }, -- headings in markdown
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
				enabled = vim.o.columns > 170,
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
				{ "kosayoda/nvim-lightbulb", event = "LspAttach" }, -- alert for possible code actions

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
			-- - executing a query focuses the result pane (fixed with autocmd)
			-- - i dislike the 4-pane gui

			dependencies = { "MunifTanjim/nui.nvim" },
			build = function()
				require("dbee").install()
			end,
			config = function()
				require("dbee").setup({
					sources = {
						require("dbee.sources").MemorySource:new({
							{
								name = "foo",
								type = "sqlite",
								url = vim.env.HOME .. "/gripts/disq/collection2.db",
							},
						}),
						require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
						require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
					},

					editor = {
						mappings = {
							-- TODO: this overrides the original binding, making Sqls (or whatever) unavailable after dbee is exited
							{ key = "<leader>x", mode = "n", action = "run_file" },
						},
					},

					result = { mappings = {
						{ key = "<C-c>", mode = "", action = "cancel_call" },
					} },
				})

				local dbee = require("dbee")
				vim.keymap.set("n", "<leader>X", function()
					local scratch_dir = vim.env.HOME .. "/.local/state/nvim/dbee/notes/memory_source_memory1"
					local scratch_path = scratch_dir .. "/" .. vim.fn.expand("%:t")

					-- ensure note is synced to the file
					local cmd = string.format([[ln -sf %s %s/]], vim.fn.expand("%:p"), scratch_dir)
					os.execute(cmd)

					local id = require("dbee").api.ui.editor_search_note_with_file(scratch_path).id
					dbee.api.ui.editor_set_current_note(id)

					local function buffer_to_string()
						local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
						return table.concat(content, "\n")
					end
					dbee.execute(buffer_to_string())
				end)
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
			lazy = false,

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

				"joosepalviste/nvim-ts-context-commentstring", -- TS-aware commentstring (slow)
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

		"iagorrr/noctis-high-contrast.nvim",
		-- { "nlcodes/my_nvim_config", lazy = true }, -- mono tabline
		{ "judaew/ronny.nvim", lazy = true }, -- requires git-lfs (only for assets, lol)
		{ "tomasr/molokai", lazy = true }, -- italic types

		-- "ajmwagar/vim-deus", -- mono tabline
		-- "bluz71/vim-moonfly-colors", -- mid contrast, pub and fn same color
		-- "crusoexia/vim-monokai", -- mid contrast
		-- "danilo-augusto/vim-afterglow", -- mono tabline
		-- "dasupradyumna/midnight.nvim", -- mono tabline
		-- "fenetikm/falcon", -- mono tabline
		-- "gosukiwi/vim-atom-dark", -- bad lualine
		-- "hachy/eva01.vim", -- don't like the low contrast one
		-- "jaredgorski/spacecamp", -- bad lualine
		-- "kvrohit/rasmus.nvim", -- mono tabline
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

-- nvim-tree - might remove {{{
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

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
