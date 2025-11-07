local M = {}

local util = require("util")

local git_dir = vim.fs.root(0, ".git")

local git = string.format("git -C %s ", git_dir)
local has_remote = git_dir ~= nil and util:get_command_output(git .. "remote -v") ~= ""

---@param from string
---@param to string
---@return number
local function commits_ahead(from, to)
	-- note: this will fail for detached head
	local cmd = string.format("%s rev-list --left-right --count %s...%s | cut -f2", git, from, to)
	return assert(tonumber(util:get_command_output(cmd, true)))
end

-- can check .git/HEAD, but a shell is fine for now
local curr_branch = git_dir ~= nil and util:get_command_output(git .. "branch --show-current", true) -- or ""

-- this file will be watched for changes
local head_file = string.format("%s/.git/refs/heads/%s", git_dir, curr_branch)
local master_file = string.format("%s/.git/refs/remotes/origin/%s", git_dir, "master")

---@type { [string]: number }
M.cache = {}

if git_dir and has_remote then
	-- print(f)

	M.head_sha = util:read_file(head_file) -- nil if no commits made
	if M.head_sha then
		M.origin_master_sha = util:read_file(master_file) or util:get_command_output(git .. " rev-parse HEAD", true)
		M.cache[(M.origin_master_sha or "") .. M.head_sha] = commits_ahead(M.origin_master_sha, M.head_sha)
	end

	-- ["origin/" .. M.curr_branch .. M.head_sha] = commits_ahead(M.origin_master_sha, M.head_sha),
end

-- print(vim.inspect(M.cache))
-- os.execute("notify-send sarskjdfl")

-- https://github.com/nvim-lualine/lualine.nvim/blob/15884cee63a8/lua/lualine/components/branch/git_branch.lua
-- under the hood, every lualine func is always executed ~10 times per second
-- (even the native git_branch). the key is to cache known states and reduce
-- file reads / shell spawns as far as possible

-- note: this func is constantly executed!
local watcher = assert(vim.uv.new_fs_event())
local watcher2 = assert(vim.uv.new_fs_event())
local function update_branch()
	watcher:stop()
	watcher2:stop()

	watcher:start(head_file, {}, vim.schedule_wrap(update_branch))
	watcher2:start(master_file, {}, vim.schedule_wrap(update_branch))

	local new_head_sha = util:read_file(head_file)
	local new_master_sha = util:read_file(master_file)

	-- os.execute("notify-send " .. M.head_sha)

	-- it is probably impossible for both shas to change simultaneously

	-- made a commit
	if M.head_sha ~= new_head_sha and M.origin_master_sha then
		-- M.cache[M.origin_master_sha .. new_head_sha] = commits_ahead(M.origin_master_sha, new_head_sha)
		-- increment, so git rev-list needs to be run only once. note, however,
		-- that commit --amend will lead to erroneous increment!
		M.cache[M.origin_master_sha .. new_head_sha] = M.cache[M.origin_master_sha .. M.head_sha] + 1
		M.head_sha = new_head_sha

	-- pushed
	elseif new_master_sha and M.origin_master_sha ~= new_master_sha then
		-- will probably be 0
		-- M.cache[new_master_sha .. M.head_sha] = commits_ahead(new_master_sha, M.head_sha)
		M.cache[new_master_sha .. M.head_sha] = 0
		M.origin_master_sha = new_master_sha
	end
end

if git_dir then
	update_branch()
end

function M:foo()
	-- 1. i never switch branches within vim
	-- 2. i always edit files in the current branch (if a branch exists at all)
	--
	-- i am not interested in watching branch changes. i am, however, interested
	-- in knowing how many commits i am ahead of remote

	if not git_dir or not M.head_sha then
		-- os.execute("notify-send nogit")
		return "" -- not nil!
	end

	local k = M.origin_master_sha .. M.head_sha
	local v = M.cache[k]

	if v > 0 then
		return string.format( --
			"%s[%s+%s]",
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
