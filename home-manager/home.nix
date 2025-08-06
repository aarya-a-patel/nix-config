# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  firefox-extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    bitwarden
    darkreader
    onetab
    one-click-wayback
  ];
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.nvim

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.zen-browser.homeModules.beta

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

  programs.firefox = {
    enable = true;
    profiles.default.extensions.packages = firefox-extensions;
  };
  programs.zen-browser = {
    enable = true;
    profiles.default = {
      settings = {
        "zen.widget.linux.transparency" = true;
        "zen.view.compact.should-enable-at-startup" = true;
        "zen.theme.gradient.show-custom-colors" = true;
        "zen.view.grey-out-inactive-windows" = false;
      };
      extensions.packages = firefox-extensions;
    };
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
  };

  stylix.targets.firefox.profileNames = ["default"];
  stylix.targets.zen-browser.enable = false;

  home.packages = with pkgs; [
    vlc
    vesktop
    vscode
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
    ghidra
    stable.input-leap
    papirus-icon-theme
    sshfs
  ];

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
}
