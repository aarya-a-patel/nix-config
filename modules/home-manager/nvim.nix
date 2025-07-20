{
  pkgs,
  inputs,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # Language server deps
      lua-language-server
      rust-analyzer
      nixd
      tree-sitter
      clang-tools
      texlab
      clang
      inputs.bacon-ls.defaultPackage.${pkgs.system}
    ];
  };

  home.packages = with pkgs; [
    bacon
    # LaTeX Deps
    tectonic
  ];

  programs.zathura = {
    enable = true;
    extraConfig = builtins.readFile (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/dracula/zathura/master/zathurarc";
      sha256 = "03r5gbfp3m4hlzba61lgk0z95avjjlb9h8jb1nacv44aqcr04s84"; # Replace with actual hash
    });
  };

  xdg = {
    enable = true;
    configFile."nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };
}
