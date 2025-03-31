{ ... }:

{
  services.displayManager.defaultSession = "plasma";
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "doom";
  };
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.xserver.displayManager.gdm = {
  #   enable = true;
  #   wayland = true;
  # };
}

