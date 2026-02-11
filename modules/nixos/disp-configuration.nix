{pkgs, ...}: {
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    excludePackages = [pkgs.xterm];
  };
}
