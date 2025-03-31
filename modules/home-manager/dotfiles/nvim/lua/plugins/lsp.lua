return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = function()
      local lsp_zero = require('lsp-zero')

      lsp_zero.on_attach(function(client, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp_zero.default_keymaps({buffer = bufnr})
      end)

      local lspconfig = require('lspconfig')
      lspconfig.lua_ls.setup({})
      lspconfig.rust_analyzer.setup({})
      lspconfig.nixd.setup({})
      lspconfig.clangd.setup({})
      lspconfig.texlab.setup({})
    end,
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/nvim-cmp',
      'L3MON4D3/LuaSnip',
    },
  },
  {'neovim/nvim-lspconfig' },
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},
}
