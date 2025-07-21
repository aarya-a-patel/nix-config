{
  ...
}: {
  xdg = {
    enable = true;
    configFile."hypr" = {
      source = ./dotfiles/hypr;
      recursive = true;
    };
    configFile."rofi" = {
      source = ./dotfiles/rofi;
      recursive = true;
    };
    configFile."waybar" = {
      source = ./dotfiles/waybar;
      recursive = true;
    };
  };
}
