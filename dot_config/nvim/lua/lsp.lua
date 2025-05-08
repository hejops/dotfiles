-- :h lspconfig-setup
-- :h vim.lsp.ClientConfig
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
-- multiple LSPs lead to strange behaviour (e.g. renaming symbol twice)

-- https://github.com/fatih/dotfiles/blob/52e459c991e1fa8125fb28d4930f13244afecd17/init.lua#L748
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev) -- goto def + tabdrop
		local opts = { buffer = ev.buf }

		-- vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)

		-- https://github.com/neovim/neovim/pull/19213
		-- https://github.com/raphapr/dotfiles/blob/ecdf9771d/home/dot_config/nvim/lua/raphapr/utils.lua#L25
		-- https://github.com/Swoogan/dotfiles/blob/ecfdf4fe5/nvim/.config/nvim/lua/config/lang.lua#L63

		vim.keymap.set("n", "gd", function()
			-- https://github.com/nvim-telescope/telescope.nvim/pull/2751
			require("telescope.builtin").lsp_definitions({ jump_type = "tab drop" })
		end, opts)
		-- vim.keymap.set("n", "gd", golang_goto_def, opts)

		-- require("actions-preview").setup({})
		-- require("tiny-code-action").setup()
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

-- motivation: `vim.lsp.buf.references` and `incoming_calls` serve basically
-- the same purpose; the former outputs the call, the latter the caller. but i
-- don't really adopt a qf workflow, and i would prefer outputting both caller
-- and call.
--
-- telescope is superior for navigating, but requires you to divide your
-- attention between the selection and preview panes, because the selection
-- pane is useless.
--
-- this function outputs caller (and call, if the buffer has been loaded) in
-- the telescope selection pane.
local function tele_lsp_incoming_custom()
	-- {{{
	--
	-- quickfix:
	-- vim.lsp.buf.references()     -- call   -- tui.go|43 col 15| func (p Post) saveImage(subj string) error {
	-- vim.lsp.buf.incoming_calls() -- caller -- tui.go|385 col 19| Update
	--
	-- telescope:
	-- require("telescope.builtin").lsp_references     -- tui.go:385:19
	-- require("telescope.builtin").lsp_incoming_calls -- tui.go:385:19
	-- this                                            -- tui.go	L385	Update	func (p Post) ...

	-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#entry-maker
	-- https://github.com/yuepaang/dotfiles/blob/5272e1aef2b0255535d7f575d9a5e32cd75e2cd8/nvim/lua/doodleVim/extend/lsp.lua#L3
	local function entry_maker(entry)
		-- file at line; note: line will only be displayed in the selection window
		-- if the buffer has been loaded, otherwise it is empty. the line will
		-- always be displayed in the preview window.
		local bufnr = require("util"):get_bufnr(entry.filename)
		local line = bufnr and vim.api.nvim_buf_get_lines(bufnr, entry.lnum - 1, entry.lnum, false) or "(not loaded)"

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
				{ "L" .. entry.lnum, "TelescopeResultsLineNr" },
				entry.text,
				line,
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

	require("telescope.builtin").lsp_incoming_calls({ -- tui.go:385:19:Update
		-- contrary to the name, show_line only shows the name of the parent func
		-- (...:parent), but not the actual line itself. Trouble doesn't show the
		-- line either (and i don't like using trouble anyway)
		show_line = true,
		entry_maker = entry_maker, -- this func is invoked for every entry
	})
end -- }}}

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

	-- nmap("<leader>A", require("actions-preview").code_actions)
	-- nmap("<leader>A", require("tiny-code-action").code_action)
	nmap("<leader>A", vim.lsp.buf.code_action)

	nmap("<leader>i", tele_lsp_incoming_custom, "incoming calls")
	nmap("<leader>s", telescope_b.lsp_dynamic_workspace_symbols, "document symbols") -- all project files
	nmap("K", vim.lsp.buf.hover, "hover documentation")
	nmap("R", vim.lsp.buf.rename, "rename")

	nmap("<leader>S", function()
		-- TS has no project-wide scope, too bad
		require("telescope.builtin").treesitter({ symbols = { "method", "function", "type" } })
	end, "treesitter functions")
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
	pyright = {}, -- https://github.com/Lilja/dotfiles/blob/9fd77d2f5/nvim/lua/plugins/lsp_init.lua#L90
	taplo = {},
	zls = {},

	clangd = { -- mason versions are usually newer than arch
		cmd = {
			"clangd",

			"--all-scopes-completion", -- include index symbols that are potentially out of scope
			"--background-index", -- index project code in the background and persist index on disk (where?)
			"--completion-style=detailed", -- don't combine overloads
			"--enable-config", -- read .clangd (see fallbackFlags below)
			"--function-arg-placeholders", -- complete function and method calls
			"--header-insertion-decorators",
			"--header-insertion=iwyu", -- correct insertion of c headers requires clangd 19 (?)
			"--malloc-trim", -- Release memory periodically (lol)
			"--pch-storage=memory", -- increase performance (at the expense of memory)
			-- "--clang-tidy",
			-- "--log=error",
			-- "-j=6", -- workers
		},

		init_options = {

			-- if a .clangd file exists, these flags will be merged, with the .clangd
			-- file taking precedence.
			fallbackFlags = {

				-- c++17 appears to be the minimum recommended standard, because it
				-- removed auto_ptr (replacing it with unique_ptr)
				-- https://clang.llvm.org/cxx_status.html
				--
				-- for portability, c99 is the generally accepted standard; POSIX uses
				-- c99 (citation needed).
				-- https://clang.llvm.org/c_status.html
				-- https://stackoverflow.com/a/64138834
				-- https://old.reddit.com/r/C_Programming/comments/xq58u7

				"-std=" .. (vim.bo.filetype == "cpp" and "c++23" or "c23"),
				-- "-std=c23",

				"-I",
				".", -- https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html#index-I

				"-Weverything",

				-- note: gcc notoriously does not warn about unreachable code
				-- https://gcc.gnu.org/legacy-ml/gcc-help/2011-05/msg00360.html

				-- TODO: warn unused includes (this worked on my laptop iirc)

				"-Wno-declaration-after-statement", -- `int foo = 1;` not allowed in C99
				"-Wno-missing-noreturn", -- noreturn requires C23, which breaks cproto
				"-Wno-unsafe-buffer-usage", -- asserts do not fix this -- https://stackoverflow.com/a/77017754
			},

			-- https://github.com/kuprTheMan/dotfiles/blob/b340744e0b4964e02ea43f34d4fd8303e6e8c644/.config/nvim/init.lua#L670
			checkUpdates = false,
			clangdFileStatus = true,
			completeUnimported = true,
			restartAfterCrash = true,
			semanticHighlighting = true,
			usePlaceholders = true,
		},

		-- -- TODO: https://clangd.llvm.org/config#unusedincludes
		-- -- should be enabled by default from clangd 17
		-- settings = {
		-- 	diagnostics = { "UnusedIncludes=Strict" },
		-- 	clangd = {
		-- 		diagnostics = { "UnusedIncludes=Strict" },
		-- 	},
		-- },
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

		-- autostart = vim.loop.fs_stat(vim.env.HOME .. "/.config/sqls/config.yml"),
		autostart = vim.loop.fs_stat("./config.yml") ~= nil,

		-- rely on workspace-specific config file
		-- https://github.com/sqls-server/sqls?tab=readme-ov-file#db-configuration
		-- centralised config can be defined at ~/.config/sqls/config.yml
		cmd = { "sqls", "--config", "./config.yml" },

		-- -- lol https://github.com/qbedard/dotfiles/blob/c30c58adc90d4c72859e322c480388677adee175/config/nvim/lua/plugins/lspconfig.lua#L213
		-- -- 1. workspace-specific db via settings.sqls.connections; doesn't work
		-- settings = {
		-- 	sqls = {
		-- 		connections = {
		-- 			{
		-- 				alias = "foo",
		-- 				driver = "sqlite3",
		-- 				dataSourceName = vim.env.HOME .. "/gripts/disq/collection2.db",
		-- 			},
		-- 		},
		-- 	},
		-- },
	},

	-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
	-- TODO: lsp rename (or nvim) is acting weird (go 1.24, gopls 0.18): renames
	-- are performed, but affected files are not opened in new tabs (maybe it was
	-- always like that?), and each file needs to be explicitly opened/saved.
	-- sometimes, renames are totally botched and result in ghastly syntax errors
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

	-- biome = {
	-- 	-- root_dir = require("util"):root_directory(),
	-- 	root_dir = vim.fs.root(0, { "biome.json" }),
	-- },

	ts_ls = {

		-- if nil, reverts to default value
		-- root_dir is important for loading tsconfig.json correctly!
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
					globals = {
						"Command", -- yazi
						"mp", -- mpv
						"ui", -- yazi
						"vim",
						"ya", -- yazi
					},
					disable = { "missing-fields" },
				},
				telemetry = { enable = false },
				workspace = { checkThirdParty = false },
			},
		},
	},
} -- }}}

local extra_servers = { -- these lsps are not on mason
	digestif = {}, -- requires luarocks; autocomplete is wonky
	gleam = {},
	-- works without active connection, but parser is unusable (agonisingly slow
	-- and doesn't recognise some basic syntax (e.g. ON CONFLICT DO))
	postgres_lsp = { autostart = false },
}

-- -- this doesn't work at all lol
-- vim.lsp.config("*", {
-- 	root_markers = { ".git" },
-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
-- 	on_attach = on_attach,
-- })

local base_cfg = {
	capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
	on_attach = on_attach,
}
for server_name, cfg in pairs(vim.tbl_extend("force", servers, extra_servers)) do
	vim.lsp.config(server_name, vim.tbl_extend("force", base_cfg, cfg))
end

vim.lsp.enable(vim.tbl_keys(servers))

-- require("mason").setup() -- implicitly initialised in plugins.lua

-- should only be used for ensure_installed now; lsp init is handled by vim.lsp.enable
require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_enable = false, -- very slow compared to vim.lsp.enable
})

vim.diagnostic.config({
	signs = {
		text = {

			-- [vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.ERROR] = "💀",
			[vim.diagnostic.severity.HINT] = "🤓",
			[vim.diagnostic.severity.INFO] = "ⓘ",
			[vim.diagnostic.severity.WARN] = "🤔",
		},
	},
})
