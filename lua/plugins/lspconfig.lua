return {

  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = {} },
    { 'williamboman/mason-lspconfig.nvim', opts = { automatic_installation = true } },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    -- Keep lsp.log from ballooning (it hit 146MB): only log real problems.
    vim.lsp.log.set_level 'WARN'

    -- Fast recovery from a desynced/stuck LSP without restarting nvim.
    -- (nvim-lspconfig v2 dropped :LspRestart, so do it via the core API.)
    vim.keymap.set('n', '<leader>lr', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients { bufnr = bufnr }
      if vim.tbl_isempty(clients) then
        vim.notify('No LSP clients attached to this buffer', vim.log.levels.INFO)
        return
      end
      local names = vim.tbl_map(function(c)
        return c.name
      end, clients)
      for _, client in ipairs(clients) do
        vim.lsp.stop_client(client.id, true)
      end
      vim.notify('Restarting LSP: ' .. table.concat(names, ', '), vim.log.levels.INFO)
      -- Re-edit re-fires FileType, which re-runs vim.lsp.enable() autostart.
      vim.defer_fn(function()
        vim.cmd 'silent! edit'
      end, 250)
    end, { desc = 'LSP: [R]estart (buffer)' })

    do
      local orig_rename = vim.lsp.handlers['textDocument/rename']
      vim.lsp.handlers['textDocument/rename'] = function(err, result, ctx)
        if result then
          if result.documentChanges then
            for _, change in ipairs(result.documentChanges) do
              if change.edits then
                for _, edit in ipairs(change.edits) do
                  edit.annotationId = nil
                end
              end
            end
          end
          if result.changes then
            for _, edits in pairs(result.changes) do
              for _, edit in ipairs(edits) do
                edit.annotationId = nil
              end
            end
          end
        end
        return orig_rename(err, result, ctx)
      end
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    if vim.g.have_nerd_font then
      local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config { signs = { text = diagnostic_signs } }
    end

    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      terraformls = {},
      pyright = {
        -- Pin the root to where pyrightconfig.json + .venv live, so pyright
        -- never falls back to its "<default workspace root>" (and always
        -- picks up the configured venv). Ordered: config file wins over .git.
        root_markers = { 'pyrightconfig.json', 'pyproject.toml', '.git' },
      },
      clangd = {},
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            analyses = { unusedparams = true, unusedwrite = true },
          },
        },
      },
      zls = {
        settings = {
          zls = { enable_build_on_save = true, semantic_tokens = 'partial' },
        },
      },
    }
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
      'clang-format',
      'tree-sitter-cli',
    })

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    require('which-key').add {
      {
        '<leader>ri',
        function()
          vim.cmd 'w'
          local file = vim.fn.expand '%'
          vim.system({ 'ruff', 'check', file, '--fix' }, { text = true }, function()
            vim.schedule(function()
              vim.cmd 'edit'
            end)
          end)
        end,
        desc = 'remove unused imports (python)',
      },
    }

    vim.lsp.config('*', { capabilities = capabilities })
    for name, config in pairs(servers) do
      vim.lsp.config(name, config)
    end
    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}
