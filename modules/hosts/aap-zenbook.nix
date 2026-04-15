{
  config,
  inputs,
  ...
}: let
  top = config.repo;
in {
  config.repo.hosts.aap-zenbook = {
    username = "aaryap";
    homeProfile = "aaryap";
    module = {pkgs, ...}: {
      imports =
        (with inputs.hardware.nixosModules; [
          common-cpu-amd
          common-cpu-amd-pstate
          common-cpu-amd-zenpower
          common-gpu-amd
          common-pc-laptop-ssd
        ])
        ++ [
          top.nixosModules.asus-touch-numpad-driver
          top.nixosModules.facial-recognition
          ../../machines/asus-zenbook/hardware-configuration.nix
        ];

      networking.hostName = "aap-zenbook";
      nix.settings.system-features = ["gccarch-znver2"];
      aaryap.boot = {
        useCachyKernel = true;
        cachyKernelVariant = "linuxPackages-cachyos-lts-x86_64-v3";
      };

      programs.nh.flake = "/etc/nixos";
      services.xserver.videoDrivers = ["amdgpu"];
      security.protectKernelImage = false;
      boot.resumeDevice = "/dev/disk/by-label/swap";
      swapDevices = [
        {
          device = "/dev/disk/by-label/swap";
          priority = 1;
        }
      ];

      services.ollama = {
        enable = true;
        package = pkgs.stable.ollama;
      };

      system.stateVersion = "25.05";
    };
  };
}
