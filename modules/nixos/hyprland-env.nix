{
  pkgs,
  outputs,
  username,
  ...
}: {
  imports = [
    ./xdg-configuration.nix
  ];

  home-manager.users.${username} = {
    imports = [
      (outputs.homeManagerModules.hyprland "wayland-wm@hyprland.desktop.service")
    ];
  };

  # Setup UWSM options
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.systemd.enable = false;
    }
  ];

  # Enable Hyprland.
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true; # automatically enables UWSM
    };
    # waybar.enable = true;
    # hyprlock.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    dbus.enable = true;
    gvfs.enable = true;
  };

  security.pam.services.hyprlock = {
    enableGnomeKeyring = true;
  };
  security.pam.services.ashell.enableGnomeKeyring = true;

  programs.seahorse.enable = true;

  environment.systemPackages = with pkgs; [
    libsecret
    inotify-tools
    brightnessctl
    dunst
  ];

  # xdg.portal = {
  #   config = {
  #     hyprland.default = ["gtk" "hyprland"];
  #   };
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-hyprland
  #   ];
  # };
}
