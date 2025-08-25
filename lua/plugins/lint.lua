return {
  'mfussenegger/nvim-lint',
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      python = { 'pylint' },
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

    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
