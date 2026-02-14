{pkgs, ...}: {
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    excludePackages = [pkgs.xterm];
  };

  services.ddccontrol.enable = true;

  environment.systemPackages = [
    pkgs.ddcutil
    pkgs.ddcutil-service
  ];
}
