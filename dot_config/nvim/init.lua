-- re-sourcing this file (and its dependents) is easy (with :source or
-- :luafile), but clearing all existing state (e.g. keybinds) is not
-- https://neovim.discourse.group/t/reload-init-lua-and-all-require-d-scripts/971/19

require("util")

require("autocmds")
require("binds")
require("filetypes")
require("sets")

require("plugins")
require("pickers")
require("util"):random_colorscheme()

-- TODO: start moving sections with >200 lines out into separate files

-- plugin autocmds {{{

-- format before write, lint after write
-- do both on startup

vim.api.nvim_create_autocmd({
	"BufWritePre",
	-- "VimEnter", -- triggers erroneously on Lazy init (i.e auto-install new plugin)
	"BufReadPost",
}, {
	callback = function()
		if vim.bo.modifiable then
			require("conform").format()
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	pattern = { "*.sql" },
	callback = function()
		if not vim.loop.fs_stat("config.yml") then
			print("No config.yml found, sqls will not be started")
		end

		-- somehow this works, even though we haven't `require`d formatters yet.
		-- specifically, the option is set after buffer is loaded (so we can get
		-- the lines), and (possibly) before conform:format is called
		local d = require("util"):sql_dialect()
		table.insert(require("conform").formatters.sqlfluff.args, 2, "--dialect=" .. d)
		table.insert(require("lint").linters.sqlfluff.args, 2, "--dialect=" .. d)
		-- os.execute("notify-send -- " .. require("conform").formatters.sqlfluff.args[3])
	end,
})

-- trying to make vil files pretend to be json causes problems with both
-- prettier and biome
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.vil" },
	callback = function()
		vim.cmd([[silent! !cat % | jq | sponge %]])
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "VimEnter" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

vim.api.nvim_create_autocmd({
	"ColorScheme",
	"BufReadPre",
}, {
	callback = function()
		vim.api.nvim_set_hl(0, "EyelinerPrimary", { underline = true })
		vim.api.nvim_set_hl(0, "EyelinerSecondary", { underline = true })

		-- enforce hl colorcolumn (citruszest unsets it)
		-- $HOME/.local/share/nvim/lazy/citruszest.nvim/lua/citruszest/highlights/init.lua:29
		-- 8:    ColorColumn = { bg = C.none }, -- used for the columns set with 'colorcolumn'
		-- TODO: should follow lualine main color
		vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#444444" })

		-- enforce diff colors
		local green = "#00CC7A"
		local red = "#FF5454"
		-- https://github.com/neovim/neovim/blob/b3109084c2c3675aa886bf16ff15f50025f30096/runtime/doc/treesitter.txt#L459
		vim.api.nvim_set_hl(0, "@diff.plus", { fg = green })
		vim.api.nvim_set_hl(0, "@diff.minus", { fg = red })
	end,
})

-- hacked together from exec
local function tectonic_build() -- {{{
	if not vim.loop.fs_stat("Tectonic.toml") then
		return
	end

	require("util"):close_unnamed_splits()

	-- .PHONY: build
	--
	-- build:
	-- 	tectonic -X build

	vim.cmd("Make build") -- or Dispatch?

	vim.fn.jobstart([[
lsof ./build/default/default.pdf > /dev/null 2> /dev/null || zathura ./build/default/default.pdf 2> /dev/null &
]])
end -- }}}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.tex" },
	callback = tectonic_build,
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = { "*.tex" },
	callback = tectonic_build,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.sql" },
	callback = function()
		if vim.loop.fs_stat("sqlc.yaml") then
			vim.cmd("Dispatch sqlc vet && sqlc generate")
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.ly" },
	callback = function()
		require("util"):close_unnamed_splits()
		vim.cmd(
			vim.o.lines * 0.2
				.. " new | setlocal buftype=nofile bufhidden=hide noswapfile | silent! 0read! "
				.. string.format("lilypond %s 2>&1", vim.fn.expand("%"))
		)
	end,
})

-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "LazyVimStarted",
-- 	command = "lua require('lazy').sync({ show = false })",
-- 	desc = "Sync plugins",
-- })

-- https://github.com/folke/lazy.nvim/issues/1200#issuecomment-1867407116
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyCheck",
	-- pattern = "LazyVimStarted",
	desc = "Update lazy.nvim plugins",
	callback = function(event)
		-- local start_time = os.clock()
		require("lazy").sync({ wait = false, show = false })
		-- local end_time = os.clock()
		-- print("Lazy plugins synced in " .. (end_time - start_time) * 1000 .. "ms")
		-- print(vim.print(event))
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GitConflictDetected",
	callback = function()
		-- engage.conflict_buster()
		vim.notify("Conflict(s) detected in " .. vim.fn.expand("<afile>"))
		-- vim.o.foldenable = false

		vim.cmd("LspStop")
		vim.diagnostic.enable(false)
		-- vim.treesitter.stop()

		vim.cmd("norm gg")
		vim.cmd("GitConflictNextConflict")

		-- -- https://github.com/wochap/nvim/blob/60920de61ae887f04994a4f253e19c0494d33023/lua/custom/custom-plugins/configs/git-conflict.lua#L4
		-- vim.keymap.set("n", "[c", "<cmd>GitConflictPrevConflict<CR>|zz")
		-- vim.keymap.set("n", "]c", "<cmd>GitConflictNextConflict<CR>|zz")
		-- vim.keymap.set("n", "cq", "<cmd>GitConflictListQf<CR>")
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GitConflictResolved",
	callback = function()
		vim.notify("Conflict(s) resolved")
		vim.cmd("LspRestart")
		vim.diagnostic.enable()
	end,
})

vim.api.nvim_create_autocmd("TabLeave", {
	callback = function()
		vim.g.lasttab = vim.fn.tabpagenr()
	end,
})

-- https://github.com/xvzc/chezmoi.nvim?tab=readme-ov-file#treat-all-files-in-chezmoi-source-directory-as-chezmoi-files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	-- dot* excludes .git/*
	pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/dot*" },
	callback = function(ev)
		vim.schedule(function()
			require("chezmoi.commands.__edit").watch(ev.buf)
		end)
		vim.api.nvim_set_current_dir(os.getenv("HOME") .. "/.local/share/chezmoi")
		-- print("chezmoi watching")
	end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
	-- git blame should always be displayed inline, never in lualine
	-- git blame should be disabled in narrow windows as it is not useful
	callback = function()
		vim.cmd(vim.o.columns > 170 and "GitBlameEnable" or "GitBlameDisable")
	end,
})

-- }}}
-- plugin binds {{{

-- vim.keymap.set("n", "<leader>gB", ":GitBlameToggle<cr>") -- must be explicitly enabled on mac (due to lacking horizontal space)
vim.keymap.set("n", "<leader>J", ":TSJToggle<cr>")

-- vim-fugitive
vim.keymap.set("n", "<leader>gP", ":Git add %<cr>", { desc = "add current buffer (patch)" })
vim.keymap.set("n", "<leader>gU", ":Git checkout -- %<cr>", { desc = "discard all uncommitted changes" })
vim.keymap.set("n", "<leader>ga", ":Gwrite<cr>", { desc = "add current buffer" })
vim.keymap.set("n", "<leader>gp", ":Dispatch! git push<cr>", { desc = "git push (async)" })

local function commit_staged()
	-- {{{
	if not require("util"):in_git_repo() then
		print("not in git repo")
	elseif -- any changes have been staged (taken from gc)
		-- commit currently staged chunk(s)
		require("util"):get_command_output("git diff --name-only --cached --diff-filter=AM | grep .") ~= ""
	then
		vim.cmd("Git commit --quiet -v")
	elseif -- current file has changes
		-- commit entire file
		-- exits with 1 if there were differences
		not require("util"):command_ok("git diff --quiet " .. vim.api.nvim_buf_get_name(0))
	then
		-- do i ever need to commit a whole file while there are staged chunks? remains to be seen
		vim.cmd("Git commit --quiet -v %")
	else
		print("no changes to stage")
	end
end -- }}}

vim.keymap.set("n", "<leader>c", commit_staged, { desc = "commit current buffer/hunks" })

for _, k in pairs({ "C", "gc" }) do
	vim.keymap.set("n", "<leader>" .. k, function()
		print("deprecated; use <leader>c")
	end, { desc = "deprecated" })
end

vim.keymap.set("n", "<leader>gC", function()
	-- TODO: git add % + git commit --amend --no-edit
	if not require("util"):command_ok("git status --porcelain | grep -q '^M'") then
		print("No hunks staged")
		return
	end

	vim.cmd("Git commit --quiet --amend --no-edit")
	print(
		string.format(
			"Added hunk(s) to previous commit: %s",
			require("util"):get_command_output("git log -n 1 --pretty=format:%s")
		)
	)
end, { desc = "append currently staged hunks to previous commit" })

-- use gdm instead
-- vim.keymap.set("n", "<leader>gd", function()
-- 	vim.cmd("vertical Git -p diff master...HEAD") -- J and K are smartly remapped, apparently
-- end, { desc = "diff current HEAD against master" })

-- vim.keymap.set("n", "<leader>gB", ":BlameToggle<cr>")
vim.keymap.set("n", "<leader>gS", ":Gitsigns stage_buffer<cr>", { desc = "stage all hunks in current buffer" }) -- same as :Gwrite, but without making the commit
vim.keymap.set("n", "<leader>gh", ":Gitsigns stage_hunk<cr>") -- more ergonomic than gs? (debatable)
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<cr>")
vim.keymap.set("v", "gs", ":Gitsigns stage_hunk<cr>")

vim.keymap.set("n", "<leader>go", function()
	-- GitBlameOpenFileURL may produce bogus URLs, usually when files are moved.
	-- in such cases, GitBlameOpenCommitURL may be better
	-- https://github.com/f-person/git-blame.nvim/issues/103
	-- vim.cmd("GitBlameOpenFileURL")

	-- GitBlameOpenFileURL always opens the file at the commit of the current
	-- line. sometimes it is better to just construct url with latest commit of
	-- current branch
	local base = require("util")
		:get_command_output("git config --get remote.origin.url", true)
		:gsub("git@", "https://")
		:gsub("com:", "com/")
		:gsub(".git$", "")
	local branch = require("util"):get_command_output("git branch --show-current", true)
	local path = require("util"):get_command_output("git ls-files --full-name " .. vim.fn.expand("%:p"), true)

	local url = string.format("%s/blob/%s/%s", base, branch, path)
	if base:match("gitlab") then
		url = url:gsub("/blob/", "/-/blob/")
	end
	vim.fn.jobstart("xdg-open " .. url)

	-- $url/-/blob/$branch/$path

	-- vim.cmd("GitBlameOpenCommitURL")

	-- -- ubuntu xdg-open may not work
	-- vim.cmd("GitBlameCopyCommitURL")
	-- vim.fn.jobstart([[sleep 0.5 ; xdg-open "$(xclip -o -sel c)" || firefox "$(xclip -o -sel c)"]])
end, { desc = "view commit of current line (in browser)" })

-- unlike telescope diagnostics, trouble is persistent (per tab)
vim.keymap.set("n", "<leader>j", function()
	require("trouble").open({ mode = "diagnostics" })
	require("trouble").next({ skip_groups = true, jump = true })
	-- require("trouble").close() -- causes every other invocation to error
	-- if require("trouble").is_open() then
	-- 	-- trouble can jump across files, vim.diagnostic can't
	-- 	require("trouble").next({ skip_groups = true, jump = true })
	-- else
	-- 	vim.diagnostic.goto_next()
	-- end
end, { desc = "next diagnostic message" })

vim.keymap.set("n", "<leader>k", function()
	require("trouble").open({ mode = "diagnostics" })
	require("trouble").prev({ skip_groups = true, jump = true })
end, { desc = "previous diagnostic message" })

vim.keymap.set("n", "<leader>l", function()
	require("trouble").toggle({ mode = "diagnostics", focus = true })
end)

-- google_docstrings
-- https://github.com/danymat/neogen#supported-languages
vim.keymap.set("n", "<leader>ng", require("neogen").generate, { noremap = true, silent = true })

-- }}}
-- telescope {{{

-- must be declared after loading plugins
local telescope = require("telescope")
local telescope_b = require("telescope.builtin")

local telescope_actions = require("telescope.actions")

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- mostly to avoid find from mac home
		if vim.fn.argv(0) == "" and require("util"):in_git_repo() and vim.bo.filetype ~= "man" then
			telescope_b.find_files()
		end
	end,
})

telescope.setup({

	-- :h telescope.defaults
	defaults = {

		-- https://github.com/nvim-telescope/telescope.nvim/blob/24778fd72fcf39a0b1a6f7c6f4c4e01fef6359a2/lua/telescope/config.lua#L144

		border = true, -- if false, all text is disabled!
		dynamic_preview_title = true, -- useful, since you don't have to look away from the right pane
		layout_config = { preview_cutoff = 0 },
		layout_strategy = require("util"):get_layout_strategy(),
		prompt_title = false, -- this is almost always overridden anyway
		results_title = false,
		sorting_strategy = "descending", -- closest match on bottom (near prompt)
		wrap_results = true, -- doesn't apply to diagnostics; use line_width (below)

		preview = {
			-- msg_bg_fillchar = "╱",
			msg_bg_fillchar = "",
			-- borderchars = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
		},

		mappings = {

			-- https://github.com/SpaceVim/SpaceVim/blob/b462646223dfb8a7b19fb3999edffd4d0dd8aea1/bundle/telescope.nvim/lua/telescope/mappings.lua#L133
			-- https://github.com/nvim-telescope/telescope.nvim/blob/24778fd72fcf39a0b1a6f7c6f4c4e01fef6359a2/doc/telescope.txt#L2617
			i = {

				-- ["<c-i>"] = telescope_actions.preview_scrolling_up,
				-- ["<c-s-t>"] = require("trouble.sources.telescope").open(),
				-- ["<c-s-t>"] = telescope_trouble.open_with_trouble,
				-- ["<c-s>"] = telescope_actions.select_horizontal, -- open in horiz split
				-- ["<c-u>"] = telescope_actions.preview_scrolling_down,
				-- ["<c-x>"] = require("telescope.actions.layout").toggle_prompt_position,
				["<c-b>"] = telescope_actions.preview_scrolling_up,
				["<c-c>"] = telescope_actions.close,
				["<c-f>"] = telescope_actions.preview_scrolling_down,
				["<c-j>"] = telescope_actions.move_selection_next,
				["<c-k>"] = telescope_actions.move_selection_previous,
				["<c-p>"] = require("telescope.actions.layout").toggle_preview,
				["<c-t>"] = require("telescope.actions.layout").cycle_layout_next, -- TODO: why must input twice?
				["<cr>"] = telescope_actions.select_tab_drop, -- reuse tab, if buffer already open
				["<esc>"] = telescope_actions.close,

				-- ["<c-l>"] = function() -- ???
				-- 	vim.cmd("normal E")
				-- end,
			},

			n = {

				-- ["t"] = require("trouble.sources.telescope").open(),
				-- ["t"] = telescope_trouble.open_with_trouble,
				["<c-c>"] = telescope_actions.close,
				["<c-s>"] = telescope_actions.select_horizontal,
				["<cr>"] = telescope_actions.select_tab_drop,
			},
		},
	},

	-- https://github.com/RobinTruax/resolution/blob/63cbc5a50eee8df039f54e593ed377f04e60e583/lua/plugins/telescope/picker_opts.lua#L20

	-- :h telescope.builtin
	pickers = {

		colorscheme = { enable_preview = true },
		find_files = { prompt_title = "find" },
		live_grep = { prompt_title = "ripgrep" },
		lsp_definitions = { show_line = false },
		lsp_document_symbols = { path_display = "hidden", show_line = false },
		lsp_dynamic_workspace_symbols = { show_line = false },
		lsp_implementations = { show_line = false },
		lsp_incoming_calls = { show_line = false },
		lsp_outgoing_calls = { show_line = false },
		lsp_references = { show_line = false },
		lsp_type_definitions = { show_line = false },
		lsp_workspace_symbols = { show_line = false },

		git_branches = {
			show_remote_tracking_branches = false,
			mappings = {
				i = { ["<cr>"] = telescope_actions.select_default }, -- override the overridden default
			},
		},

		git_status = {
			mappings = {
				-- ironically, <c-i> is a perfectly fine mapping
				-- https://github.com/nvim-telescope/telescope.nvim/blob/a4ed82509/lua/telescope/actions/init.lua#L885
				i = {
					["<cr>"] = function()
						local selection = require("telescope.actions.state").get_selected_entry()
						if selection.status:sub(2) ~= " " then
							-- starts in insert mode for some reason, which is nice
							vim.cmd("Git commit -v " .. selection.value)
						end
					end,
				},
				-- n = { ["<cr>"] = telescope_actions.git_staging_toggle },
			},
		},

		--   -- use trouble instead
		-- diagnostics = {
		-- 	-- :h telescope.builtin.diagnostics()
		-- 	-- disable_coordinates = true,
		-- 	line_width = "full", -- important
		-- },
	},

	extensions = {

		adjacent = { exclude_binary = true },

		heading = {
			-- TODO: sort normal
			treesitter = true,
			picker_opts = {
				-- layout_config = { width = 0.8, preview_width = 0.5 },
				layout_strategy = require("util"):get_layout_strategy(),
				sorting_strategy = "ascending",
			},
		},
	},
})

-- extensions must be loaded after `telescope.setup`
telescope.load_extension("heading")

-- }}}
-- telescope binds {{{

vim.api.nvim_create_autocmd({ "VimEnter", "VimResized" }, {
	callback = function()
		require("telescope").setup({
			defaults = { layout_strategy = require("util"):get_layout_strategy() },
		})
	end,
})

-- rarely used
vim.keymap.set("n", "<leader>b", telescope_b.buffers, { desc = "open buffers" })
vim.keymap.set("n", "<leader>f", telescope_b.find_files, { desc = "find" })
vim.keymap.set("n", "<leader>t", telescope.extensions["telescope-tabs"].list_tabs) -- TODO: if 1 tab, noop

-- telescope.treesitter is less useful than telescope_b.lsp_*_symbols
-- vim.keymap.set("n", "<leader>F", telescope.oldfiles, { desc = "recently opened files" })
vim.keymap.set("n", "<leader>.", telescope.extensions.adjacent.adjacent) -- TODO: ignore binary
vim.keymap.set("n", "<leader>/", telescope_b.live_grep, { desc = "ripgrep" }) -- entire project
vim.keymap.set("n", "<leader>?", telescope_b.keymaps, { desc = "keymaps" })
vim.keymap.set("n", "<leader>e", telescope_b.git_files, { desc = "git ls-files" })
vim.keymap.set("n", "<leader>gB", telescope_b.git_branches, { desc = "git branches" })
vim.keymap.set("n", "<leader>gS", telescope_b.git_status, { desc = "git status" })

local git_log_cmd = {
	"git",
	"log",
	"--pretty=%h \t %ad \t %s", -- oneline lacks date
	"--abbrev-commit",
	"--no-merges",
	"--first-parent",
}

-- vim.keymap.set("n", "<leader>gl", telescope_b.git_commits, { desc = "git log" })

vim.keymap.set("n", "<leader>gl", function()
	-- there is probably a native vim api for this, but whatever
	local branch = require("util"):get_command_output("git branch --show-current", true)
	local master =
		require("util"):get_command_output("git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null | cut -d/ -f4", true)

	telescope_b.git_commits({
		-- git_command = vim.list_extend(git_log_cmd, branch ~= master and { branch .. "...HEAD" } or {}),
		git_command = vim.list_extend(git_log_cmd, { branch ~= master and branch .. "...HEAD" or nil }),
	})
end, { desc = "git log (current branch only)" })

vim.keymap.set("n", "<leader>gL", function()
	telescope_b.git_commits({
		git_command = vim.list_extend(git_log_cmd, { vim.fn.expand("%") }),
	})
end, { desc = "git log (current file only)" })

-- requires user input (or visual selection):
-- git log --author=$(git config --get user.email) --branches --format="%h%x09%S%x09%s" --pickaxe-regex -S

-- vim.keymap.set("n", "<leader>?", telescope_b.help_tags, { desc = "search help" }) -- let's face it; i never use this

-- }}}

require("lsp")
require("linters")
require("formatters")

-- completer: nvim-cmp + luasnip {{{
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").load({ -- `from_vscode` is a misleading name; this is for friendly-snippets
	include = {
		-- i only need snippets for languages without an lsp (e.g. htmldjango)

		"css",
		"html",
		"htmldjango",
		"jsx",
		"markdown",
		-- "javascript", -- where my jsx snippets at??
	},
})

-- https://github.com/m3idnotfree/Zkdqay9Co4/blob/f86e44c7ca3de055eb79e19e16557cea01c11bc5/nvim/snippets/gitcommit/init.lua
-- seems neat, until you see 'util.luasnip.format':
-- https://github.com/m3idnotfree/Zkdqay9Co4/blob/f86e44c7ca3de055eb79e19e16557cea01c11bc5/nvim/lua/util/luasnip/format.lua
-- luasnip.filetype_extend("gitcommit", foo)

luasnip.config.setup({})

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({

		-- ["<c-space>"] = cmp.mapping.complete({}),
		["<c-,>"] = cmp.mapping.scroll_docs(4),
		["<c-m>"] = cmp.mapping.scroll_docs(-4),

		["<c-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<c-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

		["<cr>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),

		["<tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{
			name = "nvim_lsp",
			-- disable lsp 'Snippet's (somewhat annoying for rust, e.g. 'rc~')
			-- this restriction can easily be made rust-specific
			-- https://neovim.discourse.group/t/how-to-disable-lsp-snippets/922/5
			entry_filter = function(entry)
				return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
			end,
		},
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
		-- { name = "gitcommit" }, -- dunno how this is supposed to work -- https://github.com/Cassin01/cmp-gitcommit#usage
	},
})

require("cmp-gitcommit").setup({}) -- i don't really use this

-- }}}
