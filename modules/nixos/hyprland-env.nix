{pkgs, ...}: {
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable Hyprland.
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
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
