return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  lazy = false,
  config = function()
    -- Compatibility shim: `main` branch removed `parsers.ft_to_lang`,
    -- but some plugins (treesitter-context, go.nvim, etc.) still call it.
    local parsers = require 'nvim-treesitter.parsers'
    if not parsers.ft_to_lang then
      parsers.ft_to_lang = function(ft)
        return vim.treesitter.language.get_lang(ft) or ft
      end
    end

    require('nvim-treesitter').install {
      'bash',
      'c',
      'diff',
      'dockerfile',
      'go',
      'gomod',
      'gosum',
      'hcl',
      'html',
      'javascript',
      'json',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'terraform',
      'toml',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    }

    -- The `main` branch doesn't auto-enable features. Start highlighting/indent
    -- for any buffer whose filetype has an installed parser.
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if lang and pcall(vim.treesitter.start, args.buf, lang) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
