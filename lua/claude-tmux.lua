-- Drive a sibling tmux pane running Claude Code from inside Neovim.
--
-- Claude Code rewrites its own pane title ("✳ Claude Code"), so a title we set
-- with select-pane -T gets clobbered. The pane is marked with a pane-scoped
-- tmux user option instead, and title/command matching is kept as a fallback so
-- a pane started by hand is still found.

local M = {}

local PANE_OPT = '@claude_pane'

-- --continue picks up the most recent conversation in the pane's cwd, which is
-- Neovim's cwd, so each project folder reopens where it left off. In a folder
-- with no history it just starts a fresh session.
-- Overridable from init.lua: require('claude-tmux').cmd = 'claude'
M.cmd = 'claude --continue'
M.split_size = '40%'

local function in_tmux()
  if vim.env.TMUX == nil or vim.env.TMUX == '' then
    vim.notify('claude-tmux: not running inside tmux', vim.log.levels.WARN)
    return false
  end
  return true
end

---Run tmux and return trimmed stdout, or nil plus the error on failure.
local function tmux(args)
  local res = vim.system(vim.list_extend({ 'tmux' }, args), { text = true }):wait()
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr or '')
  end
  return vim.trim(res.stdout or '')
end

---Append `-t <our pane>` so window-scoped commands act on the window holding
---Neovim rather than whatever window the attached client happens to be viewing.
local function with_self_target(args)
  if vim.env.TMUX_PANE and vim.env.TMUX_PANE ~= '' then
    vim.list_extend(args, { '-t', vim.env.TMUX_PANE })
  end
  return args
end

---@return string|nil pane_id of the Claude pane in the current window
local function find_pane()
  local out = tmux(with_self_target { 'list-panes', '-F', '#{pane_id}\t#{' .. PANE_OPT .. '}\t#{pane_title}\t#{pane_current_command}' })
  if not out or out == '' then
    return nil
  end
  local fallback
  for _, line in ipairs(vim.split(out, '\n', { trimempty = true })) do
    local id, marked, title, cmd = unpack(vim.split(line, '\t', { plain = true }))
    if marked == '1' then
      return id
    end
    if id ~= vim.env.TMUX_PANE and (cmd == M.cmd:match '^%S+' or (title or ''):lower():find('claude', 1, true)) then
      fallback = fallback or id
    end
  end
  return fallback
end

local function create_pane()
  -- -d: create the pane without making it active, so focus stays in Neovim.
  local id, err = tmux(with_self_target { 'split-window', '-d', '-h', '-l', M.split_size, '-c', vim.fn.getcwd(), '-P', '-F', '#{pane_id}' })
  if not id then
    vim.notify('claude-tmux: split-window failed: ' .. (err or '?'), vim.log.levels.ERROR)
    return nil
  end
  tmux { 'set-option', '-p', '-t', id, PANE_OPT, '1' }
  tmux { 'select-pane', '-t', id, '-T', 'claude' }
  tmux { 'send-keys', '-t', id, M.cmd, 'Enter' }
  return id
end

---Locate the Claude pane, creating it if the current window has none. Focus is
---never moved: everything here drives the pane from Neovim.
---@param create boolean|nil create the pane when missing (default true)
---@return string|nil pane_id
function M.open(create)
  if not in_tmux() then
    return nil
  end
  local id = find_pane()
  if id then
    return id
  end
  if create == false then
    vim.notify('claude-tmux: no claude pane in this window', vim.log.levels.WARN)
    return nil
  end
  return create_pane()
end

---Paste text into the Claude pane without submitting it. Focus stays put.
---Bracketed paste keeps multi-line text as a single prompt entry.
---@param text string
function M.send(text)
  local id = M.open()
  if not id then
    return
  end
  local tmpfile = vim.fn.tempname()
  local ok = pcall(vim.fn.writefile, vim.split(text, '\n', { plain = true }), tmpfile, 'b')
  if not ok then
    vim.notify('claude-tmux: could not stage text for tmux', vim.log.levels.ERROR)
    return
  end
  local _, err = tmux { 'load-buffer', '-b', 'nvim_claude', tmpfile }
  vim.fn.delete(tmpfile)
  if err then
    vim.notify('claude-tmux: load-buffer failed: ' .. err, vim.log.levels.ERROR)
    return
  end
  tmux { 'paste-buffer', '-b', 'nvim_claude', '-t', id, '-d', '-p' }
end

---Path of the current buffer relative to cwd, as Claude's @ syntax expects.
---@return string|nil nil for an unnamed buffer
local function rel_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    return nil
  end
  return vim.fn.fnamemodify(name, ':.')
end

---Send the visual selection as a fenced block tagged with its location.
function M.send_selection()
  local mode = vim.fn.mode()
  local from, to = vim.fn.getpos 'v', vim.fn.getpos '.'
  local lines = vim.fn.getregion(from, to, { type = mode:sub(1, 1) })
  vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'nx', false)
  if vim.tbl_isempty(lines) then
    return
  end
  local first, last = math.min(from[2], to[2]), math.max(from[2], to[2])
  local header = ('%s:%d-%d'):format(rel_path() or '[scratch]', first, last)
  local fence = '```' .. (vim.bo.filetype ~= '' and vim.bo.filetype or '')
  M.send(table.concat({ header, fence, table.concat(lines, '\n'), '```', '' }, '\n'))
end

---Send an @-reference to the current file.
function M.send_file()
  local path = rel_path()
  if not path then
    vim.notify('claude-tmux: buffer has no file name', vim.log.levels.WARN)
    return
  end
  M.send('@' .. path .. ' ')
end

vim.keymap.set('n', '<leader>cc', function()
  M.open()
end, { desc = 'Open [C]laude pane' })
vim.keymap.set('x', '<leader>cv', M.send_selection, { desc = 'Send selection to [C]laude' })
vim.keymap.set('n', '<leader>cf', M.send_file, { desc = 'Send @[f]ile reference to Claude' })

return M
