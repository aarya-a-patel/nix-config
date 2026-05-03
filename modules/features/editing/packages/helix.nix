{inputs, ...}: let
  wrappers = inputs.nix-wrapper-modules.wrappers;
in {
  config.perSystem = {pkgs, ...}: {
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
}
