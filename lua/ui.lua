local utils = require("utils")
---@class position
---@field row number
---@field col number

---@class winopt
---@field width number
---@field height number
---@field wait number
---@field position string

---@class config
---@field quick winopt
---@field center winopt
---@field filter string[]
---@field keep_original boolean
---@field max_logs number

local color = {
	TRACE = "DiagnosticHint",
	DEBUG = "DiagnosticUnnecessary",
	INFO = "DiagnosticOk",
	WARN = "DiagnosticWarn",
	ERROR = "DiagnosticError",
}

---return log string with highlight detail, nil if level not found in string or in color table
---@param log string
---@param level string
local function get_level_color(log, level)
	local level_start = log:find(level)

	if level_start and color[level] then
		local out = {
			color = color[level],
			start_pos = level_start - 1,
			end_pos = level_start + #level - 1,
		}
		return out
	end

	return nil
end

local function close_push(win, buf)
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

---@return position
local function get_position(position, width, height)
	local cases = {
		["bottom-left"] = function()
			return { col = 2, row = vim.o.lines - height - 2 }
		end,

		["bottom-right"] = function()
			return { col = vim.o.columns - width - 2, row = vim.o.lines - height - 2 }
		end,

		["center"] = function()
			return {
				col = math.floor((vim.o.columns - width) / 2),
				row = math.floor((vim.o.lines - height) / 2),
			}
		end,

		["top-left"] = function()
			return { col = 2, row = 2 }
		end,

		["top-right"] = function()
			return { col = vim.o.columns - width - 2, row = 2 }
		end,
	}

	return cases[position] and cases[position]() or cases["bottom-right"]()
end

---@param opts winopt
---@return vim.api.keyset.win_config
local function get_win_config(opts)
	local width = math.floor(vim.o.columns * opts.width)
	local height = math.floor(vim.o.lines * opts.height)
	local position = get_position(opts.position, width, height)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = position.col,
		row = position.col,
		style = "minimal",
		border = "single",
	}
end

---@param opts winopt
---@param log log
local function create_push_notification(opts, log)
	local feed = {}
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, get_win_config(opts))

	local formattedLog = utils.format_log(log)

	if formattedLog == "" then
		return
	end

	table.insert(feed, formattedLog)
	-- Fill buffer with logs
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { formattedLog })

	local hl = get_level_color(formattedLog, log.level)
	if hl then
		vim.api.nvim_buf_add_highlight(buf, -1, hl.color, 0, hl.start_pos, hl.end_pos)
	end

	vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, #log.time)

	-- Set buf attribute
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	-- Auto close
	if opts.wait ~= 0 then
		vim.defer_fn(function()
			close_push(win, buf)
		end, opts.wait)
	end
end

local function create_buffer()
	return vim.api.nvim_create_buf(false, true)
end

local function close_buffer_and_window(buf, win)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

local function create_notification_window(opts, buf)
	local win = vim.api.nvim_open_win(buf, false, get_win_config(opts))
	local keyOpt = {
		noremap = true,
		callback = function()
			close_buffer_and_window(buf, win)
		end,
	}
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", keyOpt)

	return win
end

---@param buf integer | nil
---@param logs log[]
local function insert_log_to_buffer(buf, logs)
	logs = utils.array_reverse(logs)
	if buf == nil then
		return
	end
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	local formattedLogs = utils.parse_log(logs)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, formattedLogs)

	if #logs > 0 then
		-- add highlight
		for i, value in ipairs(logs) do
			local hl = get_level_color(formattedLogs[i], value.level)
			if hl then
				vim.api.nvim_buf_add_highlight(buf, -1, hl.color, i - 1, hl.start_pos, hl.end_pos)
			end
			vim.api.nvim_buf_add_highlight(buf, -1, "Comment", i - 1, 0, #value.time)
		end
	end

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

local M = {
	open_center = create_notification_window,
	push_noti = create_push_notification,
	create_buffer = create_buffer,
	write_logs = insert_log_to_buffer,
	close_buffer_and_window = close_buffer_and_window,
}

return M
