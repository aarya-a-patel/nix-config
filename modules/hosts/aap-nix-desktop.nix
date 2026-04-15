{
  config,
  inputs,
  ...
}: let
  top = config.repo;
in {
  config.repo.hosts.aap-nix-desktop = {
    username = "aaryap";
    homeProfile = "aaryap";
    module = {...}: {
      imports =
        (with inputs.hardware.nixosModules; [
          common-cpu-amd
          common-cpu-amd-pstate
          common-cpu-amd-zenpower
          common-pc-ssd
        ])
        ++ [
          top.nixosModules.nvidia-gpu
          ../../machines/desktop/hardware-configuration.nix
        ];

      networking.hostName = "aap-nix-desktop";
      nix.settings.system-features = ["gccarch-znver2"];
      aaryap.boot = {
        useCachyKernel = true;
        cachyKernelVariant = "linuxPackages-cachyos-lts-x86_64-v3";
      };

      security.protectKernelImage = false;
      boot.resumeDevice = "/dev/disk/by-label/swap";
      swapDevices = [
        {
          device = "/dev/disk/by-label/swap";
          priority = 1;
        }
      ];

      system.stateVersion = "25.11";
    };
  };
}
