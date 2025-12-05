{
  pkgs,
  config,
  lib,
  ...
}: {
  home.shellAliases = {
    ls = "eza";
    cd = "z";
  };

  programs.zsh = {
    enable = true;
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

  programs.bash = {
    enable = true;
  };

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
    themes = {
      gruvbox_transparent = {
        "inherits" = "gruvbox";
        "ui.background" = {};
      };
    };
    extraPackages = with pkgs; [
      # Language server deps
      lua-language-server
      rust-analyzer
      nixd
      tree-sitter
      clang-tools
      texlab
      clang
      bacon-ls
      tinymist
      typst
      tombi
      yaml-language-server
      vscode-json-languageserver
      vscode-css-languageserver
    ];
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
    claude-code
    opencode
  ];
}
