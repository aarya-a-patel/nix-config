{pkgs, ...}: {
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
    excludePackages = [pkgs.xterm];
  };
}
