{pkgs, ...}: {
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable the COSMIC Desktop Evironment.
  # services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  environment.systemPackages = with pkgs; [
    cosmic-ext-applet-caffeine
    cosmic-ext-applet-external-monitor-brightness
    cosmic-ext-applet-privacy-indicator
    cosmic-ext-tweaks
  ];

  # Disable cosmic osd for now (not working)
  services.desktopManager.cosmic.showExcludedPkgsWarning = false; # cosmic-osd is considered essential, but we bring our own polkit agent.
  environment.cosmic.excludePackages = [pkgs.cosmic-osd];
  home-manager.sharedModules = [
    ({...}: {
      services.polkit-gnome.enable = true;
    })
  ];
}
