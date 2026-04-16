{
  config,
  inputs,
  lib,
  ...
}: let
  flake = config.flake;
  wrappers = inputs.nix-wrapper-modules.wrappers;
in {
  config = {
    perSystem = {pkgs, ...}: {
      packages = {
        wezterm = wrappers.wezterm.wrap {
          inherit pkgs;
          package = pkgs.wezterm;
          "wezterm.lua".content = builtins.readFile ../../_assets/wezterm/wezterm.lua;
        };

        kitty = wrappers.kitty.wrap {
          inherit pkgs;
          package = pkgs.kitty;
          settings = {
            window_padding_width = 10;
            touch_scroll_multipler = 10.0;
          };
        };

        btop = wrappers.btop.wrap {
          inherit pkgs;
          package = pkgs.btop;
          settings.vim_mode = true;
        };
      };
    };

    flake.modules.homeManager.shell = {
      pkgs,
      config,
      lib,
      ...
    }: let
      packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      home.shellAliases = {
        ls = "eza";
        cd = "z";
      };

      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        history = {
          path = "${config.xdg.dataHome}/zsh/history";
          extended = true;
          share = false;
          ignoreAllDups = true;
        };
        syntaxHighlighting.enable = true;
        defaultKeymap = "viins";
        autosuggestion = {
          enable = true;
          strategy = [
            "history"
            "completion"
          ];
        };
        plugins = [
          {
            name = "vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];
      };

      programs.bash.enable = true;
      programs.nh.enable = true;

      programs.atuin = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      programs.direnv.enable = true;
      programs.bat.enable = true;

      programs.git = {
        enable = true;
        settings.user = {
          email = "aarya.patel@gmail.com";
          name = "Aarya Patel";
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
      };

      programs.eza = {
        enable = true;
        git = true;
        colors = "auto";
        icons = "auto";
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      programs.starship = {
        enable = true;
        enableTransience = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      programs.helix = {
        enable = true;
        package = packages.helix;
        settings = {
          theme = lib.mkForce "gruvbox_transparent";
          editor = {
            line-number = "relative";
            trim-trailing-whitespace = true;
          };
        };
        languages = {
          language-server = {
            nixd.command = lib.getExe pkgs.nixd;
            tinymist = {
              command = lib.getExe pkgs.tinymist;
              config = {
                exportPdf = "onType";
                preview.background = {
                  enabled = true;
                  args = [
                    "--data-plane-host=127.0.0.1:0"
                    "--invert-colors=never"
                    "--open"
                  ];
                };
              };
            };
          };
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = lib.getExe pkgs.alejandra;
              language-servers = ["nixd"];
            }
            {
              name = "typst";
              auto-format = true;
              formatter = {
                command = lib.getExe pkgs.typstyle;
                args = ["--wrap-text"];
              };
            }
          ];
        };
        themes.gruvbox_transparent = {
          "inherits" = "gruvbox";
          "ui.background" = {};
        };
        extraPackages = with pkgs; [
          lua-language-server
          rust-analyzer
          nixd
          tree-sitter
          clang-tools
          texlab
          clang
          tinymist
          typst
          tombi
          yaml-language-server
          vscode-json-languageserver
          vscode-css-languageserver
        ];
      };

      programs.nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      programs.btop = {
        enable = true;
        package = lib.mkDefault packages.btop;
        settings.vim_mode = true;
      };

      home.packages = with pkgs; [
        fd
        ripgrep
        ncdu
        rmlint
        unzip
        autossh
        nix-output-monitor
        nix-fast-build
        nix-tree
        just
        comma
        codex
      ];
    };
  };
}
