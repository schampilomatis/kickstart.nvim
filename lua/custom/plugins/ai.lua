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
}
