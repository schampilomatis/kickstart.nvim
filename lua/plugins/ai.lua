return {
  {
    'Exafunction/windsurf.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    cond = vim.env.NVIM_USE_CODEIUM == '1',
    config = function()
      require('codeium').setup {
        enable_cmp_source = false,
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = '<S-Tab>',
          },
        },
      }

      -- On Windows the server returns completions with CRLF, and the stray
      -- \r survives as a literal ^M in unix-fileformat buffers (which breaks
      -- pyright even though the linter strips it). Every accept path inserts
      -- via get_completion_text(), so strip \r at that single chokepoint.
      local vt = require 'codeium.virtual_text'
      local get_completion_text = vt.get_completion_text
      vt.get_completion_text = function(...)
        local text = get_completion_text(...)
        return type(text) == 'string' and (text:gsub('\r', '')) or text
      end
    end,
  },
}
