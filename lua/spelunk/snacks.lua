local status_ok, _ = pcall(require, "snacks")
if not status_ok then
	return false, "snacks.nvim"
end

local M = {}

---@param prompt string
---@param data FullBookmark[]
---@param cb fun(file: string, line: integer, col: integer, split: "vertical" | "horizontal" |nil)
M.search_marks = function(prompt, data, cb)
	local opts = {}

	local i = 0
	local items = vim.tbl_map(function(item)
		i = i + 1

		return {
			idx = i,
			text = item.file,
			pos = { item.line, item.col },
			stack = item.stack,
			file = item.file,
			line = item.line,
			col = item.col,
		}
	end, data)

	Snacks.picker.pick({
		format = function(item, picker)
			local display = require("spelunk").display_function(item)
			return {
				{ item.stack, "Comment" },
				{ ": ", "Comment" },
				{ display, "Keyword" },
			}
		end,
		layout = {
			preview = "main",
		},
		format = "text",
		items = items,
		-- confirm = function(picker, item)
		-- 	picker:close()
		-- 	cb(item.file, item.line, item.col)
		-- end,
	})
end

---@param prompt string
---@param data string[]
---@param cb fun(data: string)
M.search_stacks = function(prompt, data, cb)
	local opts = {}
	local api = require("spelunk")

	local marks = api.all_full_marks()

	local i = 0
	local items = vim.tbl_map(function(item)
		local allMarks = vim.tbl_map(
			function(item)
				return require("spelunk").display_function(item)
				-- return ("%s:%s:%s"):format(item.file, item.line, item.col)
			end,
			vim.tbl_filter(function(mark)
				return mark.stack == item
			end, marks)
		)

		i = i + 1
		return {
			idx = i,
			text = item,
			preview = {
				text = table.concat(allMarks, "\n"),
			},
		}
	end, data)

	Snacks.picker.pick({
		format = function(item, picker)
			return {
				{ item.text, "Keyword" },
			}
		end,
		format = "text",
		items = items,
		preview = "preview",
		confirm = function(picker, item)
			picker:close()
			cb(item.text)
		end,
	})
end

return M
