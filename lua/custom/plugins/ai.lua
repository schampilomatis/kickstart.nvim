return {
  {
    'Exafunction/codeium.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    cond = vim.env.NVIM_USE_CODEIUM == '1',
    config = function()
      require('codeium').setup {
        enable_cmp_source = false,
        virtual_text = { enabled = true },
      }
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('codecompanion').setup {
        strategies = {
          chat = {
            adapter = 'anthropic',
          },
          inline = {
            keymaps = {
              accept_change = {
                modes = { n = '<leader>aa' },
                description = 'CodeCompanion: Accept the suggested change',
              },
              reject_change = {
                modes = { n = '<leader>ar' },
                description = 'CodeCompanion: Reject the suggested change',
              },
            },
          },
        },
      }

      local codecompanion = require 'codecompanion'
      vim.keymap.set('n', '<leader>at', codecompanion.toggle, { desc = 'CodeCompanion: toggle chat' })
      vim.keymap.set('n', '<leader>ac', codecompanion.chat, { desc = 'CodeCompanion: clear chat' })
    end,
  },
}
