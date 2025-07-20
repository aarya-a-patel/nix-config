{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.pop-shell
    gnomeExtensions.blur-my-shell
    gnomeExtensions.unite
    gnome-tweaks
  ];

  # Use Alternative Terminal Emulators
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "wezterm";
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    gnome-terminal
    epiphany
    geary
  ];

  # Performance Improvements
  nixpkgs.config.allowAliases = false;

  # Screen Sharing
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
}
