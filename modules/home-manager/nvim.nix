{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    # LaTeX Deps
    tectonic
    zathura

    # Language server deps
    lua-language-server
    rust-analyzer
    nixd
    tree-sitter
    clang-tools
    texlab
    clang
  ];

  xdg = {
    enable = true;
    configFile."nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };
}
