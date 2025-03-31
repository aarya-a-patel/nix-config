{ pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];

  xdg = {
    enable = true;
    configFile."nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };
}
