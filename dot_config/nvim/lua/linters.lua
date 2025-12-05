-- lua print(require("lint").get_running()[1])

---@type {[string]: table}
local linters = {
	-- https://github.com/mfussenegger/nvim-lint#available-linters

	-- bashls now includes shellcheck
	-- css = { vim.uv.fs_stat("foo") and "stylelint" }, -- TODO: 'no configuration provided'
	-- elixir = { "credo" }, -- where da binary at
	-- lua = { "selene" }, -- disabled until i can get condition to work
	-- rust = { "clippy" }, -- part of the lsp
	["yaml.github"] = { "zizmor" },
	c = { "clangtidy" },
	cpp = { "clangtidy" },
	d2 = { "d2" },
	dockerfile = { "hadolint" }, -- can be quite noisy
	dotenv = { "dotenv_linter" },
	gitcommit = { "gitlint" },
	go = { "golangcilint" },
	html = { "markuplint" },
	htmldjango = { "djlint" },
	javascript = { "biomejs" }, -- should resolve to repo root
	javascriptreact = { "biomejs" },
	lua = { vim.fn.executable("luacheck") == 1 and "luacheck" or nil },
	make = { "checkmake", "checkmake2" },
	proto = { "buf_lint" },
	python = { "ruff" }, -- may have duplicate with ruff lsp
	typescript = { "biomejs" },
	typescriptreact = { "biomejs" },
	yaml = { "yaml_shellcheck" },

	sql = {
		"sqlfluff", -- slow lint is fine, since async
		vim.fn.executable("squawk") == 1 and "squawk" or nil, -- https://squawkhq.com/
	},

	markdown = {
		"markdownlint", -- https://github.com/DavidAnson/markdownlint?tab=readme-ov-file#rules--aliases
		"proselint", -- https://github.com/amperser/proselint?tab=readme-ov-file#checks
	},
}

-- for _, t in pairs(linters) do
-- 	table.insert(t, "cspell")
-- end

if vim.fn["globpath"](".", "commitlint.config.js") ~= "" then
	-- npm install --save-dev @commitlint/{cli,config-conventional}
	-- echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
	table.insert(linters.gitcommit, "commitlint")
end

-- https://github.com/orumin/dotfiles/blob/62d7afe8a9bf53/nvim/lua/configs/plugin/lsp/linter_config.lua#L7
require("lint").linters_by_ft = linters

-- TODO: configure linters https://golangci-lint.run/usage/linters/#asasalint
-- decorder, dogsled, errchkjson, errorlint, funlen, goconst, grouper?, iface,
-- importas, lll, nestif, nilnil, nlreturn, nolintlint, nonamedreturns,
-- tagalign, usestdlibvars, unconvert, unparam, unused, varnamelen, whitespace
-- require("lint").linters.golangci.args = {}

require("lint").linters.markdownlint.args = {
	"--disable",
	"MD010", -- no hard tabs (they only appear in Go blocks)
	"--stdin",
}

local x = vim.fs.root(0, "biome.json")
require("lint").linters.biomejs.cmd = x and x .. "/node_modules/.bin/biome" or "biome"

-- https://github.com/rrunner/dotfiles/blob/d55d90ed5d481fc/nvim/.config/nvim/lua/plugins/linting.lua#L17
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
	-- real    0m0.483s

	-- https://discourse.llvm.org/t/how-to-specify-clang-tidy-to-completely-not-check-non-user-files/70381
	-- https://discourse.llvm.org/t/rfc-exclude-issues-from-system-headers-as-early-as-posible/68483

	"--checks=" -- https://clang.llvm.org/extra/clang-tidy/checks/list.html
		.. table.concat({

			-- WARN: large number of checks will lead to slowdown

			-- echo '#include <stdio.h>' > foo.c ; clang-tidy --checks='-*,misc-include-cleaner' foo.c
			-- works in cli, but not in vim, possibly because it traverses ast?
			-- https://clang.llvm.org/extra/clang-tidy/checks/misc/include-cleaner.html
			"misc-include-cleaner",

			-- modernize-use-designated-initializers is relatively new (Feb 2024).
			-- arch seem to be conservative with updating clang/llvm
			-- https://github.com/llvm/llvm-project/pull/80541

			"bugprone-*", -- https://clang.llvm.org/extra/clang-tidy/checks/bugprone/argument-comment.html
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

require("lint").linters.squawk = { -- {{{
	cmd = "squawk",
	args = { "--reporter", "Json" },
	stdin = false,

	parser = function(output, _)
		local items = {}

		local severities = {
			Warning = vim.diagnostic.severity.WARN,
		}

		if output == "" then
			return items
		end

		local decoded = vim.json.decode(output) or {}
		local bufpath = vim.fn.expand("%:p")

		for _, diag in ipairs(decoded) do
			if diag.file == bufpath then
				table.insert(items, {
					source = "squawk",
					lnum = diag.line, -- squawk tends to misreport lnum, and does not report end_lnum
					col = 0,
					end_col = 999,
					message = diag.messages[1].Note, -- .. "\n\n" .. diag.messages[2].Help,
					severity = assert(severities[diag.level], "missing mapping for severity " .. diag.level),
				})
			end
		end

		return items
	end,
} -- }}}

require("lint").linters.luacheck.args = vim.list_extend( --
	require("lint").linters.luacheck.args,
	{
		"--globals",
		"vim",
	}
)

-- require("lint").linters.cspell.args = vim.list_extend( --
-- 	require("lint").linters.cspell.args,
-- 	{
-- 		"--config",
-- 		vim.env.HOME .. "/.config/cspell/config.yaml",
-- 	}
-- )

require("lint").linters.d2 = { -- {{{
	cmd = "d2",
	args = { "validate" },

	ignore_exitcode = true,
	stdin = false,
	stream = "stderr",

	parser = function(output, _)
		if output:find("Success!") then
			return {}
		end

		local items = {}

		-- local bufpath = vim.fn.expand("%:p")

		for line in output:gmatch("%d+:%d+: [^\n]+") do
			-- err: oss.terrastruct.com/d2/d2cli.validateCmd: 2:12: missing value after colon
			-- err: 7:1: unexpected map termination character } in file map
			local _, _, lnum, col, msg = string.find(line, "(%d+):(%d+): ([^\n]+)")

			table.insert(items, {
				source = "d2",
				lnum = tonumber(lnum) - 1,
				col = tonumber(col),
				end_col = 999,
				message = msg,
				severity = vim.diagnostic.severity.ERROR,
			})
		end

		return items
	end,
} -- }}}

-- use sed to transform a shell-containing file into valid shell script
-- (preserving line numbers), then call shellcheck
---@ param sed_cmd string
local function shellcheck_wrapper(sed_cmd)
	return {
		cmd = "bash",
		args = {
			"-c",
			string.format(
				[[ < "$1" sed -r '%s' | ~/.local/share/nvim/mason/bin/shellcheck --shell=bash --exclude=2164,2103,2091 -f json - ]],
				sed_cmd
			),
			vim.fn.expand("%"),
		},

		stdin = false,
		ignore_exitcode = true,

		parser = function(output, _)
			local items = {}

			if output == "" then
				return items
			end

			for _, diag in ipairs(vim.json.decode(output) or {}) do
				table.insert(items, {
					source = "shellcheck",
					lnum = diag.line - 1,
					col = vim.bo.filetype == "yaml" and 6 or 1,
					end_col = 999,
					message = diag.message,
					severity = vim.diagnostic.severity.WARN,
				})
			end

			return items
		end,
	}
end

require("lint").linters.checkmake2 = shellcheck_wrapper([[/^[^\t]/ s/^/#/; s/\$\$/$/g]])

require("lint").linters.yaml_shellcheck = shellcheck_wrapper([[
  s/^/#/                    # comment everything
  # /script:$/,/^#$/  s/^#//g # uncomment script: sections
  /script:$/,/^#($|  [^ ])/  s/^#//g # uncomment script: sections
  /script:$/        s/^/#/  # comment script: again
  s/^[ |>-]+//              # remove leading symbols
]])

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
