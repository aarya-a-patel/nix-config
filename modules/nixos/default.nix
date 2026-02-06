# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  asus-touch-numpad-driver = import ./asus-touch-numpad-driver.nix;
  hyprland-env = import ./hyprland-env.nix;
  bluetooth = import ./bluetooth.nix;
  kde = import ./kde-configuration.nix;
  gnome = import ./gnome-configuration.nix;
  cosmic = import ./cosmic-configuration.nix;
  dm = import ./dm-configuration.nix;
  shell = import ./shell-configuration.nix;
  neovim = import ./neovim-configuration.nix;
  audio = import ./audio.nix;
  boot = import ./boot.nix;
  display = import ./disp-configuration.nix;
  localization = import ./localization.nix;
  network-services = import ./net-services.nix;
  networking = import ./networking.nix;
}
