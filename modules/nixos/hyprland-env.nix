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

  security.pam.services.hyprlock = {};

  services.gnome.gnome-keyring.enable = true;
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    libsecret
    inotify-tools
    brightnessctl
    dunst
  ];
}
