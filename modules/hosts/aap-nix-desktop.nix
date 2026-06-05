{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  config.flake.nixosConfigurations.aap-nix-desktop = flake.lib.mkNixosConfiguration {
    hostname = "aap-nix-desktop";
    username = "aaryap";
    homeProfile = "aaryap";
    modules = [
      {
        imports =
          (with inputs.hardware.nixosModules; [
            common-cpu-amd
            common-cpu-amd-pstate
            common-cpu-amd-zenpower
            common-pc-ssd
          ])
          ++ [
            flake.modules.nixos.nvidia-gpu
            flake.modules.nixos.binary-cache
            ../../machines/desktop/hardware-configuration.nix
          ];

        networking.hostName = "aap-nix-desktop";
        nix.settings.system-features = ["gccarch-znver5"];
        aaryap.boot = {
          useCachyKernel = true;
          cachyKernelVariant = "linuxPackages-cachyos-lts-x86_64-v4";
        };

        security.protectKernelImage = false;
        boot.resumeDevice = "/dev/disk/by-label/swap";
        fileSystems."/mnt/data-two" = {
          device = "/dev/disk/by-uuid/EE78A7EF78A7B4AD";
          fsType = "ntfs3";
          options = ["rw" "nofail" "uid=1000" "gid=100" "umask=022" "x-systemd.device-timeout=10s"];
        };
        systemd.sleep.settings.Sleep = {
          AllowSuspend = false;
          AllowHibernation = false;
          AllowHybridSleep = false;
          AllowSuspendThenHibernate = false;
        };
        swapDevices = [
          {
            device = "/dev/disk/by-label/swap";
            priority = 1;
          }
        ];

        system.stateVersion = "25.11";
      }
    ];
  };
}
