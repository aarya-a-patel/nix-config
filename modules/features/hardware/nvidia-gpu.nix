{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
  wrappers = inputs.nix-wrapper-modules.wrappers;
in {
  config = {
    perSystem = {pkgs, ...}: {
      packages.btop-cuda = wrappers.btop.wrap {
        inherit pkgs;
        package = pkgs.btop-cuda;
        settings.vim_mode = true;
      };
    };

    flake.modules.nixos.nvidia-gpu = {
      config,
      pkgs,
      ...
    }: let
      packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      imports = [
        inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
      ];

      home-manager.users.aaryap = {
        programs.btop.package = packages.btop-cuda;
      };

      hardware.graphics.enable = true;
      boot.kernelParams = ["nvidia.NVreg_UsePageAttributeTable=1"];

      systemd.services."systemd-suspend".serviceConfig.Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"'';

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      services.ollama = {
        enable = true;
        package = pkgs.stable.ollama-cuda;
      };

      environment.systemPackages = [pkgs.opencode];
    };
  };
}
