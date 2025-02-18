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

    vim.api.nvim_set_keymap('n', '<leader>tt', "<cmd>lua require('neotest').run.run()<CR>", { noremap = true, silent = true, desc = 'Run current [T]est' })
    vim.api.nvim_set_keymap(
      'n',
      '<leader>td',
      "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<CR>",
      { noremap = true, silent = true, desc = '[D]ebug current test' }
    )
    vim.api.nvim_set_keymap(
      'n',
      '<leader>tf',
      "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
      { noremap = true, silent = true, desc = 'Run current [F]ile' }
    )
    vim.api.nvim_set_keymap('n', '<leader>tc', "<cmd>lua require('neotest').run.stop()<CR>", { noremap = true, silent = true, desc = '[C]ancel test' })
    vim.api.nvim_set_keymap('n', '<leader>ts', "<cmd>lua require('neotest').summary.toggle()<CR>", { noremap = true, silent = true, desc = '[S]how summary' })
    vim.api.nvim_set_keymap(
      'n',
      '<leader>to',
      "<cmd>lua require('neotest').output.open({ enter = true })<CR>",
      { noremap = true, silent = true, desc = 'Show [O]utput' }
    )
  end,
}
