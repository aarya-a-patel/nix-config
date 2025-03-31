{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history = {
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
      share = false;
      ignoreAllDups = true;
    };
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    shellAliases = {
      ls = "eza";
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv.enable = true;

  programs.bat.enable = true;

  programs.git = {
    enable = true;
    delta.enable = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    colors = "auto";
    icons = "auto";
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableTransience = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    fd
    ripgrep
    ncdu
    rmlint
  ];
}
