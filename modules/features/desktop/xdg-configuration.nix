{config, ...}: {
  config.flake.modules.nixos.xdg = {
    pkgs,
    lib,
    ...
  }: {
    xdg.terminal-exec = {
      enable = true;
      settings.default = [
        "org.wezfurlong.wezterm.desktop"
      ];
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = ["gtk"];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    home-manager.sharedModules = [
      {
        xdg.portal.enable = lib.mkForce false;
      }
    ];
  };
}
