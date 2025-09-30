{pkgs, ...}
: {
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";

  # Enable iwd (better wifi).
  # networking.wireless.iwd.enable = true;
  # networking.wireless.iwd.settings = {
  #   General.EnableNetworkConfiguration = true;
  #   IPv6.Enabled = true;
  #   Settings.AutoConnect = true;
  # };

  # Enable the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 53317];
  };

  users.users.aaryap.extraGroups = ["networkmanager"];

  home-manager.sharedModules = [
    {
      home.packages = with pkgs; [
        networkmanagerapplet
      ];
    }
  ];
}
