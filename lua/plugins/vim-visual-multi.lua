return {
  'mg979/vim-visual-multi',
  init = function()
    vim.g.VM_default_mappings = 0
    vim.g.VM_maps = {
      ['Find Under'] = '',
    }
    vim.g.VM_add_cursor_at_pos_no_mappings = 1
    local wk = require 'which-key'
    wk.add {
      { '<leader>m', group = 'Visual Multi' },
      { '<leader>ma', '<Plug>(VM-Select-All)<Tab>', desc = 'Select All' },
      { '<leader>mo', '<Plug>(VM-Toggle-Mappings)', desc = 'Toggle Mapping' },
      { '<leader>mp', '<Plug>(VM-Add-Cursor-At-Pos)', desc = 'Add Cursor At Pos' },
      { '<leader>mr', '<Plug>(VM-Start-Regex-Search)', desc = 'Start Regex Search' },
      { '<leader>mv', '<Plug>(VM-Visual-Cursors)', desc = 'Visual Cursors', mode = 'v' },
    }
  end,
}