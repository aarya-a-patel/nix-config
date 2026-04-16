{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  config.flake.modules.homeManager.aaryap = {pkgs, ...}: let
    packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [
      flake.modules.homeManager.shell
      flake.modules.homeManager.nvim
      flake.modules.homeManager.browsers
      inputs.zen-browser.homeModules.beta
      inputs.wallpaperengine.homeManagerModules.default
    ];

    nixpkgs = {
      overlays = [
        flake.overlays.stable-packages
        inputs.nur.overlays.default
      ];
      config.allowUnfree = true;
    };

    home = {
      username = "aaryap";
      homeDirectory = "/home/aaryap";
    };

    programs.simple-wallpaper-engine.enable = true;

    programs.wezterm = {
      enable = true;
      package = packages.wezterm;
      enableZshIntegration = true;
      enableBashIntegration = true;
      extraConfig = builtins.readFile ../_assets/wezterm/wezterm.lua;
    };

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      installVimSyntax = true;
      installBatSyntax = true;
    };

    programs.kitty = {
      enable = true;
      package = packages.kitty;
      enableGitIntegration = true;
      shellIntegration = {
        mode = "";
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
      settings = {
        window_padding_width = 10;
        touch_scroll_multipler = 10.0;
      };
    };

    home.packages = with pkgs; [
      vlc
      stable.vesktop
      zed-editor
      thunderbird
      texlab
      (prismlauncher.override {
        jdks = [
          temurin-bin-21
          temurin-bin-8
          temurin-bin-17
        ];
      })
      input-leap
      papirus-icon-theme
      sshfs
      gnome-network-displays
      libreoffice-qt
      wike
      localsend
      drawio
      packages.mouseless-click
      packages.apply-pilot
    ];

    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        rocq-prover.vsrocq
        asvetliakov.vscode-neovim
      ];
    };

    programs.home-manager.enable = true;
    systemd.user.startServices = "sd-switch";
    home.stateVersion = "25.05";
    manual.manpages.enable = false;
  };

  config.flake.homeConfigurations."aaryap@nixos" = flake.lib.mkHomeConfiguration {
    system = "x86_64-linux";
    profile = "aaryap";
  };
}
