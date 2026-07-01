{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  config.flake.modules.homeManager.cosmic = {
    cosmicLib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.cosmic-manager.homeManagerModules.cosmic-manager
    ];

    wayland.desktopManager.cosmic = {
      enable = true;

      appearance = {
        theme.mode = "dark";

        toolkit = {
          apply_theme_global = false;
          header_size = cosmicLib.cosmic.mkRON "enum" "Compact";
          icon_theme = "Papirus-Dark";
          interface_density = cosmicLib.cosmic.mkRON "enum" "Compact";
          interface_font = {
            family = "Inter";
            stretch = cosmicLib.cosmic.mkRON "enum" "Normal";
            style = cosmicLib.cosmic.mkRON "enum" "Normal";
            weight = cosmicLib.cosmic.mkRON "enum" "Normal";
          };
          monospace_font = {
            family = "FiraCode Nerd Font Mono";
            stretch = cosmicLib.cosmic.mkRON "enum" "Normal";
            style = cosmicLib.cosmic.mkRON "enum" "Normal";
            weight = cosmicLib.cosmic.mkRON "enum" "Normal";
          };
        };
      };

      compositor = {
        autotile = true;
        workspaces = {
          workspace_layout = cosmicLib.cosmic.mkRON "enum" "Horizontal";
          workspace_mode = cosmicLib.cosmic.mkRON "enum" "OutputBound";
        };
        xkb_config = {
          rules = "";
          model = "pc104";
          layout = "us";
          variant = "";
          options = cosmicLib.cosmic.mkRON "optional" "terminate:ctrl_alt_bksp";
          repeat_delay = 600;
          repeat_rate = 25;
        };
      };
    };

    home.packages = with pkgs; [
      papirus-icon-theme
    ];
  };
}
