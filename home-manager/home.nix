# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.nvim

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

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

  # Add stuff for your user as you see fit:
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = builtins.readFile ./dotfiles/wezterm/wezterm.lua;
  };

  programs.firefox = {
    enable = true;
  };

  # programs.neovim.enable = true;
  home.packages = (with pkgs; [
    google-chrome
    vlc
    slack
    vesktop
    vscode
    zed-editor
    # code-cursor
    qgroundcontrol
    # libreoffice-fresh
    # mailspring
    thunderbird
    # nodejs_22
    clickup
    texlab
    (prismlauncher.override {
      jdks = [
        temurin-bin-21
        temurin-bin-8
        temurin-bin-17
      ];
    })
    ghidra
    # input-leap # broken right now
    stable.input-leap
    papirus-icon-theme
    sshfs
    mission-planner
  ]) ++ [
    inputs.zen-browser.packages.x86_64-linux.default
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.plasma = {
    enable = true;
    workspace = {
      iconTheme = "Papirus-Dark";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
