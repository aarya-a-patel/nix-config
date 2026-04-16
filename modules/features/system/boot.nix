{
  config,
  inputs,
  lib,
  ...
}: {
  config.flake.modules.nixos.boot = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.aaryap.boot;
    cachyKernelPackages = pkgs.cachyosKernels.${cfg.cachyKernelVariant};
    cachyKernelVariants = [
      "linuxPackages-cachyos-latest"
      "linuxPackages-cachyos-latest-x86_64-v3"
      "linuxPackages-cachyos-latest-lto-x86_64-v3"
      "linuxPackages-cachyos-lts"
      "linuxPackages-cachyos-lts-x86_64-v3"
      "linuxPackages-cachyos-lts-lto-x86_64-v3"
      "linuxPackages-cachyos-bore"
      "linuxPackages-cachyos-bore-lto"
      "linuxPackages-cachyos-eevdf"
      "linuxPackages-cachyos-eevdf-lto"
    ];
  in {
    options.aaryap.boot.useCachyKernel = lib.mkEnableOption "the CachyOS LTO x86_64-v3 kernel";
    options.aaryap.boot.cachyKernelVariant = lib.mkOption {
      type = lib.types.enum cachyKernelVariants;
      default = "linuxPackages-cachyos-lts-x86_64-v3";
      description = "Which CachyOS kernel package set to use when aaryap.boot.useCachyKernel is enabled.";
    };

    config = {
      nixpkgs.overlays = lib.optional cfg.useCachyKernel inputs.nix-cachyos-kernel.overlays.pinned;

      boot = {
        bootspec.enable = true;
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        plymouth = {
          enable = true;
          theme = "bgrt";
        };
        initrd.verbose = false;
        consoleLogLevel = 0;
        kernelParams = [
          "quiet"
          "udev.log_level=0"
          "transparent_hugepage=madvise"
        ];
        kernelPackages =
          if cfg.useCachyKernel
          then cachyKernelPackages
          else pkgs.linuxPackages_latest;
        supportedFilesystems.ntfs = true;
        kernel.sysctl = {
          "vm.swappiness" = 10;
          "vm.vfs_cache_pressure" = 50;
        };
      };
    };
  };
}
