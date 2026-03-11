{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  boot = {
    # Bootloader.
    bootspec.enable = true;
    loader.systemd-boot = {
      enable = true;
      # extraInstallCommands = ''
      #   echo "default @saved" >> /boot/loader/loader.conf
      # '';
    };
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
    kernelPackages = let
      helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" {};
    in
      helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest-lto-x86_64-v3);

    # Enable NTFS
    supportedFilesystems.ntfs = true;

    kernel.sysctl = {
      # reduce disk swapping
      "vm.swappiness" = 10;
      # keep filesystem caches longer
      "vm.vfs_cache_pressure" = 50;
    };
  };
}
