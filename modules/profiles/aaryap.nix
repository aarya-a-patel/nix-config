{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  config.flake.modules.homeManager.aaryap = {
    config,
    pkgs,
    ...
  }: let
    packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [
      flake.modules.homeManager.shell
      flake.modules.homeManager.nvim
      flake.modules.homeManager.browsers
      flake.modules.homeManager.cosmic
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

    gtk.gtk4.theme = config.gtk.theme;

    programs.simple-wallpaper-engine.enable = true;

    programs.wezterm = {
      enable = true;
      package = pkgs.wezterm;
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
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium
      packages.mouseless-click
      packages.apply-pilot
    ];

    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          rocq-prover.vsrocq
          (pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "vscode-helix-emulation";
            publisher = "jasew";
            version = "0.7.0";
            sha256 = "sha256-gYyIVnXG9Atmik0c1FsRKO2idFnufwl26nOiH3DYPLY=";
          })
        ];
        userSettings = {
          "extensions.experimental.affinity"."jasew.vscode-helix-emulation" = 1;
          "helixKeymap.toggleRelativeLineNumbers" = true;
        };
      };
    };

    programs.home-manager.enable = true;
    services.tailscale-systray.enable = pkgs.stdenv.hostPlatform.isLinux;
    systemd.user.startServices = "sd-switch";
    home.stateVersion = "25.05";
    manual.manpages.enable = false;
  };

  config.flake.homeConfigurations."aaryap@nixos" = flake.lib.mkHomeConfiguration {
    system = "x86_64-linux";
    profile = "aaryap";
  };
}
