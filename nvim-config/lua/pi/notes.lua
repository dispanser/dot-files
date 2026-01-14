  local function path_exists(filepath)
      local f = io.open(filepath, "r")
      if f then
          io.close(f)
          return true
      end
      return false
  end

  local function is_directory(filepath)
      return vim.fn.isdirectory(vim.fn.expand(filepath)) == 1
  end


  local function get_note_prefix()
      -- Check if .tp directory exists, otherwise use daily
      if is_directory(".tp") then
          return ".tp"
      end
      return "daily"
  end

  local function ensure_prefix_exists(prefix)
      -- Create the prefix directory if it doesn't exist
      local expanded_prefix = vim.fn.expand(prefix)
      if not is_directory(expanded_prefix) then
          vim.fn.mkdir(expanded_prefix, "p")
      end
  end

local function get_date_from_filename(filename)
    -- Extract date from filename like "daily/2023-10-01.md"
    local date_str = filename:match("daily/([%d%-]+)%.md")
    if date_str then
        return date_str
    end
    return nil
end

local function parse_date(date_str)
    -- Parse YYYY-MM-DD format
    local year, month, day = date_str:match("(%d+)%-(%d+)%-(%d+)")
    if year and month and day then
        return tonumber(year), tonumber(month), tonumber(day)
    end
    return nil, nil, nil
end

local function date_to_timestamp(year, month, day)
    -- Convert date components to timestamp
    local date_table = { year = year, month = month, day = day }
    return os.time(date_table)
end

local function timestamp_to_date(timestamp)
    -- Convert timestamp back to YYYY-MM-DD format
    local date_table = os.date("*t", timestamp)
    return string.format("%04d-%02d-%02d", date_table.year, date_table.month, date_table.day)
end

  local function date_exists(date_str, prefix)
      -- Check if a daily note file for the given date exists
      local filepath = vim.fn.expand(prefix .. "/" .. date_str .. ".md")
      return path_exists(filepath)
  end

  local function get_next_existing_date(current_date_str, direction, prefix)
      -- Get next/previous existing date, skipping non-existent days
      local year, month, day = parse_date(current_date_str)
      if not year then return nil end

      local timestamp = date_to_timestamp(year, month, day)
      local max_iterations = 365 -- Prevent infinite loops
      local iterations = 0

      while iterations < max_iterations do
          iterations = iterations + 1

          local new_timestamp = timestamp + (direction * 24 * 60 * 60) -- Add/subtract one day
          local new_date_str = timestamp_to_date(new_timestamp)

          if date_exists(new_date_str, prefix) then
              return new_date_str
          end

          timestamp = new_timestamp
      end

      return nil -- No more existing dates found
  end

-- Function to create a file with template content
local function create_file_with_template(filepath, date)
    local template = [[
# Daily Notes for ]] .. date .. [[


## To-Do

- [ ] 

## Scratch

]]

    local f = io.open(filepath, "w")
    if f ~= nil then
        f:write(template)
        io.close(f)
    else
        error("Failed to open file: " .. filepath)
    end
end


  -- Function to open a file named with the current date
  local function open_file_for(offset)
      local prefix = get_note_prefix()
      ensure_prefix_exists(prefix)
      local date = os.date("%Y-%m-%d", os.time() + (offset * 24 * 60 * 60)) -- Calculate the offset date
      local filepath = vim.fn.expand(prefix .. "/" .. date .. ".md") -- Adjust path as needed
      if not path_exists(filepath) then
          create_file_with_template(filepath, date)
      end
      vim.cmd("edit " .. filepath) -- Open the file
  end


  local function open_next_existing_file(direction)
      -- Open next/previous existing daily note file
      local current_file = vim.api.nvim_buf_get_name(0)
      local current_date = get_date_from_filename(current_file)

      if not current_date then
          -- If not a daily note file, default to today
          open_file_for(0)
          return
      end

      local prefix = get_note_prefix()
      local next_date = get_next_existing_date(current_date, direction, prefix)
      if next_date then
          local filepath = vim.fn.expand(prefix .. "/" .. next_date .. ".md")
          vim.cmd("edit " .. filepath)
      else
          -- No more files found, maybe show a message or do nothing
          vim.notify("No more " .. (direction > 0 and "next" or "previous") .. " daily notes found", vim.log.levels.WARN)
      end
  end

-- Keybindings: jump around daily notes
vim.keymap.set('n', '<leader>oy', function() open_file_for(-1) end, { noremap = true, silent = true, desc = "is yesterday" })
vim.keymap.set('n', '<leader>ot', function() open_file_for(1) end, { noremap = true, silent = true, desc = "tomorrow" })
vim.keymap.set('n', '<leader>oo', function() open_file_for(0) end, { noremap = true, silent = true, desc = "today" })
vim.keymap.set('n', '<leader>on', function() open_next_existing_file(1) end, { noremap = true, silent = true, desc = "next existing note" })
vim.keymap.set('n', '<leader>op', function() open_next_existing_file(-1) end, { noremap = true, silent = true, desc = "previous existing note" })
