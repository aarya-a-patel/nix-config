{config, ...}: let
  flake = config.flake;
in {
  config.flake.modules = {
    homeManager.shell-development = {
      lib,
      pkgs,
      ...
    }: let
      packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      programs.git = {
        enable = lib.mkDefault true;
        settings.user = lib.mkDefault {
          email = "aarya.patel@gmail.com";
          name = "Aarya Patel";
        };
        settings.core.editor = lib.mkDefault (lib.getExe packages.helix);
      };

      programs.delta = {
        enable = lib.mkDefault true;
        enableGitIntegration = lib.mkDefault true;
      };

      programs.helix = {
        enable = lib.mkDefault true;
        package = lib.mkDefault packages.helix;
        extraPackages = with pkgs; [
          lua-language-server
          rust-analyzer
          nixd
          tree-sitter
          clang-tools
          clang
          tombi
          yaml-language-server
          vscode-json-languageserver
          vscode-css-languageserver
        ];
      };
    };

    nixos.shell-development = {lib, ...}: {
      programs.git.enable = lib.mkDefault true;
    };
  };
}
