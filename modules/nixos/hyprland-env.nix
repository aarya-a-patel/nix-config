{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./xdg-configuration.nix
  ];

  home-manager.users.aaryap = {
    imports = [
      outputs.homeManagerModules.hypr
    ];
  };

  # Enable Hyprland.
  programs = {
    uwsm.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    # waybar.enable = true;
    hyprlock.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    hypridle.enable = true;
    dbus.enable = true;
    gvfs.enable = true;
  };

  security.pam.services.hyprlock.enableGnomeKeyring = true;
  security.pam.services.ashell.enableGnomeKeyring = true;

  programs.seahorse.enable = true;

  environment.systemPackages = with pkgs; [
    libsecret
    inotify-tools
    brightnessctl
    dunst
  ];

  xdg.portal = {
    config = {
      hyprland.default = ["gtk" "hyprland"];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
}
