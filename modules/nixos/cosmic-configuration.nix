{ ... }:

{
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable the COSMIC Desktop Evironment.
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
}

