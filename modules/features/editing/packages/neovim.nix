{inputs, ...}: let
  wrappers = inputs.nix-wrapper-modules.wrappers;
in {
  config.perSystem = {pkgs, ...}: let
    nvimConfig = pkgs.writeTextDir "init.lua" ''
      vim.loader.enable()

      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      if vim.fn.has("termguicolors") == 1 then
        vim.opt.termguicolors = true
      end

      vim.opt.background = "dark"
      vim.cmd.colorscheme("srcery")

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.linebreak = true
      vim.opt.showbreak = "++"
      vim.opt.textwidth = 80
      vim.opt.showmatch = true
      vim.opt.visualbell = true
      vim.opt.hlsearch = true
      vim.opt.smartcase = true
      vim.opt.ignorecase = true
      vim.opt.incsearch = true
      vim.opt.autoindent = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.smartindent = true
      vim.opt.smarttab = true
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.ruler = true
      vim.opt.undolevels = 1000
      vim.opt.backspace = { "indent", "eol", "start" }
      vim.opt.mouse = "a"
      vim.opt.scrolloff = 7
      vim.opt.list = true
      vim.opt.listchars = { tab = "▸ ", trail = "·" }
      vim.opt.showmode = false
      vim.opt.conceallevel = 2

      vim.keymap.set("n", "n", "nzz")
      vim.keymap.set("n", "N", "Nzz")
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

      vim.cmd.filetype("on")
      vim.cmd.syntax("on")

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        end,
      })
    '';
  in {
    packages.neovim = wrappers.neovim.wrap {
      inherit pkgs;
      settings = {
        aliases = [
          "vi"
          "vim"
        ];
        config_directory = nvimConfig;
      };
      hosts = {
        node.nvim-host.enable = false;
        python3.nvim-host.enable = false;
        ruby.nvim-host.enable = false;
      };
      extraPackages = with pkgs; [
        lua-language-server
        rust-analyzer
        nixd
        tree-sitter
        clang-tools
        texlab
        clang
        inputs.bacon-ls.defaultPackage.${pkgs.stdenv.hostPlatform.system}
        bacon
        tectonic
        biber
        texlivePackages.bibtex
        typst
        ripgrep
        xdotool
        psmisc
      ];
      specs = {
        srcery = pkgs.vimPlugins.srcery-vim;

        lualine = {
          data = with pkgs.vimPlugins; [
            lualine-nvim
            nvim-web-devicons
          ];
          config = ''
            require("lualine").setup({
              options = {
                theme = "srcery",
                icons_enabled = false,
                component_separators = "|",
                section_separators = { left = "", right = "" },
              },
              sections = {
                lualine_a = {
                  { "mode", separator = { left = "" }, right_padding = 2 },
                },
                lualine_b = { "filename", "branch" },
                lualine_c = { "fileformat" },
                lualine_x = {},
                lualine_y = { "filetype", "progress" },
                lualine_z = {
                  { "location", separator = { right = "" }, left_padding = 2 },
                },
              },
              inactive_sections = {
                lualine_a = { "filename" },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { "location" },
              },
              tabline = {},
              extensions = {},
            })
          '';
        };

        vimtex = {
          data = pkgs.vimPlugins.vimtex;
          before = ["INIT_MAIN"];
          config = ''
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_compiler_method = "tectonic"
            vim.g.tex_conceal = "abdmgs"
            vim.g.tex_flavor = "latex"
          '';
        };

        neoscroll = {
          data = pkgs.vimPlugins.neoscroll-nvim;
          config = ''require("neoscroll").setup({})'';
        };

        bufferline = {
          data = with pkgs.vimPlugins; [
            bufferline-nvim
            nvim-web-devicons
          ];
          config = ''
            require("bufferline").setup({
              options = {
                mode = "tabs",
                separator_style = "slant",
              },
            })
          '';
        };

        indent-blankline = {
          data = pkgs.vimPlugins.indent-blankline-nvim;
          config = ''
            require("ibl").setup({
              indent = {
                char = "▏",
              },
            })
          '';
        };

        mini-ai = {
          data = pkgs.vimPlugins.mini-ai;
          config = ''require("mini.ai").setup()'';
        };

        nvim-tree = {
          data = with pkgs.vimPlugins; [
            nvim-tree-lua
            nvim-web-devicons
          ];
          config = ''require("nvim-tree").setup({})'';
        };

        telescope = {
          data = with pkgs.vimPlugins; [
            telescope-nvim
            plenary-nvim
          ];
          config = ''
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
          '';
        };

        treesitter = {
          data = with pkgs.vimPlugins; [
            (nvim-treesitter.withPlugins (plugins:
              with plugins; [
                c
                lua
                vim
                vimdoc
                query
                javascript
                html
                rust
                nix
                typst
              ]))
            nvim-treesitter-context
          ];
          config = ''
            local treesitter_install_dir = vim.fn.stdpath("data") .. "/site"
            vim.fn.mkdir(treesitter_install_dir, "p")
            vim.opt.runtimepath:prepend(treesitter_install_dir)
            require("nvim-treesitter").setup({
              install_dir = treesitter_install_dir,
            })

            vim.api.nvim_create_autocmd("FileType", {
              callback = function()
                pcall(vim.treesitter.start)
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end,
            })
          '';
        };

        which-key = {
          data = with pkgs.vimPlugins; [
            which-key-nvim
            mini-icons
          ];
          config = ''
            require("which-key").setup({
              preset = "helix",
            })
            vim.keymap.set("n", "<leader>?", function()
              require("which-key").show({ global = false })
            end, { desc = "Buffer Local Keymaps (which-key)" })
          '';
        };

        lsp = {
          data = with pkgs.vimPlugins; [
            nvim-lspconfig
            cmp-nvim-lsp
            nvim-cmp
            luasnip
          ];
          config = ''
            require("cmp").setup({
              sources = {
                { name = "nvim_lsp" },
              },
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            for _, server in ipairs({
              "lua_ls",
              "rust_analyzer",
              "nixd",
              "clangd",
              "texlab",
              "bacon_ls",
            }) do
              vim.lsp.config(server, {
                capabilities = capabilities,
              })
              vim.lsp.enable(server)
            end
          '';
        };
      };
    };
  };
}
