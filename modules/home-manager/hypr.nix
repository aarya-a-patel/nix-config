{
  config,
  pkgs,
  lib,
  ...
}: let
  mod = "SUPER";

  # Generate workspace binds (1-10)
  workspaceBinds = builtins.concatLists (builtins.genList (i: let
      n = toString (i + 1);
    in [
      "${mod}, ${n}, workspace, ${n}"
      "${mod} SHIFT, ${n}, movetoworkspace, ${n}"
    ])
    10);

  # Vim-style movement
  movementBinds = [
    "${mod}, H, movefocus, l"
    "${mod}, L, movefocus, r"
    "${mod}, K, movefocus, u"
    "${mod}, J, movefocus, d"

    "${mod} SHIFT, H, movewindow, l"
    "${mod} SHIFT, L, movewindow, r"
    "${mod} SHIFT, K, movewindow, u"
    "${mod} SHIFT, J, movewindow, d"

    "${mod} ALT, H, moveactive, -30 0"
    "${mod} ALT, L, moveactive, 30 0"
    "${mod} ALT, K, moveactive, 0 -30"
    "${mod} ALT, J, moveactive, 0 30"
  ];

  # Resize binds
  resizeBinds = [
    "${mod}, I, resizeactive, 10 0"
    "${mod} SHIFT, I, resizeactive, -10 0"
    "${mod}, O, resizeactive, 0 10"
    "${mod} SHIFT, O, resizeactive, 0 -10"
  ];

  # App launch + system controls
  appBinds = [
    "${mod}, SPACE, exec, rofi -show drun"
    "${mod}, T, exec, wezterm"
    "CTRL ALT, T, exec, wezterm"
    "${mod}, E, exec, dolphin"
    "${mod}, M, exit,"
    "${mod}, C, killactive,"
    "${mod}, F, togglefloating,"
    "${mod}, P, pseudo,"
    "${mod}, W, togglesplit,"
    "${mod}, S, togglespecialworkspace, magic"
    "${mod} SHIFT, S, movetoworkspace, special:magic"
  ];

  # Misc binds
  miscBinds = [
    "${mod}, mouse_down, workspace, e+1"
    "${mod}, mouse_up, workspace, e-1"
  ];
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      monitor = ",preferred,auto,1";
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
          scroll_factor = 0.3;
        };
        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
        allow_tearing = false;
        # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        # "col.inactive_border" = "rgba(595959aa)";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 2;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      gestures.workspace_swipe = "on";

      misc.force_default_wallpaper = "-1";

      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
      ];

      exec-once = [
        # "~/.config/waybar/waybar_auto_refresh.sh"
        "hypridle"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      bind = appBinds ++ workspaceBinds ++ movementBinds ++ resizeBinds ++ miscBinds;
      bindm = [
        "${mod}, mouse:272, movewindow"
        "${mod}, mouse:273, resizewindow"
      ];
      bindl = [",switch:Lid Switch,exec,hyprlock"];

      # Media keys
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  # Required apps
  home.packages = with pkgs; [
    wl-clipboard
    rofi
    cliphist
    hypridle
    hyprlock
    brightnessctl
    wireplumber
  ];

  programs.ashell = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
  };

  xdg = {
    enable = true;
    configFile."hypr/hypridle.conf" = {
      source = ./dotfiles/hypr/hypridle.conf;
      recursive = true;
    };
    configFile."hypr/hyprlock.conf" = {
      source = ./dotfiles/hypr/hyprlock.conf;
      recursive = true;
    };
    configFile."rofi" = {
      source = ./dotfiles/rofi;
      recursive = true;
    };
    configFile."waybar" = {
      source = ./dotfiles/waybar;
      recursive = true;
    };
  };
}
