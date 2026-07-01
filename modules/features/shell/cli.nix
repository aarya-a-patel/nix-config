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
      packages.btop = wrappers.btop.wrap {
        inherit pkgs;
        package = pkgs.btop;
        settings.vim_mode = true;
      };
    };

    flake.modules = {
      homeManager.shell-cli = {
        lib,
        pkgs,
        ...
      }: let
        packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
      in {
        home.shellAliases = {
          ls = lib.mkDefault "eza";
          cd = lib.mkDefault "z";
        };

        programs.bat.enable = lib.mkDefault true;

        programs.eza = {
          enable = lib.mkDefault true;
          git = lib.mkDefault true;
          colors = lib.mkDefault "auto";
          icons = lib.mkDefault "auto";
          enableZshIntegration = lib.mkDefault true;
          enableBashIntegration = lib.mkDefault true;
        };

        programs.zoxide = {
          enable = lib.mkDefault true;
          enableZshIntegration = lib.mkDefault true;
          enableBashIntegration = lib.mkDefault true;
        };

        programs.btop = {
          enable = lib.mkDefault true;
          package = lib.mkDefault packages.btop;
        };

        home.packages = with pkgs; [
          fd
          ripgrep
          wget
          unzip
          just
        ];
      };

      nixos.shell-cli = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          wget
          unzip
        ];
      };
    };
  };
}
