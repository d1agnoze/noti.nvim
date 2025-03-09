local Core = require "core"

---@class log
---@field message string
---@field level string
---@field time string

---@type config
local default_opts = {
	quick = {
		width = 0.30,
		height = 0.1,
		position = "bottom-right",
		wait = 5000,
	},
	center = {
		width = 0.30,
		height = 0.5,
		position = "bottom-right",
		wait = 0,
	},
	filter = { "INFO", "WARN", "ERROR" },
	keep_original = false,
	max_logs = 30,
}

---@param opts config
local function main(opts)
	local core = Core:new(opts)

	---@diagnostic disable-next-line: duplicate-set-field
	vim.notify = function(msg, level, _)
		if level == nil then return end
		core:add(msg, level)
	end

	--#region Command
	vim.api.nvim_create_user_command("NotiToggle", function()
		if core.window then
			core:close_center()
		else
			core:open_center()
		end
	end, {})

	vim.api.nvim_create_user_command("NotiView", function()
		core:open_center()
	end, {})

	vim.api.nvim_create_user_command("NotiClose", function()
		core:close_center()
	end, {})

	vim.api.nvim_create_user_command("NotiClear", function()
		core:clear()
	end, {})
	--#endregion
end

---@param opts config
local function setup(opts)
	if opts == nil or next(opts) == nil then
		opts = default_opts
	end
	main(opts)
end

return { setup = setup }
