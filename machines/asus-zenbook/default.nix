{
  inputs,
  outputs,
  ...
}: {
  imports =
    (with inputs.hardware.nixosModules; [
      common-cpu-amd
      common-cpu-amd-pstate
      common-cpu-amd-zenpower
      common-gpu-amd
      common-pc-laptop-ssd
    ])
    ++ [
      outputs.nixosModules.asus-touch-numpad-driver
      outputs.nixosModules.facial-recognition

      ./hardware-configuration.nix
    ];

  programs.nh.flake = "/etc/nixos";

  services.xserver.videoDrivers = ["amdgpu"];

  # enable hibernation
  security.protectKernelImage = false;
  boot.resumeDevice = "/dev/disk/by-label/swap";

  # memory
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
      # size = 16*1024;
      priority = 1;
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
