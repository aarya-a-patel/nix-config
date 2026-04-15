{
  config,
  inputs,
  lib,
  ...
}: let
  wrappers = inputs.nix-wrapper-modules.wrappers;
  overlays = {
    additions = final: _prev: lib.mapAttrs (_: builder: builder final) config.repo.packageBuilders;

    modifications = final: prev: {
    };

    stable-packages = final: _prev: {
      stable = import inputs.nixpkgs-stable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };

    zen-browser-package = _final: prev: {
      zen-browser = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system};
    };

    bacon-ls-package = _final: prev: {
      bacon-ls = inputs.bacon-ls.defaultPackage.${prev.stdenv.hostPlatform.system};
    };

    wrapper-programs = final: prev: {
      wezterm = wrappers.wezterm.wrap {
        pkgs = final;
        package = prev.wezterm;
        "wezterm.lua".content = builtins.readFile ../_assets/wezterm/wezterm.lua;
      };

      kitty = wrappers.kitty.wrap {
        pkgs = final;
        package = prev.kitty;
        settings = {
          window_padding_width = 10;
          touch_scroll_multipler = 10.0;
        };
      };

      helix = wrappers.helix.wrap {
        pkgs = final;
        package = prev.helix;
        settings = {
          theme = "gruvbox_transparent";
          editor = {
            line-number = "relative";
            trim-trailing-whitespace = true;
          };
        };
        languages = {
          language-server = {
            nixd.command = "${final.nixd}/bin/nixd";
            tinymist = {
              command = "${final.tinymist}/bin/tinymist";
              config = {
                exportPdf = "onType";
                preview.background = {
                  enabled = true;
                  args = [
                    "--data-plane-host=127.0.0.1:0"
                    "--invert-colors=never"
                    "--open"
                  ];
                };
              };
            };
          };
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = "${final.alejandra}/bin/alejandra";
              language-servers = ["nixd"];
            }
            {
              name = "typst";
              auto-format = true;
              formatter = {
                command = "${final.typstyle}/bin/typstyle";
                args = ["--wrap-text"];
              };
            }
          ];
        };
        themes.gruvbox_transparent = {
          "inherits" = "gruvbox";
          "ui.background" = {};
        };
      };

      btop = wrappers.btop.wrap {
        pkgs = final;
        package = prev.btop;
        settings.vim_mode = true;
      };

      btop-cuda = wrappers.btop.wrap {
        pkgs = final;
        package = prev.btop-cuda;
        settings.vim_mode = true;
      };
    };
  };
in {
  config = {
    flake.overlays = overlays;
    repo.overlays = overlays;
  };
}
