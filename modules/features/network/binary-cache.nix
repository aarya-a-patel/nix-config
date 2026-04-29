{config, ...}: {
  config.flake.modules.nixos.binary-cache = {pkgs, ...}: {
    services.atticd = {
      enable = true;
      environmentFile = "/var/lib/atticd/atticd.env";
      settings.listen = "[::]:8080";
    };

    networking.firewall.allowedTCPPorts = [
      8080
    ];

    environment.systemPackages = with pkgs; [
      attic-client
    ];
  };
}
