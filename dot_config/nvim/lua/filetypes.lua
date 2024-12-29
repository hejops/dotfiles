vim.filetype.add({
	pattern = {
		[".*/templates/.*.html"] = require("util"):buf_contains("{%%") and "htmldjango" or "html", -- https://github.com/emilioziniades/dotfiles/blob/db7b414c/nvim/init.lua#L714
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
