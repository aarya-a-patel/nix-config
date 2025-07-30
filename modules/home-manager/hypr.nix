{pkgs, ...}: let
  hyprland-target = "wayland-wm@Hyprland.service"; # "wayland-session@Hyprland.target";
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
    "${mod}, Q, killactive,"
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
    "${mod}, L, exec, loginctl lock-session"
  ];
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;

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

      # exec-once = [
      #   # "~/.config/waybar/waybar_auto_refresh.sh"
      #   "uwsm app -- wl-paste --type text --watch cliphist store"
      #   "uwsm app -- wl-paste --type image --watch cliphist store"
      #   "systemctl --user start hyprpolkitagent"
      # ];

      bind = appBinds ++ workspaceBinds ++ movementBinds ++ resizeBinds ++ miscBinds;
      bindm = [
        "${mod}, mouse:272, movewindow"
        "${mod}, mouse:273, resizewindow"
      ];
      bindl = [",switch:Lid Switch,exec,loginctl lock-session"];

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

  services.hyprpolkitagent.enable = true;

  services.hypridle = {
    enable = true;
    systemdTarget = hyprland-target;
    settings = {
      general = {
        lock_cmd = "hyprctl dispatch exec hyprlock";
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r"; # monitor backlight restor.
        }

        # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
        #listener = {
        #    timeout = 150;                                          # 2.5min.
        #    on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
        #    on-resume = "brightnessctl -rd rgb:kbd_backlight";        # turn on keyboard backlight.
        #};

        {
          timeout = 300; # 5min
          on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
        }

        {
          timeout = 330; # 5.5min
          on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        }

        {
          timeout = 600; # 10min
          on-timeout = "systemctl suspend"; # suspend pc
        }
      ];
    };
  };

  # Required apps
  home.packages = with pkgs; [
    wl-clipboard-rs
    rofi-wayland
    cliphist
    brightnessctl
    wireplumber
    networkmanagerapplet
  ];

  programs.ashell = {
    enable = true;
    systemd = {
      enable = true;
      target = hyprland-target;
    };
    settings = {
      appearance = {
        font_name = "JetbrainsMono Nerd Font Propo";
        style = "Solid";
      };
    };
  };

  /*
  programs.quickshell = {
    enable = true;
    systemd = {
      enable = true;
      target = hyprland-target;
    };
  };
  */

  programs.hyprlock = {
    enable = true;
    settings = {
      background = {
        monitor = "";
        # path = /home/me/someImage.png   # only png supported for now

        # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
        blur_passes = 1; # 0 disables blurring
        blur_size = 7;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      input-field = {
        monitor = "";
        size = "200, 50";
        outline_thickness = 3;
        dots_size = 0.33; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = false;
        dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
        # outer_color = "rgb(151515)";
        # inner_color = "rgb(200, 200, 200)";
        fade_on_empty = true;
        fade_timeout = 1000; # Milliseconds before fade_on_empty is triggered.
        placeholder_text = "<i>Input Password...</i>"; # Text rendered in the input box when it's empty.
        hide_input = false;
        rounding = -1; # -1 means complete rounding (circle/oval)
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>"; # can be set to empty
        fail_transition = 300; # transition time in ms between normal outer_color and fail_color
        capslock_color = -1;
        numlock_color = -1;
        bothlock_color = -1; # when both locks are active. -1 means don't change outer color (same for above)
        invert_numlock = false; # change color if numlock is off
        swap_font_color = false; # see below

        position = "0, -20";
        halign = "center";
        valign = "center";
      };
    };
  };

  xdg = {
    enable = true;
    configFile."rofi" = {
      source = ./dotfiles/rofi;
      recursive = true;
    };
    /*
    configFile."waybar" = {
      source = ./dotfiles/waybar;
      recursive = true;
    };
    */
  };
}
