local M = {}

local util = require("util")

local git_dir = vim.fs.root(0, ".git")
local in_git_dir = git_dir ~= nil
local has_remote = util:get_command_output(string.format("git -C %s remote -v", git_dir)) ~= ""

---@param from string
---@param to string
---@return number
local function commits_ahead(from, to)
	-- note: this will fail for detached head

	-- the starting commit can always be specified 'loosely' (i.e. no need sha).
	-- the ending commit must always be specified as a sha, because it can and
	-- will change as commits are made.

	local cmd = string.format("git -C %s rev-list --left-right --count %s...%s | cut -f2", git_dir, from, to)
	return assert(tonumber(util:get_command_output(cmd, true)))
end

-- can check .git/HEAD, but a shell is fine for now
local curr_branch = util:get_command_output(string.format("git -C %s branch --show-current", git_dir), true) or ""

-- this file will be watched for changes
local f = string.format("%s/.git/refs/heads/%s", git_dir, curr_branch)

if in_git_dir then
	-- print(f)
	local branch_head_file_contents = assert(io.open(f))
	M.head_sha = branch_head_file_contents:read()
	branch_head_file_contents:close()
end

-- print(
-- 	M.head_sha, --
-- 	commits_ahead("origin/master", M.head_sha),
-- 	"x"
-- )

---@type { [string]: number }
M.cache = {}

if M.head_sha and has_remote then
	M.cache["origin/master" .. M.head_sha] = commits_ahead("origin/master", M.head_sha)
	-- ["origin/" .. M.curr_branch .. M.head_sha] = commits_ahead("origin/master", M.head_sha),
end

-- print(vim.inspect(M.cache))
-- os.execute("notify-send sarskjdfl")

-- https://github.com/nvim-lualine/lualine.nvim/blob/15884cee63a8/lua/lualine/components/branch/git_branch.lua
-- under the hood, every lualine func is always executed ~10 times per second
-- (even git_branch). the key is to cache known states and reduce file reads /
-- shell spawns as far as possible

-- note: this func is constantly executed!
local watcher = assert(vim.loop.new_fs_event())
local function update_branch()
	-- active_bufnr = tostring(vim.api.nvim_get_current_buf())
	watcher:stop()
	watcher:start(f, {}, vim.schedule_wrap(update_branch))

	local branch_head_file_contents = assert(io.open(f))
	local new_head_sha = branch_head_file_contents:read()
	branch_head_file_contents:close()

	-- os.execute("notify-send " .. M.head_sha)

	if M.head_sha == new_head_sha then
		return
	end

	-- M.cache["origin/master" .. new_head_sha] = commits_ahead("origin/master", M.head_sha)

	-- increment, so git rev-list needs to be run only once
	M.cache["origin/master" .. new_head_sha] = M.cache["origin/master" .. M.head_sha] + 1
	M.head_sha = new_head_sha
end

if in_git_dir then
	update_branch()
end

function M:foo()
	-- 1. i never switch branches within vim
	-- 2. i always edit files in the current branch (if a branch exists at all)
	--
	-- i am not interested in watching branch changes. i am, however, interested
	-- in knowing how many commits i am ahead of remote

	if not in_git_dir then
		-- os.execute("notify-send nogit")
		return "" -- not nil!
	end

	local k = "origin/master" .. M.head_sha
	local v = M.cache[k]

	if v > 0 then
		return string.format(
			"%s[%s+%s]", --
			curr_branch,
			curr_branch == "master" and "" or "m",
			v
		)
	else
		-- TODO: handle origin/branch
		return curr_branch
	end

	-- if ahead_m == "0" then
	-- 	return branch
	-- elseif ahead_b == "0" then
	-- 	return branch .. string.format("[m+%s]", ahead_m)
	-- else
	-- 	return branch .. string.format("[m+%s|b+%s]", ahead_m, ahead_b)
	-- end
end

return M
