return {
  'tiagovla/tokyodark.nvim',
  opts = {
    terminal_colors = true,
  },
  config = function(_, opts)
    require('tokyodark').setup(opts)
    vim.cmd [[colorscheme tokyodark]]
  end,
}
