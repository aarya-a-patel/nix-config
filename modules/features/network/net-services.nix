{config, ...}: {
  config.flake.modules.nixos.network-services = {...}: {
    services.fail2ban.enable = true;
    services.openssh = {
      enable = true;
      ports = [22];
      startWhenNeeded = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
    services.tailscale.enable = true;
    programs.mosh.enable = true;
  };
}
