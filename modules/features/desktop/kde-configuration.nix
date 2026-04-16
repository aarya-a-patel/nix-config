{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules.nixos.kde = {pkgs, ...}: {
    imports = [
      flake.modules.nixos.xdg
    ];

    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
    ];

    environment.systemPackages = with pkgs; [
      kdePackages.krohnkite
    ];

    xdg.portal.extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}
