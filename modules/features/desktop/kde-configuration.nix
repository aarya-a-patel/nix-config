{config, ...}: let
  top = config.repo;
in {
  config.repo.nixosModules.kde = {pkgs, ...}: {
    imports = [
      top.nixosModules.xdg
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
