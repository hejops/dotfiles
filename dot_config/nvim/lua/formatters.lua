local js_formatters = {
	"biome",
	"prettier",
	stop_after_first = true,
}

require("conform").setup({
	-- :h conform-options
	-- :h conform-formatters
	formatters = {

		["goimports-reviser"] = { args = { "$FILENAME" } }, -- '-format' introduces additional formatting, which i don't like

		golines = {
			-- https://github.com/segmentio/golines/issues/115#issuecomment-1824651357
			args = { "--base-formatter=gofmt" },
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
				-- "--unsafe-fixes",
				"--force-exclude",
				"--exit-zero",
				"--no-cache",
				"--stdin-filename",
				"$FILENAME",
				"-",
			},
		},

		biome = {
			-- important: at work, use top-level biome.json
			-- note: cwd must be a func, not a string
			-- cwd = require("util").root_directory,
			condition = function()
				return not vim.uv.fs_stat(".prettierrc.json")
			end,
			args = (function()
				local args = {
					"format",
					"--stdin-file-path",
					"$FILENAME",
				}
				if not vim.fs.root(0, "biome.json") then
					-- default is tab (although this may not be noticeable due to the
					-- tabstop autocmd)
					table.insert(args, "--indent-style=space")
				end
				return args
			end)(),
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

		["clang-format"] = {
			-- https://clang.llvm.org/docs/ClangFormatStyleOptions.html#basedonstyle
			-- https://github.com/motine/cppstylelineup
			-- https://github.com/torvalds/linux/blob/master/.clang-format
			prepend_args = vim.uv.fs_stat(".clang-format") and {} or { "--style", "google" },
		},

		["clang-tidy"] = {
			command = "clang-tidy",
			args = { "--fix-errors", "$FILENAME" },
			stdin = false,
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

		sqruff = { exit_codes = { 0, 1 } },

		dhall = { command = "dhall", args = { "format" } },

		latexindent = { args = { "--logfile=/dev/null" } },

		-- curl -sSL https://api.github.com/repos/reteps/dockerfmt/releases |
		-- 	sponge /dev/stdout |
		-- 	grep -Pom1 "https.+linux-amd64.tar.gz" |
		-- 	xargs curl -sL |
		-- 	sponge /dev/stdout |
		-- 	tar -xvz --one-top-level=~/.local/bin

		dockerfmt = {
			command = "dockerfmt",
			args = { "-w", "$FILENAME" },
			stdin = false,
		},

		-- blocked until jqfmt preserves `def`
		-- https://github.com/noperator/jqfmt/issues/5
		-- < ~/scripts/immo rgml -o "jq \S* '\n.+?'" | sed '1d;$d' | jqfmt -op pipe

		jqfmt = {
			command = "jqfmt",
			args = { "-op", "pipe" },
			stdin = true,
		},

		-- sqlfluff = {
		-- 	-- format: more reliable; will format if no violations found
		-- 	-- fix: does nothing if 'Unfixable violations detected'
		-- 	-- in either case, no `dialect` usually leads to timeout
		-- 	args = {
		-- 		"format",
		-- 		"--dialect=postgres",
		-- 		"--processes=32", -- lol
		-- 		"--exclude-rules",
		-- 		"layout.long_lines",
		-- 		"-",
		-- 	},
		-- 	stdin = true,
		-- 	require_cwd = false, -- else requires local .sqlfluff
		-- },
	},

	formatters_by_ft = {
		-- https://github.com/stevearc/conform.nvim#formatters
		-- Conform will run multiple formatters sequentially
		-- all formatters will be run non-async

		-- jq = { "jq" }, -- jq only formats json (duh)
		-- ocaml = { "ocamlformat" },
		-- xml = { "xmlformat" }, -- ModuleNotFoundError: No module named 'xmlformatter'
		["_"] = { "trim_whitespace", "trim_newlines" },
		bash = { "shfmt", "shellharden" }, -- bash ft is only via modeline (?)
		c = { "clang-tidy", "clang-format" }, -- both provided by clangd
		cpp = { "clang-format" }, -- clang-tidy is slow!
		css = { "prettier" },
		dhall = { "dhall" },
		dockerfile = { "dockerfmt" },
		elixir = { "mix" }, -- slow (just like elixir)
		gleam = { "gleam" }, -- apparently this works?
		html = { "prettier" },
		htmldjango = { "djlint" },
		jq = { "jqfmt" },
		jsonl = { "jq" },
		lua = { "stylua" },
		markdown = { "mdslw", "prettier" },
		python = { "ruff_organize_imports", "ruff_fix", "ruff_format" }, -- TODO: pyproject.toml: [tool.ruff.isort] force-single-line = true
		rust = { "rustfmt" },
		scss = { "prettier" },
		sh = { "shfmt", "shellharden" },
		templ = { "templ" },
		tex = { "latexindent" },
		toml = { "taplo" },
		yaml = { "prettier" }, -- TODO: no .clangd parser

		javascript = js_formatters,
		javascriptreact = js_formatters,
		json = js_formatters,
		jsonc = js_formatters, -- TODO: biome selects parser based on file ext if it is not "special" (e.g. tsconfig.json)
		typescript = js_formatters,
		typescriptreact = js_formatters,

		go = {
			-- https://github.com/SingularisArt/Singularis/blob/856a938fc8554fcf47aa2a4068200bc49cad2182/aspects/nvim/files/.config/nvim/lua/modules/lsp/lsp_config.lua#L50

			"gofumpt", -- https://github.com/mvdan/gofumpt?tab=readme-ov-file#added-rules
			"golines", -- https://github.com/segmentio/golines#motivation https://github.com/segmentio/golines?tab=readme-ov-file#struct-tag-reformatting
			"goimports", -- required for autoimport (null_ls), but not for formatting -- https://pkg.go.dev/golang.org/x/tools/cmd/goimports
			"goimports-reviser", -- better default behaviour (lists 1st party after 3rd party); TODO: investigate why this breaks in some dirs (e.g. linkedin)
		},

		sql = {
			-- "pg_format", -- default formatting violates sqlfluff
			"sqruff", -- relies on .sqruff
			-- sqruff erroneously inserts a trailing newline; sqlfluff doesn't. why
			-- do people rewrite in rust without feature parity?
			"trim_newlines",
			-- "sqlfluff",
			-- stop_after_first = true,
		},
	},
})
