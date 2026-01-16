# mouseless.nix
{
  pkgs,
  fetchurl,
  ...
}:
pkgs.appimageTools.wrapType2 {
  pname = "mouseless-click";
  version = "0.4.3";

  src = fetchurl {
    url = "https://github.com/croian/mouseless/releases/download/v0.4.3/Mouseless_v0.4.3_arch-20251019.0.436919_x86_64.AppImage";
    hash = "sha256-1CaVEEoHJ9MQLikyL+ClVuv2wlBZZXmrF7zkBU6V23c=";
  };

  # Optional: Customize desktop file and icon if needed
  # makeDesktopItem = true;
  # desktopItem = pkgs.makeDesktopItem {
  #   name = "My AppImage";
  #   exec = "my-appimage"; # Name of the executable within the AppImage
  #   icon = "my-appimage-icon"; # Name of the icon file within the AppImage
  #   comment = "A description of My AppImage";
  #   categories = [ "Utility" ];
  # };
}
