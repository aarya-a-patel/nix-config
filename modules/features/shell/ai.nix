{config, ...}: {
  config.flake.modules.homeManager.shell-ai = {pkgs, ...}: {
    home.packages = [pkgs.codex];
  };
}
