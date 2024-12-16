vim.filetype.add({
	pattern = {
		-- https://github.com/emilioziniades/dotfiles/blob/db7b414c150d3a3ab863a0109786f7f48465dd23/nvim/init.lua#L708
		[".*/templates/.*.html"] = function(_, bufnr)
			local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			for _, line in ipairs(content) do
				if line:match("{%%") or line:match("%%}") then
					return "htmldjango"
				end
			end
		end,
		["Dockerfile.*"] = "dockerfile",
		[".+%.flux"] = "flux",
		["docker%-compose.*.yml"] = "yaml.docker-compose", -- '-' has special meaning (smh)
	},

	-- https://github.com/kennethnym/dotfiles/blob/41f03b9091181dc62ce872288685b27f001286f3/nvim/init.lua#L474
	filename = {

		["Dockerfile"] = "dockerfile",
		["docker-compose.yml"] = "yaml.docker-compose",
		["yarn.lock"] = "text", -- default is yaml for some reason
	},
})
