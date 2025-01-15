require("conform").setup({
	-- :h conform-formatters
	formatters = {
		-- python {{{
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
				-- "--unsafe-fixes",
				"--force-exclude",
				"--exit-zero",
				"--no-cache",
				"--stdin-filename",
				"$FILENAME",
				"-",
			},
		},
		-- }}}
		-- js {{{
		biome = {
			-- important: at work, use top-level biome.json
			-- note: cwd must be a func, not a string
			cwd = require("util").root_directory,
			args = vim.loop.fs_stat(require("util"):root_directory() .. "/biome.json") -- if biome.json exists, leave args unchanged
					and { "format", "--stdin-file-path", "$FILENAME" }
				or {
					"format",
					"--indent-style=space",
					"--stdin-file-path",
					"$FILENAME",
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
		-- }}}
		-- sql {{{
		sqruff = {
			command = "sqruff",
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
				-- note: sql_dialect will probably be triggered before buf is loaded. a
				-- BufReadPost will likely be needed to set this to the correct value
				"--dialect=" .. require("util"):sql_dialect(),
				"--exclude-rules",
				"layout.long_lines",
				"-",
			},
			stdin = true,
			require_cwd = false, -- else requires local .sqlfluff
		},
		-- }}}

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
			prepend_args = vim.loop.fs_stat(".clang-format") and {} or { "--style", "google" },
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

		dhall = { command = "dhall", args = { "format" } },

		latexindent = {
			-- extra/perl-yaml-tiny
			-- extra/perl-file-homedir
			-- extra/texlive-luatex
			-- texlive-fontsrecommended
			command = "/usr/bin/latexindent",
		},
	},

	formatters_by_ft = {
		-- https://github.com/stevearc/conform.nvim#formatters
		-- Conform will run multiple formatters sequentially
		-- all formatters will be run non-async

		["_"] = { "trim_whitespace", "trim_newlines" },
		bash = { "shfmt" },
		c = { "clang-tidy", "clang-format" }, -- both provided by clangd
		cpp = { "clang-format" }, -- clang-tidy is slow!
		css = { "prettier" },
		dhall = { "dhall" },
		elixir = { "mix" }, -- slow (just like elixir)
		gleam = { "gleam" }, -- apparently this works?
		html = { "prettier" },
		htmldjango = { "djlint" },
		lua = { "stylua" },
		markdown = { "mdslw", "prettier" },
		ocaml = { "ocamlformat" },
		python = { "ruff_organize_imports", "ruff_fix", "ruff_format" }, -- pyproject.toml: [tool.ruff.isort] force-single-line = true
		rust = { "rustfmt" },
		scss = { "prettier" },
		sh = { "shfmt" },
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

		go = {
			-- https://github.com/SingularisArt/Singularis/blob/856a938fc8554fcf47aa2a4068200bc49cad2182/aspects/nvim/files/.config/nvim/lua/modules/lsp/lsp_config.lua#L50

			"gofumpt", -- https://github.com/mvdan/gofumpt?tab=readme-ov-file#added-rules
			"golines", -- https://github.com/segmentio/golines#motivation https://github.com/segmentio/golines?tab=readme-ov-file#struct-tag-reformatting
			"goimports-reviser", -- better default behaviour (lists 1st party after 3rd party); TODO: investigate why this breaks in some dirs (e.g. linkedin)
			-- "goimports", -- required for autoimport (null_ls), but not for formatting -- https://pkg.go.dev/golang.org/x/tools/cmd/goimports
		},

		sql = {
			"sqruff",
			-- sqruff erroneously inserts a trailing newline; sqlfluff doesn't. why
			-- do people rewrite in rust without feature parity?
			"trim_newlines",
			-- "sqlfluff",
			-- stop_after_first = true,
		},
	},
})
