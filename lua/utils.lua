local function find_key_by_value(tbl, value)
	for key, val in pairs(tbl) do
		if val == value then
			return key -- Return the first matching key
		end
	end
	return nil -- Return nil if not found
end

--- Parse logs
---@param entries log[]
---@returns string[]
local function parse_log(entries)
	local lines = {}

	for _, log in ipairs(entries) do
		table.insert(lines, string.format("%s %s %s", log.time, log.level, log.message))
	end

	if #lines == 0 then
		table.insert(lines, "No notifications")
	end

	return lines
end

--- Format log
---@param log log
---@returns string
local function format_log(log)
	return string.format("%s %s: %s", log.time, log.level, log.message)
end

local function array_reverse(x)
	local n, m = #x, #x / 2
	for i = 1, m do
		x[i], x[n - i + 1] = x[n - i + 1], x[i]
	end
	return x
end

return {
	array_reverse = array_reverse,
	find_key_by_value = find_key_by_value,
	parse_log = parse_log,
	format_log = format_log,
}
