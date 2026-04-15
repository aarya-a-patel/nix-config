{config, ...}: let
  top = config.repo;
in {
  config.repo.homeManagerModules.nvim = {pkgs, ...}: {
    nixpkgs.overlays = [
      top.overlays.bacon-ls-package
    ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      extraPackages = with pkgs; [
        lua-language-server
        rust-analyzer
        nixd
        tree-sitter
        clang-tools
        texlab
        clang
      ];
    };

    home.packages = with pkgs; [
      bacon
      stable.tectonic
      typst
    ];

    programs.zathura = {
      enable = true;
      extraConfig = builtins.readFile (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/zathura/master/zathurarc";
        sha256 = "03r5gbfp3m4hlzba61lgk0z95avjjlb9h8jb1nacv44aqcr04s84";
      });
    };

    xdg = {
      enable = true;
      configFile."nvim" = {
        source = ../../_assets/nvim/nvim;
        recursive = true;
      };
    };
  };
}
