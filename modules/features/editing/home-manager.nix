{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
  wrappers = inputs.nix-wrapper-modules.wrappers;
in {
  config = {
    perSystem = {pkgs, ...}: {
      packages.helix = wrappers.helix.wrap {
        inherit pkgs;
        package = pkgs.helix;
        settings = {
          theme = "gruvbox_transparent";
          editor = {
            line-number = "relative";
            trim-trailing-whitespace = true;
          };
        };
        languages = {
          language-server = {
            nixd.command = "${pkgs.nixd}/bin/nixd";
            tinymist = {
              command = "${pkgs.tinymist}/bin/tinymist";
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
              formatter.command = "${pkgs.alejandra}/bin/alejandra";
              language-servers = ["nixd"];
            }
            {
              name = "typst";
              auto-format = true;
              formatter = {
                command = "${pkgs.typstyle}/bin/typstyle";
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
    };

    flake.modules.homeManager.nvim = {pkgs, ...}: {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [
          lua-language-server
          rust-analyzer
          nixd
          tree-sitter
          clang-tools
          texlab
          clang
        ];
      };

      home.packages = with pkgs; [
        inputs.bacon-ls.defaultPackage.${pkgs.stdenv.hostPlatform.system}
        bacon
        stable.tectonic
        typst
      ];

      programs.zathura = {
        enable = true;
        extraConfig = builtins.readFile (builtins.fetchurl {
          url = "https://raw.githubusercontent.com/dracula/zathura/master/zathurarc";
          sha256 = "03r5gbfp3m4hlzba61lgk0z95avjjlb9h8jb1nacv44aqcr04s84";
        });
      };

      xdg = {
        enable = true;
        configFile."nvim" = {
          source = ../../_assets/nvim/nvim;
          recursive = true;
        };
      };
    };
  };
}
