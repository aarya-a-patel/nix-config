{config, ...}: let
  flake = config.flake;
in {
  config = {
    flake.modules.homeManager.nvim = {pkgs, ...}: let
      packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      home.packages = [
        packages.neovim
      ];

      programs.zathura = {
        enable = true;
        extraConfig = builtins.readFile (builtins.fetchurl {
          url = "https://raw.githubusercontent.com/dracula/zathura/master/zathurarc";
          sha256 = "03r5gbfp3m4hlzba61lgk0z95avjjlb9h8jb1nacv44aqcr04s84";
        });
      };
    };
  };
}
