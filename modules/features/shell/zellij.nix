{
  config,
  inputs,
  ...
}: let
  wrappers = inputs.nix-wrapper-modules.wrappers;
in {
  config = {
    perSystem = {pkgs, ...}: {
      packages.kitty = wrappers.kitty.wrap {
        inherit pkgs;
        package = pkgs.kitty;
        settings = {
          window_padding_width = 10;
          touch_scroll_multipler = 10.0;
        };
      };
    };

    flake.modules.homeManager.shell-zellij = {lib, ...}: {
      home.shellAliases = {
        zj = lib.mkDefault "zellij";
        zjh = lib.mkDefault "zellij --layout helix";
      };

      programs.zellij = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault false;
        enableZshIntegration = lib.mkDefault false;
        attachExistingSession = lib.mkDefault false;
        exitShellOnExit = lib.mkDefault false;

        settings = lib.mkDefault {
          default_mode = "locked";
          scrollback_editor = "hx";
          pane_frames = true;
          mouse_mode = true;
          copy_clipboard = "system";
          show_startup_tips = false;
          web_server = false;
          web_sharing = "disabled";
        };

        layouts.helix = lib.mkDefault ''
          layout {
              default_tab_template {
                  pane size=1 borderless=true {
                      plugin location="zellij:tab-bar"
                  }
                  children
                  pane size=2 borderless=true {
                      plugin location="zellij:status-bar"
                  }
              }

              tab name="helix" focus=true {
                  pane split_direction="vertical" {
                      pane command="hx" size="70%" focus=true {
                          args "."
                      }
                      pane name="shell"
                  }
              }
          }
        '';
      };
    };
  };
}
