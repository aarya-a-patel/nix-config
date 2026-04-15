{config, ...}: let
  top = config.repo;
in {
  config.repo.homeProfiles.wsl = {pkgs, ...}: {
    imports = [
      top.homeManagerModules.shell
      top.homeManagerModules.nvim
    ];

    nixpkgs = {
      overlays = [
        top.overlays.additions
        top.overlays.modifications
        top.overlays.stable-packages
        top.overlays.wrapper-programs
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

  config.repo.standaloneHomes."aarya@AAP-Desktop" = {
    system = "x86_64-linux";
    profile = "wsl";
  };
}
