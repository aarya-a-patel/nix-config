{...}: {
  # SSH
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
  programs.mosh.enable = true;
}
