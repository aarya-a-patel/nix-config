{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  config.flake.nixosConfigurations.aap-zenbook = flake.lib.mkNixosConfiguration {
    hostname = "aap-zenbook";
    username = "aaryap";
    homeProfile = "aaryap";
    modules = [
      ({
        lib,
        pkgs,
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
            flake.modules.nixos.cosmic
            flake.modules.nixos.hyprland-env
            flake.modules.nixos.asus-touch-numpad-driver
            flake.modules.nixos.facial-recognition
            ../../machines/asus-zenbook/hardware-configuration.nix
          ];

        networking.hostName = "aap-zenbook";
        xdg.portal.extraPortals = lib.mkForce (with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-cosmic
          xdg-desktop-portal-hyprland
        ]);
        nix.settings = {
          system-features = ["gccarch-znver2"];
        };
        aaryap.boot = {
          useCachyKernel = true;
          cachyKernelVariant = "linuxPackages-cachyos-lts-x86_64-v3";
        };
        aaryap.workloads = {
          podman = true;
        };
        aaryap.steamosOptimizations.enable = true;

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

        system.stateVersion = "25.05";
      })
    ];
  };
}
