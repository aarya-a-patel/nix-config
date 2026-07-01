{config, ...}: {
  config.flake.modules = {
    homeManager.shell-extra = {pkgs, ...}: {
      xdg.configFile."ncdu/config".source = ../../_assets/ncdu.conf;

      programs.helix.extraPackages = with pkgs; [
        texlab
        tinymist
        typst
      ];

      home.packages = with pkgs; [
        ncdu
        rmlint
        autossh
        nix-fast-build
        nix-tree
      ];
    };

    nixos.shell-extra = {...}: {
      environment.etc."ncdu.conf" = {
        source = ../../_assets/ncdu.conf;
        mode = "0444";
      };
    };
  };
}
