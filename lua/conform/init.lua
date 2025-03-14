local M = {}

---@class (exact) conform.FormatterInfo
---@field name string
---@field command string
---@field cwd? string
---@field available boolean
---@field available_msg? string

---@class (exact) conform.FormatterConfig
---@field command string|fun(ctx: conform.Context): string
---@field args? string[]|fun(ctx: conform.Context): string[]
---@field range_args? fun(ctx: conform.RangeContext): string[]
---@field cwd? fun(ctx: conform.Context): nil|string
---@field require_cwd? boolean When cwd is not found, don't run the formatter (default false)
---@field stdin? boolean Send buffer contents to stdin (default true)
---@field condition? fun(ctx: conform.Context): boolean
---@field exit_codes? integer[] Exit codes that indicate success (default {0})
---@field env? table<string, any>|fun(ctx: conform.Context): table<string, any>

---@class (exact) conform.FileFormatterConfig : conform.FormatterConfig
---@field meta conform.FormatterMeta

---@class (exact) conform.FormatterMeta
---@field url string
---@field description string

---@class (exact) conform.Context
---@field buf integer
---@field filename string
---@field dirname string
---@field range? conform.Range

---@class (exact) conform.RangeContext : conform.Context
---@field range conform.Range

---@class (exact) conform.Range
---@field start integer[]
---@field end integer[]

---@alias conform.FormatterUnit string|string[]

---@type table<string, conform.FormatterUnit[]>
M.formatters_by_ft = {}

---@type table<string, conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig>
M.formatters = {}

M.notify_on_error = true

M.setup = function(opts)
  opts = opts or {}

  M.formatters = vim.tbl_extend("force", M.formatters, opts.formatters or {})
  M.formatters_by_ft = vim.tbl_extend("force", M.formatters_by_ft, opts.formatters_by_ft or {})

  if opts.log_level then
    require("conform.log").level = opts.log_level
  end
  if opts.notify_on_error ~= nil then
    M.notify_on_error = opts.notify_on_error
  end

  for ft, formatters in pairs(M.formatters_by_ft) do
    ---@diagnostic disable-next-line: undefined-field
    if formatters.format_on_save ~= nil then
      vim.notify(
        string.format(
          'The "format_on_save" option for filetype "%s" is deprecated. It is recommended to put this logic in the autocmd, see :help conform-autoformat',
          ft
        ),
        vim.log.levels.WARN
      )
      break
    end
  end

  local aug = vim.api.nvim_create_augroup("Conform", { clear = true })
  if opts.format_on_save then
    if type(opts.format_on_save) == "boolean" then
      opts.format_on_save = {}
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      group = aug,
      callback = function(args)
        local format_args = opts.format_on_save
        if type(format_args) == "function" then
          format_args = format_args(args.buf)
        end
        if format_args then
          M.format(vim.tbl_deep_extend("force", format_args, {
            buf = args.buf,
            async = false,
          }))
        end
      end,
    })
  end

  if opts.format_after_save then
    if type(opts.format_after_save) == "boolean" then
      opts.format_after_save = {}
    end
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      group = aug,
      callback = function(args)
        if vim.b[args.buf].conform_applying_formatting then
          return
        end
        local format_args = opts.format_after_save
        if type(format_args) == "function" then
          format_args = format_args(args.buf)
        end
        if format_args then
          M.format(
            vim.tbl_deep_extend("force", format_args, {
              buf = args.buf,
              async = true,
            }),
            function(err)
              if not err and vim.api.nvim_buf_is_valid(args.buf) then
                vim.api.nvim_buf_call(args.buf, function()
                  vim.b[args.buf].conform_applying_formatting = true
                  vim.cmd.update()
                  vim.b[args.buf].conform_applying_formatting = false
                end)
              end
            end
          )
        end
      end,
    })
  end

  vim.api.nvim_create_user_command("ConformInfo", function()
    require("conform.health").show_window()
  end, { desc = "Show information about Conform formatters" })
end

---@private
---@param bufnr? integer
---@return conform.FormatterUnit[]
M.list_formatters_for_buffer = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = {}
  local seen = {}
  local filetypes = vim.split(vim.bo[bufnr].filetype, ".", { plain = true })

  local function dedupe_formatters(names, collect)
    for _, name in ipairs(names) do
      if type(name) == "table" then
        local alternation = {}
        dedupe_formatters(name, alternation)
        if not vim.tbl_isempty(alternation) then
          table.insert(collect, alternation)
        end
      elseif not seen[name] then
        table.insert(collect, name)
        seen[name] = true
      end
    end
  end

  table.insert(filetypes, "*")
  for _, filetype in ipairs(filetypes) do
    ---@type conform.FormatterUnit[]
    local ft_formatters = M.formatters_by_ft[filetype]
    if ft_formatters then
      -- support the old structure where formatters could be a subkey
      if not vim.tbl_islist(ft_formatters) then
        ---@diagnostic disable-next-line: undefined-field
        ft_formatters = ft_formatters.formatters
      end

      dedupe_formatters(ft_formatters, formatters)
    end
  end

  return formatters
end

---@param bufnr integer
---@param mode "v"|"V"
---@return table {start={row,col}, end={row,col}} using (1, 0) indexing
local function range_from_selection(bufnr, mode)
  -- [bufnum, lnum, col, off]; both row and column 1-indexed
  local start = vim.fn.getpos("v")
  local end_ = vim.fn.getpos(".")
  local start_row = start[2]
  local start_col = start[3]
  local end_row = end_[2]
  local end_col = end_[3]

  -- A user can start visual selection at the end and move backwards
  -- Normalize the range to start < end
  if start_row == end_row and end_col < start_col then
    end_col, start_col = start_col, end_col
  elseif end_row < start_row then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end
  if mode == "V" then
    start_col = 1
    local lines = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, true)
    end_col = #lines[1]
  end
  return {
    ["start"] = { start_row, start_col - 1 },
    ["end"] = { end_row, end_col - 1 },
  }
end

---@param names conform.FormatterUnit[]
---@param bufnr integer
---@param warn_on_missing boolean
---@return conform.FormatterInfo[]
local function resolve_formatters(names, bufnr, warn_on_missing)
  local all_info = {}
  local function add_info(info, warn)
    if info.available then
      table.insert(all_info, info)
    elseif warn then
      vim.notify(
        string.format("Formatter '%s' unavailable: %s", info.name, info.available_msg),
        vim.log.levels.WARN
      )
    end
    return info.available
  end

  for _, name in ipairs(names) do
    if type(name) == "string" then
      local info = M.get_formatter_info(name, bufnr)
      add_info(info, warn_on_missing)
    else
      -- If this is an alternation, take the first one that's available
      for i, v in ipairs(name) do
        local info = M.get_formatter_info(v, bufnr)
        if add_info(info, i == #name) then
          break
        end
      end
    end
  end
  return all_info
end

---Format a buffer
---@param opts? table
---    timeout_ms nil|integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---    bufnr nil|integer Format this buffer (default 0)
---    async nil|boolean If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.
---    formatters nil|string[] List of formatters to run. Defaults to all formatters for the buffer filetype.
---    lsp_fallback nil|boolean|"always" Attempt LSP formatting if no formatters are available. Defaults to false. If "always", will attempt LSP formatting even if formatters are available (useful if you set formatters for the "*" filetype)
---    quiet nil|boolean Don't show any notifications for warnings or failures. Defaults to false.
---    range nil|table Range to format. Table must contain `start` and `end` keys with {row, col} tuples using (1,0) indexing. Defaults to current selection in visual mode
---    id nil|integer Passed to |vim.lsp.buf.format| when lsp_fallback = true
---    name nil|string Passed to |vim.lsp.buf.format| when lsp_fallback = true
---    filter nil|fun(client: table): boolean Passed to |vim.lsp.buf.format| when lsp_fallback = true
---@param callback? fun(err: nil|string) Called once formatting has completed
---@return boolean True if any formatters were attempted
M.format = function(opts, callback)
  ---@type {timeout_ms: integer, bufnr: integer, async: boolean, lsp_fallback: boolean|"always", quiet: boolean, formatters?: string[], range?: conform.Range}
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    lsp_fallback = false,
    quiet = false,
  })
  callback = callback or function(_err) end
  local log = require("conform.log")
  local lsp_format = require("conform.lsp_format")
  local runner = require("conform.runner")

  local formatter_names = opts.formatters or M.list_formatters_for_buffer(opts.bufnr)
  local any_formatters_configured = formatter_names ~= nil and not vim.tbl_isempty(formatter_names)
  local formatters =
    resolve_formatters(formatter_names, opts.bufnr, not opts.quiet and opts.formatters ~= nil)

  local resolved_names = vim.tbl_map(function(f)
    return f.name
  end, formatters)
  log.debug("Running formatters on %s: %s", vim.api.nvim_buf_get_name(opts.bufnr), resolved_names)

  local any_formatters = not vim.tbl_isempty(formatters)
  if any_formatters then
    local mode = vim.api.nvim_get_mode().mode
    if not opts.range and mode == "v" or mode == "V" then
      opts.range = range_from_selection(opts.bufnr, mode)
    end

    ---@param err? conform.Error
    local function handle_err(err)
      if err then
        local level = runner.level_for_code(err.code)
        log.log(level, err.message)
        local should_notify = not opts.quiet and level >= vim.log.levels.WARN
        -- Execution errors have special handling. Maybe should reconsider this.
        local notify_msg = err.message
        if runner.is_execution_error(err.code) then
          should_notify = should_notify and M.notify_on_error and not err.debounce_message
          notify_msg = "Formatter failed. See :ConformInfo for details"
        end
        if should_notify then
          vim.notify(notify_msg, level)
        end
      end
      local err_message = err and err.message
      if not err_message and not vim.api.nvim_buf_is_valid(opts.bufnr) then
        err_message = "buffer was deleted"
      end
      if err_message then
        return callback(err_message)
      end

      if
        opts.lsp_fallback == "always" and not vim.tbl_isempty(lsp_format.get_format_clients(opts))
      then
        log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
        lsp_format.format(opts, callback)
      else
        callback()
      end
    end

    if opts.async then
      runner.format_async(opts.bufnr, formatters, opts.range, handle_err)
    else
      local err = runner.format_sync(opts.bufnr, formatters, opts.timeout_ms, opts.range)
      handle_err(err)
    end
  elseif opts.lsp_fallback and not vim.tbl_isempty(lsp_format.get_format_clients(opts)) then
    log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
    lsp_format.format(opts, callback)
  elseif any_formatters_configured and not opts.quiet then
    vim.notify("No formatters found for buffer. See :ConformInfo", vim.log.levels.WARN)
    callback("No formatters found for buffer")
  else
    log.debug("No formatters found for %s", vim.api.nvim_buf_get_name(opts.bufnr))
    callback("No formatters found for buffer")
  end

  return any_formatters
end

---Retrieve the available formatters for a buffer
---@param bufnr? integer
---@return conform.FormatterInfo[]
M.list_formatters = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = M.list_formatters_for_buffer(bufnr)
  return resolve_formatters(formatters, bufnr, false)
end

---List information about all filetype-configured formatters
---@return conform.FormatterInfo[]
M.list_all_formatters = function()
  local formatters = {}
  for _, ft_formatters in pairs(M.formatters_by_ft) do
    -- support the old structure where formatters could be a subkey
    if not vim.tbl_islist(ft_formatters) then
      ---@diagnostic disable-next-line: undefined-field
      ft_formatters = ft_formatters.formatters
    end

    for _, formatter in ipairs(ft_formatters) do
      if type(formatter) == "table" then
        for _, v in ipairs(formatter) do
          formatters[v] = true
        end
      else
        formatters[formatter] = true
      end
    end
  end

  ---@type conform.FormatterInfo[]
  local all_info = {}
  for formatter in pairs(formatters) do
    local info = M.get_formatter_info(formatter)
    table.insert(all_info, info)
  end

  table.sort(all_info, function(a, b)
    return a.name < b.name
  end)
  return all_info
end

---@private
---@param formatter string
---@param bufnr? integer
---@return nil|conform.FormatterConfig
M.get_formatter_config = function(formatter, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  ---@type nil|conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig
  local config = M.formatters[formatter]
  if type(config) == "function" then
    config = config(bufnr)
  end
  if not config then
    local ok
    ok, config = pcall(require, "conform.formatters." .. formatter)
    if not ok then
      return nil
    end
  end

  if config.stdin == nil then
    config.stdin = true
  end
  return config
end

---Get information about a formatter (including availability)
---@param formatter string The name of the formatter
---@param bufnr? integer
---@return conform.FormatterInfo
M.get_formatter_info = function(formatter, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local config = M.get_formatter_config(formatter, bufnr)
  if not config then
    return {
      name = formatter,
      command = formatter,
      available = false,
      available_msg = "No config found",
    }
  end

  local ctx = require("conform.runner").build_context(bufnr, config)

  local command = config.command
  if type(command) == "function" then
    command = command(ctx)
  end

  local available = true
  local available_msg = nil
  if vim.fn.executable(command) == 0 then
    available = false
    available_msg = "Command not found"
  elseif config.condition and not config.condition(ctx) then
    available = false
    available_msg = "Condition failed"
  end
  local cwd = nil
  if config.cwd then
    cwd = config.cwd(ctx)
    if available and not cwd and config.require_cwd then
      available = false
      available_msg = "Root directory not found"
    end
  end

  ---@type conform.FormatterInfo
  return {
    name = formatter,
    command = command,
    cwd = cwd,
    available = available,
    available_msg = available_msg,
  }
end

return M
