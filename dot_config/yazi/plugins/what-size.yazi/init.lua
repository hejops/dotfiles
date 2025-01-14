-- note: in its original form, the plugin reports total size of the selected
-- items, or cwd. this is never my use case; instead, i only want to see the
-- size of the currently hovered dir.

-- Function to get total size from du output
local get_total_size = function(s)
	local lines = {}
	for line in s:gmatch("[^\n]+") do
		lines[#lines + 1] = line
	end
	local last_line = lines[#lines]
	local last_line_parts = {}
	for part in last_line:gmatch("%S+") do
		last_line_parts[#last_line_parts + 1] = part
	end
	local total_size = last_line_parts[1]
	return total_size
end

-- Function to format file size
local function format_size(size)
	local units = { "B", "KB", "MB", "GB", "TB" }
	local unit_index = 1

	while size > 1024 and unit_index < #units do
		size = size / 1024
		unit_index = unit_index + 1
	end

	return string.format("%.2f %s", size, units[unit_index])
end

-- the arg of ya.sync must be a func that returns a table, apparently
-- get_paths must be declared outside entry
-- https://github.com/sxyazi/yazi/blob/7222e178a3e0514a3f092074a63bc9c023f3009a/yazi-plugin/src/utils/sync.rs#L22
local get_paths = ya.sync(function()
	return { tostring(cx.active.current.hovered.url) }
end)

return {
	entry = function()
		local output, err = Command("du"):args({ "-scb", get_paths()[1] }):output()

		if not output then
			ya.err("Failed to run diff, error: " .. err)
		else
			local total_size = get_total_size(output.stdout)
			local formatted_size = format_size(tonumber(total_size))
			local notification_content = "Total size: " .. formatted_size

			ya.notify({
				title = "What size",
				content = notification_content,
				timeout = 5,
			})
		end
	end,
}
