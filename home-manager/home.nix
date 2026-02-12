# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  pkgs,
  ...
}: let
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.nvim
    outputs.homeManagerModules.browsers

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.zen-browser.homeModules.beta
    inputs.wallpaperengine.homeManagerModules.default
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      inputs.nur.overlays.default

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "aaryap";
    homeDirectory = "/home/aaryap";
  };

  services.simple-linux-wallpaperengine.enable = true;

  # Add stuff for your user as you see fit:
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = builtins.readFile ./dotfiles/wezterm/wezterm.lua;
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
    # ghidra
    input-leap
    papirus-icon-theme
    sshfs
    gnome-network-displays
    libreoffice-qt
    wike
    localsend
    drawio
    outputs.packages.${stdenv.hostPlatform.system}.mouseless-click
  ];

  #vscode
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      rocq-prover.vsrocq
      asvetliakov.vscode-neovim
    ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  /*
  programs.plasma = {
    enable = true;
    workspace = {
      iconTheme = "Papirus-Dark";
    };
  };
  */

  /*
  qt = {
    enable = true;
    platformTheme.name = "kde6";
    style.name = "kvantum";
  };
  */

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";

  # Disable manual generation to avoid builtins.toFile warning
  # See: https://github.com/nix-community/home-manager/issues/7935
  manual.manpages.enable = false;
}
