{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules.nixos.hyprland-env = {pkgs, ...}: {
    imports = [
      flake.modules.nixos.xdg
    ];

    home-manager.users.aaryap = {
      imports = [
        flake.modules.homeManager.hyprland
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
