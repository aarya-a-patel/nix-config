{
  config,
  inputs,
  ...
}: {
  config.flake.modules = {
    homeManager.shell-nix = {
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs.nh.enable = lib.mkDefault true;
      programs.direnv.enable = lib.mkDefault true;

      programs.nix-index = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault true;
        enableZshIntegration = lib.mkDefault true;
      };

      home.packages = with pkgs; [
        nix-output-monitor
        comma
      ];
    };

    nixos.shell-nix = {
      lib,
      pkgs,
      ...
    }: {
      programs.direnv.enable = lib.mkDefault true;

      programs.nh = {
        enable = lib.mkDefault true;
        flake = lib.mkDefault "/home/aaryap/repos/nix-config";
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
      ];
    };
  };
}
