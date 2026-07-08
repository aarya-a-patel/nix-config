{
  config,
  inputs,
  ...
}: {
  config.flake.modules.homeManager.shell-ai = {pkgs, ...}: {
    home.packages = [
      pkgs.codex
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
