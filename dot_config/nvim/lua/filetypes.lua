-- https://github.com/ahmedelgabri/dotfiles/blob/main/config/nvim/filetype.lua

vim.filetype.add({
	pattern = {

		-- [".+%.flux"] = "flux",
		["%.d2$"] = "d2",
		["%.github/.*%.ya?ml"] = "yaml.github",
		["%.h$"] = "c",
		["Dockerfile.*"] = "dockerfile",
		["docker%-compose.*%.yml"] = "yaml.docker-compose",
		["templates/.*%.html"] = require("util"):buf_contains("{%%") and "htmldjango" or "html", -- https://github.com/emilioziniades/dotfiles/blob/db7b414c/nvim/init.lua#L714
	},

	-- https://github.com/kennethnym/dotfiles/blob/41f03b9091181dc62ce872288685b27f001286f3/nvim/init.lua#L474
	filename = {

		-- ["docker-compose.yml"] = "yaml.docker-compose", -- TODO:
		-- ["mongo.js"] = "javascript.mongo",
		[".env"] = "dotenv",
		["Dockerfile"] = "dockerfile",
		["yarn.lock"] = "text", -- default is yaml for some reason
	},
})
