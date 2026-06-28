{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules.nixos.gnome = {pkgs, ...}: {
    imports = [
      flake.modules.nixos.xdg
    ];

    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.pop-shell
      gnomeExtensions.blur-my-shell
      gnomeExtensions.unite
      gnomeExtensions.appindicator
      gnome-tweaks
    ];

    services.udev.packages = [pkgs.gnome-settings-daemon];

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

    nixpkgs.config.allowAliases = false;

    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
