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
    delta.enable = true;
    userEmail = "aarya.patel@gmail.com";
    userName = "Aarya Patel";
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
      editor.line-number = "relative";
    };
    languages = {
      language-server = {
        nixd.command = lib.getExe pkgs.nixd;
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.alejandra;
          language-servers = ["nixd"];
        }
      ];
    };
    themes = {
      gruvbox_transparent = {
        "inherits" = "gruvbox";
        "ui.background" = {};
      };
    };
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
