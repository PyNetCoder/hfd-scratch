local M = {}

local state = {
  buf = nil,
  win = nil,
  ft = nil,
}

M.config = {
  layout = "float", -- "float" or "horizontal"
  height = 15,
  default_ft = "lua",
  keymap = "<leader>n", -- Normal mode toggle keymap (set to false when using lazy.nvim `keys`)
}

local function close_window()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
  end
end

local function open_float_window(buf, ft)
  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor(ui.width * 0.75)
  local height = math.floor(ui.height * 0.7)

  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((ui.height - height) / 2),
    col = math.floor((ui.width - width) / 2),
    style = "minimal",
    border = "rounded",
    title = (" hfd-scratch [%s] "):format(ft),
    title_pos = "center",
  })
end

local function open_horizontal_window(buf)
  vim.cmd("botright " .. M.config.height .. "split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

function M.open(ft)
  ft = (ft and ft ~= "") and ft or (state.ft or M.config.default_ft)

  if state.win and vim.api.nvim_win_is_valid(state.win) and state.ft == ft then
    close_window()
    return
  end

  close_window()

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].bufhidden = "hide"
    vim.bo[state.buf].swapfile = false

    local temp_name = vim.fn.tempname() .. "." .. ft
    pcall(vim.api.nvim_buf_set_name, state.buf, temp_name)
  end

  state.ft = ft
  vim.bo[state.buf].filetype = ft

  if M.config.layout == "horizontal" then
    state.win = open_horizontal_window(state.buf)
  else
    state.win = open_float_window(state.buf, ft)
  end

  -- Note: 'q' is normally macro recording; remove this mapping if you prefer closing only via toggle keymap
  vim.keymap.set("n", "q", close_window, {
    buffer = state.buf,
    silent = true,
    desc = "Close hfd-scratch window",
  })
end

function M.save(target_path)
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    vim.notify("No active scratch buffer to save.", vim.log.levels.WARN)
    return
  end

  local function write_file(path)
    if not path or vim.trim(path) == "" then
      vim.notify("No valid file path provided.", vim.log.levels.WARN)
      return
    end
    local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
    local full_path = vim.fn.expand(vim.trim(path))
    vim.fn.writefile(lines, full_path)
    vim.notify(("Scratch content saved: %s"):format(full_path), vim.log.levels.INFO)
  end

  if target_path and target_path ~= "" then
    write_file(target_path)
  else
    vim.ui.input({ prompt = "Save file path: " }, write_file)
  end
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("HfdScratch", function(args)
    M.open(args.args)
  end, {
    nargs = "?",
    complete = function()
      return { "lua", "python", "rust", "go", "markdown", "text" }
    end,
    desc = "Toggle temporary scratch buffer with optional filetype",
  })

  vim.api.nvim_create_user_command("HfdScratchSave", function(args)
    M.save(args.args)
  end, {
    nargs = "?",
    complete = "file",
    desc = "Save scratch buffer content to a file",
  })

  if M.config.keymap and M.config.keymap ~= "" then
    vim.keymap.set("n", M.config.keymap, function()
      M.open()
    end, { desc = "hfd-scratch: Toggle" })
  end
end

return M