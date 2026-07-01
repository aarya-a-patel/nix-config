{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules.nixos.workloads = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.aaryap.workloads = {
      podman = lib.mkEnableOption "Podman and Docker-compatible tooling";
      containerd = lib.mkEnableOption "containerd, nerdctl, and Nydus tooling";
      waydroid = lib.mkEnableOption "Waydroid Android containers";
      virtualMachines = lib.mkEnableOption "libvirt, QEMU, and virt-manager";
    };

    config = lib.mkMerge [
      (lib.mkIf config.aaryap.workloads.podman {
        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
        };
        virtualisation.containers.registries.search = ["docker.io"];
        environment.systemPackages = [pkgs.podman-compose];
      })

      (lib.mkIf config.aaryap.workloads.containerd {
        virtualisation.containerd.enable = true;
        environment.systemPackages = [
          pkgs.nerdctl
          flake.packages.${pkgs.stdenv.hostPlatform.system}.nydus-bundle
        ];
      })

      (lib.mkIf config.aaryap.workloads.waydroid {
        virtualisation.waydroid = {
          enable = true;
          package = pkgs.waydroid-nftables;
        };
      })

      (lib.mkIf config.aaryap.workloads.virtualMachines {
        virtualisation.libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            swtpm.enable = true;
          };
        };
        programs.virt-manager.enable = true;
      })
    ];
  };
}
