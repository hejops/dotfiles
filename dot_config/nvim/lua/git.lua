M = {}

-- the starting commit can always be specified 'loosely' (i.e. no need sha).
-- the ending commit must always be specified as a sha, because it can and will
-- change.

local git_dir = vim.fs.root(0, ".git")

---@param from string
---@param to string
---@return number
local function commits_ahead(from, to)
	-- note: this will fail for detached head
	local cmd = string.format([[git -C %s rev-list --left-right --count "%s...%s" | cut -f2]], git_dir, from, to)
	return assert(tonumber(require("util"):get_command_output(cmd, true)))
end

-- can check .git/HEAD, but this is not important for now
local curr_branch = require("util"):get_command_output(string.format("git -C %s branch --show-current", git_dir), true)
	or ""
local f = string.format("%s/.git/refs/heads/%s", git_dir, curr_branch) -- this file will be watched for changes
-- assert(vim.loop.fs_stat(f))
-- print(f)
local branch_head_file_contents = io.open(f)
if branch_head_file_contents then
	M.head_sha = branch_head_file_contents:read()
	branch_head_file_contents:close()
end

-- print(
-- 	M.head_sha, --
-- 	commits_ahead("origin/master", M.head_sha),
-- 	"x"
-- )

if M.head_sha then
	M.cache = {
		["origin/master" .. M.head_sha] = commits_ahead("origin/master", M.head_sha),
		-- ["origin/" .. M.curr_branch .. M.head_sha] = commits_ahead("origin/master", M.head_sha),
	}
end

print()

-- print(vim.inspect(M.cache))
-- os.execute("notify-send sarskjdfl")

-- https://github.com/nvim-lualine/lualine.nvim/blob/15884cee63a8/lua/lualine/components/branch/git_branch.lua
-- under the hood, every lualine func is always executed ~10 times per second
-- (even git_branch). the key is to cache known states and reduce file reads /
-- shell spawns as far as possible

function M:foo()
	-- 1. i never switch branches within vim
	-- 2. i always edit files in the current branch (if a branch exists at all)
	--
	-- i am not interested in watching branch changes. i am, however, interested
	-- in knowing how many commits i am ahead of remote

	-- M.watcher = assert(vim.loop.new_fs_event())
	-- M.watcher.stop()
	-- M.watcher:start(
	-- 	f,
	-- 	{},
	-- 	vim.schedule_wrap(function()
	-- 		-- reset file-watch
	-- 		os.execute("notify-send 'file changed'")
	-- 		M:foo()
	-- 	end)
	-- )

	if not git_dir then
		-- os.execute("notify-send nogit")
		return nil
	end

	-- os.execute("notify-send hi")
	-- print("in func", vim.inspect(M.cache))

	local k = "origin/master" .. M.head_sha
	local v = M.cache[k]

	if curr_branch == "master" and v > 0 then
		return string.format("%s [+%s]", curr_branch, v)
	elseif v > 0 then
		return string.format("%s [m+%s]", curr_branch, v)
	else
		-- TODO: handle origin/branch
		return curr_branch
	end

	-- return current_git_branch

	-- if ahead_m == "0" then
	-- 	return branch
	-- elseif ahead_b == "0" then
	-- 	return branch .. string.format("[m+%s]", ahead_m)
	-- else
	-- 	return branch .. string.format("[m+%s|b+%s]", ahead_m, ahead_b)
	-- end
end

return M
