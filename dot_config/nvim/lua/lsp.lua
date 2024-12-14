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

-- :h lspconfig-setup
-- :h vim.lsp.ClientConfig
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
-- multiple LSPs lead to strange behaviour (e.g. renaming symbol twice)

-- WARN: commenting out an lsp does not uninstall it!
local servers = {

	-- https://github.com/blackbhc/nvim/blob/4ae2692403a463053a713e488cf2f3a762c583a2/lua/plugins/lspconfig.lua#L399
	-- https://github.com/oniani/dot/blob/e517c5a8dc122650522d5a4b3361e9ce9e223ef7/.config/nvim/lua/plugin.lua#L157

	-- hls = {}, -- 1.7 GB!
	-- ocamllsp = {}, -- requires global opam installation
	-- ruff = {}, -- i don't know if this actually does anything
	bashls = {},
	clangd = {}, -- TODO: suppress (?) "Call to undeclared function"
	dockerls = {},
	lexical = {},
	marksman = {}, -- why should md ever have any concept of root_dir?
	pyright = {},
	taplo = {},
	texlab = {},
	yamlls = {},
	zls = {},

	-- -- broken?
	-- -- https://github.com/EmilianoEmanuelSosa/nvim/blob/c0a47abd789f02eb44b7df6fefa698489f995ef4/init.lua#L129
	-- docker_compose_language_service = {
	-- 	root_dir = require("lspconfig").util.root_pattern("docker-compose.yml"), -- add more patterns if needed
	-- 	filetypes = { "yaml.docker-compose" },
	-- 	-- single_file_support = true,
	-- },

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

		-- ts_ls generally does not need to be at root, but better to be consistent
		-- with biome
		root_dir = require("util"):root_directory(),

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

require("lspconfig").gleam.setup({}) -- not on mason, must be installed globally

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
