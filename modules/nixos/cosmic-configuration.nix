{pkgs, ...}: {
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable the COSMIC Desktop Evironment.
  # services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  environment.systemPackages = with pkgs; [
    cosmic-ext-applet-privacy-indicator
    cosmic-ext-applet-caffeine
    cosmic-ext-tweaks
  ];
}
