{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules = {
    homeManager.shell = {
      imports = with flake.modules.homeManager; [
        shell-core
        shell-cli
        shell-nix
        shell-development
        shell-zellij
      ];
    };

    nixos.shell = {
      imports = with flake.modules.nixos; [
        shell-core
        shell-cli
        shell-nix
        shell-development
      ];
    };
  };
}
