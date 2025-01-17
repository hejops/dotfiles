-- lua print(require("lint").get_running()[1])

local linters = {
	-- https://github.com/mfussenegger/nvim-lint#available-linters

	-- elixir = { "credo" }, -- where da binary at
	-- lua = { "selene" }, -- disabled until i can get condition to work
	-- ruby = { "rubocop" },
	-- rust = { "clippy" }, -- part of the lsp
	["yaml.github"] = { "zizmor" },
	bash = { "shellcheck" },
	c = { "clangtidy" },
	cpp = { "clangtidy" },
	dockerfile = { "hadolint" }, -- can be quite noisy
	gitcommit = { "gitlint" },
	go = { "golangcilint" },
	html = { "markuplint" },
	htmldjango = { "djlint" },
	javascript = { "biomejs" }, -- should resolve to repo root
	javascriptreact = { "biomejs" },
	make = { "checkmake" },
	python = { "ruff" }, -- may have duplicate with ruff lsp
	sql = { "sqlfluff" }, -- slow lint is fine, since async
	typescript = { "biomejs" },
	typescriptreact = { "biomejs" },

	markdown = {
		"markdownlint", -- https://github.com/DavidAnson/markdownlint?tab=readme-ov-file#rules--aliases
		"proselint", -- https://github.com/amperser/proselint?tab=readme-ov-file#checks
	},
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

require("lint").linters.markdownlint.args = {
	"--disable",
	"MD010", -- no hard tabs (they only appear in Go blocks)
	"--stdin",
}

-- https://github.com/rrunner/dotfiles/blob/d55d90ed5d481fc1138483f76f0970d93784bf0a/nvim/.config/nvim/lua/plugins/linting.lua#L17
require("lint").linters.ruff.args = { -- {{{
	"check",
	"--preview",
	"--select=ALL",
	"--target-version=py310", -- type hints = 39, Optional (etc) = 310
	"--ignore=" .. table.concat({
		-- https://docs.astral.sh/ruff/rules/

		"CPY001", -- no need copyright notice
		"DOC201", -- allow docstrings to not document return type
		"ERA", -- allow comments
		"F841", -- reported by lsp
		"PD901", -- allow var name df
		"PLR0913", -- allow >5 func args
		"PLR2004", -- allow magic constant values
		"RET504", -- allow unnecessary assignment before return statement
		"S101", -- allow assert
		"SIM108", -- don't suggest ternary
		"T201", -- allow print()
		"TD", -- allow TODO
		-- "I001", -- ignore import sort order (handled by isort)
	}, ","),

	"--force-exclude",
	"--quiet",
	"--stdin-filename",
	vim.api.nvim_buf_get_name(0),
	"--no-fix", -- --fix should never be used for linting, because it destroys undos; fix via conform instead
	"--output-format=json", -- important
	"-",
} -- }}}

require("lint").linters.sqlfluff.args = { -- {{{
	"lint",
	-- maybe i should extend the ch parser
	-- https://github.com/sqlfluff/sqlfluff/pull/4876
	-- https://github.com/sqlfluff/sqlfluff/wiki/Contributing-Dialect-Changes
	-- https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/dialects/dialect_clickhouse.py
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
} -- }}}

require("lint").linters.clangtidy.args = { -- {{{

	-- clang-tidy is standard-agnostic!

	-- clangtidy:
	-- performs linting based on file extension (thus does not accept stdin)
	-- -always- lints header files (with no option whatsoever to skip them), and is very slow:
	--
	-- echo '#include <iostream>' > foo.cpp ; time clang-tidy --checks='-*,cppcoreguidelines-*' foo.cpp
	-- 2895 warnings generated.
	-- Suppressed 2895 warnings (2895 in non-user code).
	-- real    0m1.030s

	-- https://discourse.llvm.org/t/how-to-specify-clang-tidy-to-completely-not-check-non-user-files/70381
	-- https://discourse.llvm.org/t/rfc-exclude-issues-from-system-headers-as-early-as-posible/68483

	"--checks=" -- https://clang.llvm.org/extra/clang-tidy/checks/list.html
		.. table.concat({

			-- WARN: large number of checks will lead to slowdown

			"misc-include-cleaner",

			-- modernize-use-designated-initializers is relatively new (Feb 2024).
			-- arch seem to be conservative with updating clang/llvm
			-- https://github.com/llvm/llvm-project/pull/80541

			"bugprone-*",
			"cppcoreguidelines-*",
			"modernize-*",
			"performance-*",
			"readability-*",

			"-clang-diagnostic-pragma-once-outside-header",

			-- "cert-*",
			-- "clang-analyzer-*",
			-- "concurrency-*",
			-- "google-*",
			-- "hicpp-*",
			-- "misc-*",
			-- "portability-*",
		}, ","),
} -- }}}

-- linters cannot be conditionally disabled at config time. they can only be
-- disabled at runtime:
-- https://github.com/mfussenegger/nvim-lint/issues/370#issuecomment-1729671151

-- -- print(vim.inspect(require("lint").linters.selene.condition))
-- require("lint").linters.selene.foo = function(ctx)
-- 	return false
-- 	-- return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
-- end
-- print(vim.inspect(require("lint").linters.selene.foo))

-- -- i don't trust sqruff linting for now
-- require("lint").linters.sqruff = {
-- 	cmd = "sqruff",
-- 	args = { "lint", "-f", "json", "-" },
-- 	stdin = true,
-- 	-- ignore_exitcode = true,
-- }
