return {
  'Julian/lean.nvim',
  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

  dependencies = {
    'nvim-lua/plenary.nvim',

    --    hrsh7th/nvim-cmp or Saghen/blink.cmp are popular choices

    -- 'nvim-telescope/telescope.nvim', -- for 2 Lean-specific pickers
    -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
    -- 'andrewradev/switch.vim',        -- for switch support
    -- 'tomtom/tcomment_vim',           -- for commenting
  },

  opts = {
    mappings = true,
  },
  config = function()
    require('lean').setup {
      -- Even if empty, this table prevents the 'config' (nil value) error
      lsp = {},
      mappings = true,
    }
  end,
}
