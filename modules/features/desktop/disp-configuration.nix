{config, ...}: {
  config.flake.modules.nixos.display = {pkgs, ...}: {
    services.xserver = {
      enable = true;
      excludePackages = [pkgs.xterm];
    };

    services.ddccontrol.enable = true;

    environment.systemPackages = [
      pkgs.ddcutil
      pkgs.ddcutil-service
    ];
  };
}
