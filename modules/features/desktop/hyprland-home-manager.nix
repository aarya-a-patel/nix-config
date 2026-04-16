{config, ...}: {
  config.flake.modules.homeManager.hyprland = {pkgs, ...}: let
    mod = "SUPER";
    hyprland-target = "wayland-wm@hyprland.desktop.service";

    workspaceBinds = builtins.concatLists (builtins.genList (i: let
        n = toString (i + 1);
      in [
        "${mod}, ${n}, workspace, ${n}"
        "${mod} SHIFT, ${n}, movetoworkspace, ${n}"
      ])
      9);

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

    resizeBinds = [
      "${mod}, I, resizeactive, 10 0"
      "${mod} SHIFT, I, resizeactive, -10 0"
      "${mod}, O, resizeactive, 0 10"
      "${mod} SHIFT, O, resizeactive, 0 -10"
    ];

    appBinds = [
      "${mod}, SPACE, exec, fuzzel"
      "${mod}, T, exec, wezterm"
      "CTRL ALT, T, exec, wezterm"
      "${mod}, E, exec, dolphin"
      "${mod}, M, exit,"
      "${mod}, Q, killactive,"
      "${mod}, F, togglefloating,"
      "${mod}, P, pseudo,"
      "${mod}, W, togglesplit,"
      "${mod}, U, togglespecialworkspace, magic"
      "${mod} SHIFT, U, movetoworkspace, special:magic"
      ", PRINT, exec, hyprshot -m output"
      "${mod}, PRINT, exec, hyprshot -m window"
      "${mod} SHIFT, S, exec, hyprshot -m region"
    ];

    miscBinds = [
      "${mod}, mouse_down, workspace, e+1"
      "${mod}, mouse_up, workspace, e-1"
      "${mod}, ESCAPE, exec, loginctl lock-session"
    ];
  in {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
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
        gesture = [
          "3, horizontal, workspace"
        ];
        misc.force_default_wallpaper = "0";
        device = [
          {
            name = "epic-mouse-v1";
            sensitivity = -0.5;
          }
        ];
        bind = appBinds ++ workspaceBinds ++ movementBinds ++ resizeBinds ++ miscBinds;
        bindm = [
          "${mod}, mouse:272, movewindow"
          "${mod}, mouse:273, resizewindow"
        ];
        bindl = [",switch:Lid Switch,exec,loginctl lock-session"];
        bindle = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];
      };
    };

    services.hypridle = {
      enable = true;
      systemdTarget = hyprland-target;
      settings = {
        general = {
          lock_cmd = "hyprctl dispatch exec hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

    home.packages = with pkgs; [
      wl-clipboard-rs
      cliphist
      brightnessctl
      wireplumber
      hyprshot
    ];

    programs.fuzzel.enable = true;

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
        modules = {
          left = ["Workspaces"];
          center = ["WindowTitle"];
          right = [["Tray" "Clock" "Privacy" "Settings"]];
        };
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        background = {
          monitor = "";
          blur_passes = 1;
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
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = false;
          dots_rounding = -1;
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Input Password...</i>";
          hide_input = false;
          rounding = -1;
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color = -1;
          invert_numlock = false;
          swap_font_color = false;
          position = "0, -20";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
