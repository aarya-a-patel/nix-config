{inputs, ...}: {
  flake.wrappers.helix = {
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-wrapper-modules.wrapperModules.helix];

    package = lib.mkOverride 900 pkgs.helix;
    settings = lib.mkDefault {
      theme = "gruvbox_transparent";
      editor = {
        line-number = "relative";
        trim-trailing-whitespace = true;
      };
    };
    languages = lib.mkDefault {
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
    themes.gruvbox_transparent = lib.mkDefault {
      "inherits" = "gruvbox";
      "ui.background" = {};
    };
  };
}
