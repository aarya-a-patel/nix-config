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
  };

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    libsecret
    inotify-tools
    brightnessctl
    hypridle
    hyprlock
    rofi-wayland
    dunst
    # cliphist
    wl-clipboard-rs
  ];
}
