-- Lazy Startuptime should remain under 200 ms (opening a file in a repo)
-- (need a few good benchmark files, e.g. md, py, sh)

-- :Lazy profile, filter > 10 ms

-- https://lazy.folke.io/spec
-- https://lazy.folke.io/configuration

-- local in_git = require("util"):command_ok("git rev-parse --is-inside-work-tree 2>/dev/null") -- messes with window resize
local in_git = true

local columns = 120 -- lualine, git-blame

-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

local cfg = { -- {{{
	-- https://github.com/ecosse3/nvim/blob/e8418eb65af447/lua/config/lazy.lua#L14C41-L34C2
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

require("lazy").setup( --
	{

		-- essentials {{{

		"aymericbeaumet/vim-symlink", -- TODO: can this just be an autocmd?
		"mfussenegger/nvim-lint",
		"romainl/vim-cool", -- clear highlight after search
		"stevearc/conform.nvim",
		"tpope/vim-fugitive",
		"tpope/vim-repeat",
		"tpope/vim-surround",
		{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
		{ "numtostr/comment.nvim", opts = {} }, -- replaces vim-commentary

		-- }}}

		-- "martineausimon/nvim-lilypond-suite",
		-- { "tadmccorkle/markdown.nvim", ft = "markdown", opts = { mappings = false } }, -- https://github.com/tadmccorkle/markdown.nvim?tab=readme-ov-file#usage
		{ "akinsho/git-conflict.nvim", version = "*", opts = {}, cond = in_git }, -- TODO: only if file contains conflict markers (/repo has conflicts)?
		{ "ecridge/vim-kinesis", ft = "kinesis" }, -- KA2, *_qwerty.txt
		{ "jbyuki/quickmath.nvim", cmd = { "Quickmath" } },
		{ "johnelliott/vim-kinesis-kb900", ft = "kb900" }, -- KA FP (and 360?), layout*.txt
		{ "mbbill/undotree", cmd = { "UndoTreeToggle" } },
		{ "rhysd/vim-go-impl", ft = "go" }, -- :GoImpl m Model tea.Model (requires https://github.com/josharian/impl)
		{ "terrastruct/d2-vim", ft = "d2" },
		{ "tpope/vim-dispatch", cmd = { "Dispatch", "Make" } }, -- run async processes
		{ "tpope/vim-dotenv", cmd = { "Dotenv" } },
		{ "tridactyl/vim-tridactyl", ft = "tridactyl" }, -- syntax highlighting
		{ "wansmer/treesj", opts = {}, cmd = { "TSJToggle", "TSJSplit", "TSJJoin" } }, -- very slow; TODO: <leader>j conflicts with trouble
		{ "yochem/jq-playground.nvim", ft = "json" },

		{
			"norcalli/nvim-colorizer.lua",
			config = function()
				require("colorizer").setup()
			end,
		},

		-- {
		-- 	"devkvlt/go-tags.nvim", -- gone??
		-- 	ft = "go",
		-- 	enabled = vim.fn.executable("gomodifytags"),
		-- 	config = function()
		-- 		require("go-tags").setup({
		-- 			commands = {
		-- 				["GoTagsAddJSON"] = { "-add-tags", "json" },
		-- 				["GoTagsRemoveJSON"] = { "-remove-tags", "json" },
		-- 			},
		-- 		})
		-- 	end,
		-- },

		{
			"jinh0/eyeliner.nvim", -- replaces quick-scope
			config = function()
				require("eyeliner").setup({ highlight_on_key = false })
			end,
		},

		{
			"ray-x/lsp_signature.nvim", -- highlight func args in insert mode
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
			"lervag/vimtex",
			ft = { "tex", "bib" },
			enabled = vim.bo.filetype == "tex" and not vim.uv.fs_stat("Tectonic.toml"),
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
			"FabijanZulj/blame.nvim", -- full blame view (like gh/gl)
			cond = in_git,
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
					events = {
						on_open = { notification = { enable = true } },
						on_watch = { notification = { enable = true } },
						on_apply = { notification = { enable = false } },
					},
				})
			end,
		},

		{ -- mason-null-ls {{{
			-- https://roobert.github.io/2022/12/03/Extending-Neovim/#neovim-plugins-which-solve-problems
			--
			-- afaik, mason-null-ls is essentially only for installing everything
			-- automatically (mason's ensure_installed only applies to lsps). this is
			-- not essential, but nice to have
			--
			-- https://github.com/jjangsangy/Dotfiles/blob/a96a66b1b/astro_nvim/plugins/mason.lua#L15
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
					"prettier", -- only for html/yaml, iirc
					"shellharden",
					"shfmt",
					"stylua",
					-- "clang-format",

					-- linters

					"buf",
					"checkmake",
					"gitlint",
					"golangci-lint",
					"hadolint",
					"markdownlint",
					"proselint",
					"ruff",
					"shellcheck", -- should be included in bashls, but may not work ootb?
					"sqlfluff",
					"sqruff",
					vim.fn.executable("luarocks") == 1 and "luacheck" or nil,
				},

				--
			},
		}, -- }}}
		{ -- lualine {{{
			-- https://github.com/nvim-lualine/lualine.nvim#default-configuration
			"nvim-lualine/lualine.nvim",
			-- base: < 0.1 ms
			-- +init: 5-6 ms
			-- +git: 10-11 ms

			opts = function(_, opts)
				-- -- if vim.api.nvim_buf_get_name(0):match("^term") then
				-- if vim.bo.filetype == "c" then
				-- 	os.execute("notify-send hi")
				-- 	opts.sections = {
				-- 		lualine_a = {},
				-- 		lualine_b = {},
				-- 		lualine_c = {},
				-- 		lualine_x = {},
				-- 		lualine_y = {},
				-- 		lualine_z = {},
				-- 	}
				-- 	return
				-- end

				-- local function xx(x)
				-- 	if vim.api.nvim_buf_get_name(0):match("^term") then
				-- 		return {}
				-- 	else
				-- 		return x
				-- 	end
				-- end

				-- local gitblame = require("gitblame")

				opts.sections = {

					-- https://github.com/nvim-lualine/lualine.nvim#available-components
					-- https://github.com/nvim-lualine/lualine.nvim#component-specific-options

					lualine_a = {
						require("git").foo, -- TODO: ~ 5 ms
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

				opts.inactive_sections = {
					lualine_a = {
						function()
							if vim.fn.expand("%") == "" then
								return "[new file]"
							end
							return vim.fn.expand("%" .. (vim.o.columns > columns and ":p" or ""))
						end,
					},
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
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
					globalstatus = true,
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

				"LukasPietzschmann/telescope-tabs", -- do i use this? TODO: cond = >1 tab open
				"nvim-lua/plenary.nvim", -- backend
				-- "MaximilianLloyd/adjacent.nvim",
				-- "aznhe21/actions-preview.nvim", -- https://github.com/aznhe21/actions-preview.nvim/issues/54
				-- "fcying/telescope-ctags-outline.nvim",
				-- "nvim-telescope/telescope-ui-select.nvim", -- https://github.com/nvim-telescope/telescope-ui-select.nvim/issues/44
				-- "rachartier/tiny-code-action.nvim",
				-- "tsakirist/telescope-lazy.nvim",
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
			cond = in_git,
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
				{ "j-hui/fidget.nvim", opts = {}, event = "LspAttach" }, -- status updates for LSP

				{
					"folke/lazydev.nvim",
					ft = "lua",
					opts = {
						library = {
							-- See the configuration section for more details
							-- Load luvit types when the `vim.uv` word is found
							{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
						},
					},
				},

				{
					"kosayoda/nvim-lightbulb",
					enabled = false,
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
		{ -- gitsigns {{{
			"lewis6991/gitsigns.nvim",
			cond = in_git,
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
				{ "ravsii/tree-sitter-d2", build = "make nvim-install" },
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
						"javascript", -- includes jsx (probably)
						"jsdoc",
						"json",
						"jsonc",
						"lua",
						"markdown",
						"markdown_inline",
						"muttrc",
						"nginx",
						"python",
						"rasi",
						"rust",
						"sql",
						"toml",
						"tsx",
						"typescript",
						"vim",
						"vimdoc",
						"yaml",
						"zig",
						-- "htmldjango",
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

		-- above average contrast
		-- line column visible
		-- no font styling (acceptable only in strings and comments)
		-- not mono tabline
		-- underline current word (not highlight, not bold)

		"bgwdotdev/gleam-theme-nvim", -- the only one that meets all 4 criteria
		"hejops/kwrite-theme-nvim",
		"maya-sama/kawaii.nvim",
		"sebasruiz09/fizz.nvim",
		-- "bakageddy/alduin.nvim", -- some keywords too dim
		-- "c9rgreen/vim-colors-modus", -- mono tabline
		-- "e-q/okcolors.nvim", -- few colors, italic methods
		-- "github-main-user/lytmode.nvim", -- highlight current (dim)
		-- "iagorrr/noctis-high-contrast.nvim",
		-- "michaelfresco/space-terminal.nvim", -- highlight current
		-- "miikanissi/modus-themes.nvim", -- very good, but has light
		-- "mistweaverco/retro-theme.nvim", -- good, except for unreadable inactive tab
		-- "olivercederborg/poimandres.nvim", -- dim line column
		-- "sonya-sama/kawaii.nvim", -- dims current line
		-- "thejian/nvim-moonwalk", -- unreadable git status

		-- italic comments

		-- "devoc09/lflops.nvim",
		-- "fynnfluegge/monet.nvim",
		-- "honamduong/hybrid.nvim",
		-- "mitch1000/backpack.nvim",
		-- "pustota-theme/pustota.nvim",
		-- "wurli/cobalt.nvim",

		-- "2giosangmitom/nightfall.nvim", -- italic keywords
		-- "bartekjaszczak/finale-nvim", -- bold keywords
		-- "khoido2003/classic_monokai.nvim", -- italic vars
		-- "lancewilhelm/horizon-extended.nvim", -- italic keywords
		-- "ph1losof/morta.nvim", -- italic keywords
		-- "samharju/synthweave.nvim", -- italic vars

		{
			"shawilly/ponokai",
			lazy = true,
			config = function()
				vim.g.ponokai_disable_italic_comment = true
				vim.g.ponokai_current_word = "underline"
			end,
		},

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

		-- https://github.com/topics/neovim-theme?l=lua&o=desc&s=updated
		-- https://vimcolorschemes.com/i/new/b.dark
		-- }}}
	},

	cfg
)
