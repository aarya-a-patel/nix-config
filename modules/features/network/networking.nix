{config, ...}: {
  config.repo.nixosModules.networking = {pkgs, ...}: {
    networking.wireless.enable = true;
    networking.networkmanager.enable = true;
    networking.nftables.enable = true;

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
  };
}
