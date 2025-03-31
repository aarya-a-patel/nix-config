{ pkgs, ... }:

{
  imports = [
    ./xdg-configuration.nix
  ];

  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.krohnkite
  ];

  # Screen Sharing
  xdg.portal.extraPortals = with pkgs; [
    kdePackages.xdg-desktop-portal-kde
  ];
}

