{config, ...}: {
  config.flake.modules.nixos.shell = {
    pkgs,
    lib,
    ...
  }: {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions = {
        enable = true;
        async = true;
      };
    };
    users.defaultUserShell = pkgs.zsh;

    programs.starship = {
      enable = true;
      interactiveOnly = true;
    };

    programs.direnv.enable = true;

    programs.nh = {
      enable = true;
      flake = lib.mkDefault "/home/aaryap/repos/nix-config";
    };

    environment.etc."ncdu.conf" = {
      source = ../../_assets/ncdu.conf;
      mode = "0444";
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
  };
}
