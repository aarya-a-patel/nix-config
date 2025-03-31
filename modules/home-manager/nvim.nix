{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # Language server deps
      lua-language-server
      rust-analyzer
      nixd
      tree-sitter
      clang-tools
      texlab
      clang
    ];
  };

  home.packages = with pkgs; [
    # LaTeX Deps
    tectonic
    zathura
  ];

  xdg = {
    enable = true;
    configFile."nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };
}
