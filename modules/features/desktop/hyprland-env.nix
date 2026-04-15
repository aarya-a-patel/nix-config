{config, ...}: let
  top = config.repo;
in {
  config.repo.nixosModules.hyprland-env = {pkgs, ...}: {
    imports = [
      top.nixosModules.xdg
    ];

    home-manager.users.aaryap = {
      imports = [
        (top.homeManagerModules.hyprland "wayland-wm@hyprland.desktop.service")
      ];
    };

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland = {
          systemd.enable = false;
          package = null;
          portalPackage = null;
        };
      }
    ];

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    services = {
      gnome.gnome-keyring.enable = true;
      dbus.enable = true;
      gvfs.enable = true;
    };

    security.pam.services.hyprlock.enableGnomeKeyring = true;
    security.pam.services.ashell.enableGnomeKeyring = true;

    programs.seahorse.enable = true;

    environment.systemPackages = with pkgs; [
      libsecret
      inotify-tools
      brightnessctl
      dunst
    ];

    xdg.portal = {
      config.hyprland.default = ["hyprland" "gtk"];
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };
}
