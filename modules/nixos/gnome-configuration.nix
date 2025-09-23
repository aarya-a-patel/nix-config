{pkgs, ...}: {
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.pop-shell
    gnomeExtensions.blur-my-shell
    gnomeExtensions.unite
    gnomeExtensions.appindicator
    gnome-tweaks
  ];

  services.udev.packages = [pkgs.gnome-settings-daemon]; # For system tray icon

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
