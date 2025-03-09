local utils = require 'utils'
local ui = require('ui')

---@class Instance
---@field logs log[]
---@field window integer | nil
---@field conf config
local Core = {
	logs = {},
	window = nil,
	buffer = nil,
}

Core.__index = Core

---create new Core instance
---@param config config
function Core:new(config)
	local ins = setmetatable({}, self)
	ins.conf = config
	return ins
end

---add new log
---@param msg string
---@param level integer
function Core:add(msg, level)
	local level_label = utils.find_key_by_value(vim.log.levels, level) or "OFF"
	if level_label == "OFF" then return end

	-- Ensure logs don't exceed the limit
	if #self.logs >= self.conf.max_logs then table.remove(self.logs, 1) end

	local log = { level = level_label, message = msg, time = os.date("%Y-%m-%d %H:%M:%S") }

	table.insert(self.logs, log)

	self:push_notification(log)
	self:update_buf()
end

---clear all logs
function Core:clear()
	self.logs = {}
	self:update_buf()
end

--- open notification center
function Core:open_center()
	self:update_buf()
	self.window = self.window or ui.open_center(self.conf.center, self.buffer)
end

--- close notification center
function Core:close_center()
	ui.close_buffer_and_window(self.buffer, self.window)
	self.buffer = nil
	self.window = nil
end

---push new notification to UI
---@param log log
function Core:push_notification(log)
	local log_string = utils.format_log(log)
	ui.push_noti(self.conf.quick, log_string)
end

function Core:update_buf()
	self.buffer = self.buffer or ui.create_buffer()

	vim.api.nvim_set_option_value("modifiable", true, { buf = self.buffer })
	vim.api.nvim_buf_set_lines(self.buffer, 1, -1, false, utils.parse_log(self.logs))
	vim.api.nvim_set_option_value("modifiable", false, { buf = self.buffer })
end

return Core
