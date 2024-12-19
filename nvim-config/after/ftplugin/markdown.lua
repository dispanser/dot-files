-- Function to check if a file exists
local function file_exists(filepath)
    local f = io.open(filepath, "r")
    if f then
        io.close(f)
        return true
    end
    return false
end

-- Function to create a file with template content
local function create_file_with_template(filepath, date)
    local template = [[
# Daily Notes for ]] .. date .. [[

## To-Do
- [ ] 

## Notes
- 

## Reflections
- 
]]
    local f = io.open(filepath, "w")
    f:write(template)
    io.close(f)
end

-- Function to open a file named with the current date
local function open_file_for_today(offset)
    local date = os.date("%Y-%m-%d", os.time() + (offset * 24 * 60 * 60)) -- Calculate the offset date
    local filepath = vim.fn.expand("~/.tp/notes/daily/" .. date .. ".md") -- Adjust path as needed
    if not file_exists(filepath) then
        create_file_with_template(filepath, date)
    end
    vim.cmd("edit " .. filepath) -- Open the file
end

-- Keybinding to trigger the function
vim.keymap.set('n', '<leader>oy', function() open_file_for_today(-1) end, { noremap = true, silent = true, desc = "is yesterday" })
vim.keymap.set('n', '<leader>ot', function() open_file_for_today(1) end, { noremap = true, silent = true, desc = "tomorrow" })
vim.keymap.set('n', '<leader>od', function() open_file_for_today(0) end, { noremap = true, silent = true, desc = "today" })
