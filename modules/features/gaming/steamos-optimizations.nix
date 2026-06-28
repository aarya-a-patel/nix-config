{
  config,
  lib,
  ...
}: {
  config.flake.modules.nixos.steamos-optimizations = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.aaryap.steamosOptimizations;
    kernelHasNtsync = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";

    gamescopeFsr = pkgs.writeShellApplication {
      name = "steam-gamescope-fsr";
      runtimeInputs = [pkgs.gamescope];
      text = ''
        exec gamescope -f -h 720 -H 1080 -F fsr -- "$@"
      '';
    };

    gamescope1080p = pkgs.writeShellApplication {
      name = "steam-gamescope-1080p";
      runtimeInputs = [pkgs.gamescope];
      text = ''
        exec gamescope -f -w 1920 -h 1080 -W 1920 -H 1080 -- "$@"
      '';
    };

    gamescopeNative = pkgs.writeShellApplication {
      name = "steam-gamescope-native";
      runtimeInputs = [pkgs.gamescope];
      text = ''
        exec gamescope -f --adaptive-sync -- "$@"
      '';
    };

    gamescopeDebug = pkgs.writeShellApplication {
      name = "steam-gamescope-debug";
      runtimeInputs = [
        pkgs.gamescope
        pkgs.mangohud
      ];
      text = ''
        exec mangohud gamescope -f -- "$@"
      '';
    };

    steamBigPictureGamescope = pkgs.writeShellApplication {
      name = "steam-bigpicture-gamescope";
      runtimeInputs = [
        pkgs.gawk
        pkgs.gamescope
        pkgs.steam
        pkgs.xrandr
      ];
      text = ''
        width="''${GAMESCOPE_WIDTH:-}"
        height="''${GAMESCOPE_HEIGHT:-}"
        refresh="''${GAMESCOPE_REFRESH:-}"

        if [ -z "$width" ] || [ -z "$height" ]; then
          read -r detected_width detected_height < <(
            xrandr --current 2>/dev/null |
              awk '/current/ {
                for (i = 1; i <= NF; i++) {
                  if ($i == "current") {
                    gsub(",", "", $(i + 3))
                    print $(i + 1), $(i + 3)
                    exit
                  }
                }
              }'
          )
          width="''${width:-''${detected_width:-1920}}"
          height="''${height:-''${detected_height:-1080}}"
        fi

        if [ -z "$refresh" ]; then
          refresh="$(
            xrandr --current 2>/dev/null |
              awk '/\*/ { gsub(/[*+]/, "", $2); print $2; exit }'
          )"
          refresh="''${refresh:-60}"
        fi

        exec gamescope \
          -f \
          -W "$width" \
          -H "$height" \
          -w "$width" \
          -h "$height" \
          -r "$refresh" \
          --disable-layers \
          --force-composition \
          -- steam -tenfoot -pipewire-dmabuf "$@"
      '';
    };

    optimizationReport = pkgs.writeShellApplication {
      name = "steamos-optimization-report";
      runtimeInputs = with pkgs; [
        coreutils
        gnugrep
        kmod
        pciutils
        procps
        util-linux
      ];
      text = ''
        section() {
          printf '\n== %s ==\n' "$1"
        }

        section "Kernel"
        uname -a
        printf 'Kernel package: %s\n' "${config.boot.kernelPackages.kernel.version}"
        printf 'Command line: '
        cat /proc/cmdline
        printf 'Scheduler: '
        cat /sys/kernel/sched_ext/state 2>/dev/null || printf 'sched_ext unavailable\n'

        section "NTSYNC"
        if [ -e /dev/ntsync ]; then
          ls -l /dev/ntsync
        else
          printf '/dev/ntsync is not present\n'
        fi
        lsmod | grep '^ntsync' || true

        section "Graphics"
        lspci -nnk | grep -EA3 'VGA|3D|Display' || true
        if command -v vulkaninfo >/dev/null 2>&1; then
          vulkaninfo --summary 2>/dev/null || true
        fi

        section "Gamescope and Steam"
        if command -v gamescope >/dev/null 2>&1; then
          gamescope --version 2>&1 || true
        fi
        if command -v gamemoded >/dev/null 2>&1; then
          gamemoded --version 2>&1 || true
        fi

        section "Memory"
        free -h
        swapon --show || true
        zramctl || true
        sysctl vm.swappiness vm.vfs_cache_pressure vm.max_map_count kernel.split_lock_mitigate 2>/dev/null || true

        section "Power"
        if command -v powerprofilesctl >/dev/null 2>&1; then
          powerprofilesctl get 2>/dev/null || true
        fi

        section "Recent GPU and Session Errors"
        journalctl -b -p warning --no-pager 2>/dev/null | grep -Ei 'amdgpu|nvidia|gamescope|gpu|drm|kwin|cosmic|hyprland' | tail -n 80 || true
      '';
    };
  in {
    options.aaryap.steamosOptimizations = {
      enable = lib.mkEnableOption "portable SteamOS-style gaming optimizations" // {default = true;};

      gameModeSession = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable a selectable Steam Gamescope session in the display manager.";
      };

      experimentalLavdScheduler = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the experimental scx_lavd scheduler.";
      };

      enableDiagnostics = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install SteamOS-style gaming diagnostics.";
      };
    };

    config = lib.mkIf cfg.enable {
      boot = {
        kernelModules = lib.optional kernelHasNtsync "ntsync";
        kernelParams = lib.mkIf config.hardware.nvidia.modesetting.enable [
          "nvidia-drm.modeset=1"
        ];
      };

      services.udev.extraRules = lib.optionalString kernelHasNtsync ''
        KERNEL=="ntsync", MODE:="0666"
      '';

      programs = {
        gamescope.enable = true;

        gamemode = {
          enable = true;
          settings.general = {
            desiredgov = "performance";
            defaultgov = "schedutil";
            renice = 10;
            ioprio = 0;
            inhibit_screensaver = 1;
          };
        };

        steam = {
          platformOptimizations.enable = true;
          gamescopeSession = {
            enable = cfg.gameModeSession;
            args = [
              "--disable-layers"
              "--force-composition"
            ];
          };
        };
      };

      services.scx = lib.mkIf cfg.experimentalLavdScheduler {
        enable = true;
        scheduler = "scx_lavd";
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 100;
      };

      services = {
        earlyoom.enable = true;
        fstrim.enable = true;
      };

      security.pam.loginLimits = [
        {
          domain = "@users";
          type = "-";
          item = "nofile";
          value = 1048576;
        }
      ];

      environment.systemPackages =
        [
          pkgs.gamescope
          pkgs.gamemode
          pkgs.mangohud
          pkgs.vulkan-tools
          pkgs.mesa-demos
          pkgs.libva-utils
          pkgs.protonup-qt
          gamescopeFsr
          gamescope1080p
          gamescopeNative
          gamescopeDebug
          steamBigPictureGamescope
        ]
        ++ lib.optional cfg.enableDiagnostics optimizationReport;
    };
  };
}
