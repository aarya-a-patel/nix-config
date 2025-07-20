{pkgs, ...}: {
  imports = [
    ./xdg-configuration.nix
  ];

  # Enable Hyprland.
  programs = {
    hyprland = {
      enable = true;
      # xwayland.enable = true;
    };
    waybar.enable = true;
  };

  environment.systemPackages = with pkgs; [
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
