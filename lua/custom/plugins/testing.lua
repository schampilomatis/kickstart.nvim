return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
  },
  config = function()
    require('neotest').setup {

      adapters = { require 'neotest-python' { runner = 'pytest' } },
    }

    vim.api.nvim_set_keymap('n', '<leader>tt', "<cmd>lua require('neotest').run.run()<CR>", { noremap = true, silent = true, desc = 'run current test' })
    vim.api.nvim_set_keymap(
      'n',
      '<leader>tf',
      "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
      { noremap = true, silent = true, desc = 'run current file' }
    )
    vim.api.nvim_set_keymap('n', '<leader>tc', "<cmd>lua require('neotest').run.stop()<CR>", { noremap = true, silent = true, desc = 'cancel test' })
    vim.api.nvim_set_keymap('n', '<leader>ts', "<cmd>lua require('neotest').summary.toggle()<CR>", { noremap = true, silent = true, desc = 'show summary' })
    vim.api.nvim_set_keymap(
      'n',
      '<leader>to',
      "<cmd>lua require('neotest').output.open({ enter = true })<CR>",
      { noremap = true, silent = true, desc = 'show output' }
    )
  end,
}
