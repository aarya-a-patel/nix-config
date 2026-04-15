{
  config,
  inputs,
  ...
}: {
  config.repo.nixosModules.nvidia-gpu = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
    ];

    home-manager.users.aaryap = {
      programs.btop.package = pkgs.btop-cuda;
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
}
