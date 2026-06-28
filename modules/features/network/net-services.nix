{config, ...}: {
  config.flake.modules.nixos.network-services = {username ? "aaryap", ...}: {
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
    services.tailscale = {
      enable = true;
      openFirewall = true;
      # extraUpFlags only applies via tailscaled-autoconnect with authKeyFile;
      # manually enrolled nodes should persist SSH with extraSetFlags instead.
      extraSetFlags = [
        "--ssh=true"
        "--operator=${username}"
      ];
    };
    programs.mosh.enable = true;
  };
}
