{config, ...}: {
  config.flake.modules.nixos.network-services = {...}: {
    services.fail2ban.enable = true;
    services.openssh = {
      enable = true;
      ports = [22];
      startWhenNeeded = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = true;
        PubkeyAuthentication = true;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
    security.pam.services.sshd = {
      howdy.enable = false;
      unixAuth = true;
    };
    services.tailscale.enable = true;
    programs.mosh.enable = true;
  };
}
