-- :h lspconfig-setup
-- :h vim.lsp.ClientConfig
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
-- multiple LSPs lead to strange behaviour (e.g. renaming symbol twice)

local function gotodef_tabdrop()
	vim.lsp.buf.definition({
		on_list = function(options)
			-- note: this doesn't get triggered, apparently
			if #options.items > 1 then
				os.execute("notify-send hi")
				vim.notify("Multiple items found, opening first one", vim.log.levels.WARN)
				return
			end

			-- tab drop
			-- https://github.com/Swoogan/dotfiles/blob/ecfdf4f/nvim/.config/nvim/lua/config/lang.lua#L81
			local item = options.items[1]
			vim.cmd("tab drop " .. item.filename)
			-- vim.api.nvim_win_set_cursor(win or 0, { item.start.line + 1, item.start.character })
			vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
			vim.cmd("norm zt")
		end,
	})
end

-- https://github.com/BrunoKrugel/dotfiles/blob/0b2bdc4b3909620727b3975c482eea3cbebd7f9f/lua/mappings.lua#L5
-- local function golang_goto_def()
-- 	local old = vim.lsp.buf.definition
-- 	local opts = {
-- 		on_list = function(options)
-- 			if options == nil or options.items == nil or #options.items == 0 then
-- 				return
-- 			end
-- 			local targetFile = options.items[1].filename
-- 			local prefix = string.match(targetFile, "(.-)_templ%.go$")
-- 			if prefix then
-- 				local function_name = vim.fn.expand("<cword>")
-- 				options.items[1].filename = prefix .. ".templ"
-- 				vim.fn.setqflist({}, " ", options)
-- 				vim.api.nvim_command("cfirst")
-- 				vim.api.nvim_command("silent! /templ " .. function_name)
-- 			else
-- 				old()
-- 			end
-- 		end,
-- 	}
-- 	vim.lsp.buf.definition = function(o)
-- 		o = o or {}
-- 		o = vim.tbl_extend("keep", o, opts)
-- 		old(o)
-- 	end
-- end

-- https://github.com/fatih/dotfiles/blob/52e459c991e1fa8125fb28d4930f13244afecd17/init.lua#L748
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev) -- goto def + tabdrop
		local opts = { buffer = ev.buf }

		-- vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)

		-- https://github.com/neovim/neovim/pull/19213
		-- https://github.com/raphapr/dotfiles/blob/ecdf9771d/home/dot_config/nvim/lua/raphapr/utils.lua#L25
		-- https://github.com/Swoogan/dotfiles/blob/ecfdf4fe5/nvim/.config/nvim/lua/config/lang.lua#L63

		vim.keymap.set("n", "gd", gotodef_tabdrop, opts)
		-- vim.keymap.set("n", "gd", golang_goto_def, opts)

		require("lsp_signature").on_attach({}, ev.buf)
	end,
})

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

local function on_attach(_, bufnr)
	-- {{{
	-- buffer-specific LSP keymaps
	local function nmap(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	local telescope_b = require("telescope.builtin")

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
end -- }}}

local servers = { -- {{{

	-- WARN: commenting out an lsp does not uninstall it!

	-- https://github.com/blackbhc/nvim/blob/4ae2692403a463053a713e488cf2f3a762c583a2/lua/plugins/lspconfig.lua#L399
	-- https://github.com/oniani/dot/blob/e517c5a8dc122650522d5a4b3361e9ce9e223ef7/.config/nvim/lua/plugin.lua#L157

	-- digestif = {}, -- not valid in ensure_installed?
	-- hls = {}, -- 1.7 GB!
	-- ocamllsp = {}, -- requires global opam installation
	-- ruff = {}, -- i don't know if this actually does anything
	-- texlab = {},
	bashls = {},
	dockerls = {},
	lexical = {},
	marksman = {}, -- why should md ever have any concept of root_dir?
	pyright = {}, -- https://github.com/Lilja/dotfiles/blob/9fd77d2f5d55352b36054bcc7b4acc232cb99dc6/nvim/lua/plugins/lsp_init.lua#L90
	taplo = {},
	zls = {},

	clangd = {
		cmd = {
			"clangd",

			"--all-scopes-completion", -- include index symbols that are potentially out of scope
			"--background-index", -- index project code in the background and persist index on disk (where?)
			"--clang-tidy", -- linter (redundant?)
			"--completion-style=detailed", -- don't combine overloads
			"--function-arg-placeholders", -- complete function and method calls
			"--header-insertion-decorators",
			"--header-insertion=iwyu",
			"--malloc-trim", -- Release memory periodically (lol)
			"--pch-storage=memory", -- increase performance (at the expense of memory)
			-- "--cross-file-rename", -- removed?
			-- "--enable-config", -- read .clangd
			-- "--inlay-hints", -- removed/no effect?
			-- "--log=error",
			-- "-j=6", -- workers
		},

		init_options = {

			clangdFileStatus = true,
			completeUnimported = true,
			semanticHighlighting = true,
			usePlaceholders = true,
		},

		-- TODO: https://clangd.llvm.org/config#unusedincludes
		settings = {
			diagnostics = { "UnusedIncludes=Strict" },
		},
	},

	-- -- broken?
	-- -- https://github.com/EmilianoEmanuelSosa/nvim/blob/c0a47abd789f02eb44b7df6fefa698489f995ef4/init.lua#L129
	-- docker_compose_language_service = {
	-- 	root_dir = require("lspconfig").util.root_pattern("docker-compose.yml"), -- add more patterns if needed
	-- 	filetypes = { "yaml.docker-compose" },
	-- 	-- single_file_support = true,
	-- },

	yamlls = {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#yamlls
		settings = {
			yaml = { schemas = { ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*" } },
		},
	},

	sqls = {
		-- https://github.com/sqls-server/sqls?tab=readme-ov-file#db-configuration
		-- lol https://github.com/qbedard/dotfiles/blob/c30c58adc90d4c72859e322c480388677adee175/config/nvim/lua/plugins/lspconfig.lua#L213

		autostart = vim.loop.fs_stat(vim.env.HOME .. "/.config/sqls/config.yml") ~= nil,

		-- -- not sure what this is supposed to do
		-- on_attach = function(client, bufnr)
		-- 	require("sqls").on_attach(client, bufnr)
		-- end,

		-- -- 1. workspace-specific db via settings.sqls.connections; doesn't work
		-- settings = {
		-- 	sqls = {
		-- 		connections = {
		-- 			{
		-- 				driver = "sqlite3",
		-- 				dataSourceName = vim.env.HOME .. "/gripts/disq/collection2.db",
		-- 			},
		-- 		},
		-- 	},
		-- },

		-- -- 2. workspace-specific config file via cmd; doesn't work
		-- cmd = {
		-- 	"sqls",
		-- 	"-config",
		-- 	vim.env.HOME .. "/gripts/disq/queries/config.yml",
		-- },

		-- 3. centralised config at ~/.config/sqls/config.yml
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
		root_dir = require("util"):root_directory(), -- important: use root biome.json
	},

	ts_ls = {

		root_dir = require("util"):root_directory(), -- .. "/src",

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

					-- error 2307 is problematic. generally, it should not be ignored,
					-- because ts_ls can always detect incorrect tsx imports, regardless
					-- of where ts_ls is started.
					--
					-- if started at root, 2307 is -always- produced for any css import,
					-- regardless of whether the css file exists.
					--
					-- if started at src, 2307 is -never- produced, regardless of whether
					-- the css file exists.
					-- 2307,
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
					-- allFeatures = true, -- https://rust-analyzer.github.io/manual.html#features
					command = "clippy", -- https://rust-lang.github.io/rust-clippy/master/index.html
				},
				completion = {
					addCallParenthesis = true, -- a.foo()
					-- postfix = { enable = false },
					addCallArgumentSnippets = false, -- a.foo(arg1)
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
} -- }}}

local mason_lspconfig = require("mason-lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()) -- wrap default capabilities with cmp

mason_lspconfig.setup({ ensure_installed = vim.tbl_keys(servers) })

mason_lspconfig.setup_handlers({
	-- the func passed to setup_handlers is called once for -each- installed server on startup
	function(server_name)
		require("lspconfig")[server_name].setup(vim.tbl_extend("force", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		}, servers[server_name] or {}))
	end,
})

require("lspconfig").gleam.setup({}) -- not on mason, must be installed globally
require("lspconfig").digestif.setup({}) -- autocomplete is wonky

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
