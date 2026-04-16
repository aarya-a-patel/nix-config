{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules.nixos.cosmic = {pkgs, ...}: {
    imports = [
      flake.modules.nixos.xdg
    ];

    services.desktopManager.cosmic.enable = true;

    xdg.portal = {
      config = {
        cosmic.default = ["cosmic" "gtk"];
        COSMIC.default = ["cosmic" "gtk"];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-cosmic
      ];
    };

    environment.systemPackages = with pkgs; [
      cosmic-ext-applet-caffeine
      cosmic-ext-applet-external-monitor-brightness
      cosmic-ext-applet-privacy-indicator
      cosmic-ext-tweaks
    ];

    services.desktopManager.cosmic.showExcludedPkgsWarning = false;
    environment.cosmic.excludePackages = [pkgs.cosmic-osd];
    home-manager.sharedModules = [
      ({...}: {
        services.polkit-gnome.enable = true;
      })
    ];
  };
}
