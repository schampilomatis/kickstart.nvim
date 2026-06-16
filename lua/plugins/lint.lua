return {
  'mfussenegger/nvim-lint',
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      python = { 'pylint' },
      glsl = { 'glslc' },
    }
    lint.linters.pylint.cmd = 'python'
    lint.linters.pylint.args = {
      '-m',
      'pylint',
      '-f',
      'json',
      '--from-stdin',
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    require('lint').linters.glslc = {
      name = 'glslc',
      cmd = 'glslc',
      args = { '-o', '-' },
      stdin = false,
      stream = 'stderr',
      append_fname = true,
      ignore_exitcode = true,
      parser = require('lint.parser').from_pattern(
        '(%a:[^:]+):(%d+): (%a+): (.+)',
        { 'file', 'lnum', 'severity', 'message' },
        { ['error'] = vim.diagnostic.severity.ERROR, ['warning'] = vim.diagnostic.severity.WARN }
      ),
    }

    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
