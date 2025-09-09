return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 1000,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      javascript = { 'prettier', 'prettierd' },
      javascriptreact = { 'prettier', 'prettierd' },
      typescript = { 'prettier', 'prettierd' },
      typescriptreact = { 'prettier', 'prettierd' },
      json = { 'jq' },
      jsonc = { 'jq' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
    },
    formatters = {
      isort = {
        prepend_args = function()
          return { '--src', os.getenv 'ISORT_SRC_FOLDER' or '.' }
        end,
      },
    },
  },
}
