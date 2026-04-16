{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules.homeManager.wsl = {pkgs, ...}: {
    imports = [
      flake.modules.homeManager.shell
      flake.modules.homeManager.nvim
    ];

    nixpkgs = {
      overlays = [
        flake.overlays.stable-packages
      ];
      config.allowUnfree = true;
    };

    home = {
      username = "aarya";
      homeDirectory = "/home/aarya";
    };

    home.packages = with pkgs; [
      cachix
      sshfs
      uv
    ];

    home.sessionVariables.XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
    programs.home-manager.enable = true;
    programs.nh.flake = "/home/aarya/repos/nix-config";
    systemd.user.startServices = "sd-switch";
    home.stateVersion = "24.05";
  };

  config.flake.homeConfigurations."aarya@AAP-Desktop" = flake.lib.mkHomeConfiguration {
    system = "x86_64-linux";
    profile = "wsl";
  };
}
