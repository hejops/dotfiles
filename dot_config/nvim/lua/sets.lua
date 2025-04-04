-- if empty(glob(&directory)) | call mkdir(&directory, "p") | endif
-- if empty(glob(&undodir)) | call mkdir(&undodir, "p") | endif

-- trailing double slashes prevent collisions when editing files with same basename
vim.o.directory = vim.fn.expand("~/.vim/swap//") -- directory is an awful name for a hardcode
vim.o.undodir = vim.fn.expand("~/.vim/undo2//")

-- vim.o.guicursor = vim.o.guicursor .. "a:blinkon0"
-- vim.o.switchbuf ..= "usetab,newtab" -- open quickfix files (?) etc in new tab -- https://stackoverflow.com/a/6853779
-- vim.o.switchbuf = table.concat(vim.o.switchbuf, "usetab,newtab")

vim.opt.formatoptions:append("ro") -- auto insert comment on newline; only works in languages that have a default commentstring (i.e. not json)

local titlestring = "%f" -- path to file, relative to cwd
-- .. "[%LL] " -- lines
-- .. "%a" -- "Argument list status as in default title." (?)
-- .. "%r" -- [RO]
-- .. "%m" -- [+]

-- vim.g.ftplugin_sql_omni_key = "<C-j>" -- default <C-c> is annoying
-- vim.g.netrw_browse_split=4	-- open in vsplit
-- vim.o.spellsuggest = 5 -- show less suggestions
-- vim.o.titleold = vim.fn.getcwd() -- set title on exit; if empty, title remains unchanged
vim.g.c_syntax_for_h = true
vim.g.editorconfig = false
vim.g.lasttab = 1
vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 0 -- set pwd correctly
vim.g.netrw_liststyle = 3 -- tree
vim.g.netrw_preview = 1 -- press p (not automatic)
vim.g.netrw_winsize = 25
vim.o.autochdir = false -- if true, git commit <file> will cd to .git, usually producing an annoying gitsigns error
vim.o.autoindent = true
vim.o.autoread = true -- prevent the annoying prompt when a file is changed
vim.o.autowrite = true -- write when changing buffer (e.g. C-6)
vim.o.background = "dark"
vim.o.backup = false -- actual copies of the file
vim.o.backupcopy = "yes" -- always use the same inode -- https://www.youtube.com/watch?v="BKSK"1Dsuz_M
vim.o.belloff = "all"
vim.o.clipboard = "unnamed,unnamedplus" -- access system clipboard -- https://stackoverflow.com/a/30691754
vim.o.cmdheight = 2 -- give more space for displaying messages
vim.o.colorcolumn = "80"
vim.o.cursorline = true
vim.o.display = "lastline" -- don't show those ugly @'s
vim.o.foldenable = false -- open all folds at startup
vim.o.foldmethod = "marker"
vim.o.hidden = true -- keep unloaded buffers in memory (speeds up switching)
vim.o.hlsearch = true -- highlight searches
vim.o.ignorecase = true
vim.o.incsearch = true -- start search while typing
vim.o.joinspaces = false -- prevent double space after reflowing (gq) text
vim.o.laststatus = 2 -- always have a status line
vim.o.lazyredraw = true -- only rerender screen at the end of a macro
vim.o.linebreak = true -- wrap without breaking lines; comments ignore linebreak, i.e. they break anyway
vim.o.listchars = "tab:▸ ,eol:¬,trail:·"
vim.o.modeline = true -- to use # vim:ft=...
vim.o.modelines = 5
vim.o.mouse = "a" -- use mouse to click, scroll buffer (not lines)
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 4 -- start scrolling when cursor approaches end
vim.o.shiftround = true
vim.o.showbreak = "…"
vim.o.showcmd = true -- show command suggestions (?)
vim.o.showmode = false -- disables redundant --- INSERT ---
vim.o.showtabline = 2
vim.o.signcolumn = "yes" -- 'number' merges sign and number, which i don't like
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true -- open new split on bottom/right
vim.o.startofline = false -- don't put cursor at start of line (e.g. after gg)
vim.o.termguicolors = true -- enable 24-bit colour
vim.o.timeout = true
vim.o.timeoutlen = 1000
vim.o.title = true -- set custom window title
vim.o.titleold = "___" -- HACK: see wezterm.lua
vim.o.titlestring = titlestring
vim.o.ttimeoutlen = 0 -- re-enter normal mode instantly
vim.o.ttyfast = true -- speed improvement?
vim.o.undofile = true -- write undo history to a file
vim.o.updatetime = 300 -- faster prompts (default 4000)
vim.o.whichwrap = "h,l" -- hl can cross lines
vim.o.wildignore = table.concat({ "*/.git/*", "*/.DS_Store", "*.o", "*~", "*.pyc" }, ",")
vim.o.wildmenu = true -- show suggestions above cmdline
vim.o.winborder = "single" -- https://github.com/neovim/neovim/pull/31074/files; vim.inspect(vim.version().minor >= 11)
vim.o.wrap = true
vim.o.wrapmargin = 0
