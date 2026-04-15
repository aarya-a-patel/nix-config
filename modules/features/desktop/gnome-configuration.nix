{config, ...}: let
  top = config.repo;
in {
  config.repo.nixosModules.gnome = {pkgs, ...}: {
    imports = [
      top.nixosModules.xdg
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
