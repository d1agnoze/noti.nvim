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
---@param log string
local function create_push_notification(opts, log)
	local feed = {}
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, get_win_config(opts))

	table.insert(feed, log)

	-- Fill buffer with logs
	vim.api.nvim_buf_set_lines(buf, 1, -1, false, feed)

	-- Set buf attribute
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	-- Auto close
	if opts.wait ~= 0 then
		vim.defer_fn(function() close_push(win, buf) end, opts.wait)
	end
end

local function create_buffer()
	local buf = vim.api.nvim_create_buf(false, true)

	-- local keyOpt = { noremap = true, silent = true, callback = callback }
	-- vim.api.nvim_buf_set_keymap(buf, "n", "q", "", keyOpt)

	return buf
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
		end
	}
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", keyOpt)

	return win
end


local M = {
	open_center = create_notification_window,
	push_noti = create_push_notification,
	create_buffer = create_buffer,
	close_buffer_and_window = close_buffer_and_window,
}

return M
