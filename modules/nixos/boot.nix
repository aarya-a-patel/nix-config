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
      extraInstallCommands = ''
        echo "default @saved" >> /boot/loader/loader.conf
      '';
    };
    loader.efi.canTouchEfiVariables = true;
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    initrd.verbose = false;
    consoleLogLevel = 0;
    kernelParams = ["quiet" "udev.log_level=0"];
    kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest-x86_64-v4;

    # Enable NTFS
    supportedFilesystems.ntfs = true;
  };
}
