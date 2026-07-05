return {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('go').setup {
      -- go.nvim's codelens calls vim.lsp.codelens.enable(), which only exists on
      -- Neovim nightly (nil on 0.11.x) and errors on save once gopls attaches.
      lsp_codelens = false,
    }
  end,
  event = { 'CmdlineEnter' },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()',
}