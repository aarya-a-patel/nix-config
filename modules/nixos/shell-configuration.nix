{ pkgs, config, ... }:

{
  # Enable Zsh
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions = {
      enable = true;
      async = true;
    };
  };
  users.defaultUserShell = pkgs.zsh;

  # Enable Starship
  programs.starship = {
    enable = true;
    interactiveOnly = true;
  };

  # direnv
  programs.direnv.enable = true;

  # enable nh
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  environment.etc = {
    # Creates /etc/ncdu
    "ncdu.conf" = {
      source = ./etc/ncdu.conf;

      # The UNIX file mode bits
      mode = "0444";
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    unzip
    autossh
    nix-output-monitor
    nix-fast-build
    nix-tree
  ];
}
