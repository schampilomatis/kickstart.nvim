return {
  'olimorris/onedarkpro.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    highlights = {
      -- Theme links this to TelescopeSelection, whose bg falls back to
      -- palette.bg (#000000) unless options.cursorline is set.
      TelescopePreviewLine = { bg = '#2c323c' },
      TelescopeSelection = { bg = '#2c323c', extend = true },
    },
  },
  config = function(_, opts)
    require('onedarkpro').setup(opts)
    vim.cmd [[colorscheme onedark_dark]]
  end,
}
