{pkgs, ...}: {
  # Default terminal
  xdg.terminal-exec = {
    enable = true;
    settings.default = [
      "org.wezfurlong.wezterm.desktop"
    ];
  };

  # Screen Sharing
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = ["gtk"];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
