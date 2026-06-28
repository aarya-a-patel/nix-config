{config, ...}: let
  package = pkgs:
    pkgs.callPackage (
      {
        appimageTools,
        fetchurl,
      }:
        appimageTools.wrapType2 {
          pname = "mouseless-click";
          version = "0.4.3";

          src = fetchurl {
            url = "https://github.com/croian/mouseless/releases/download/v0.4.3/Mouseless_v0.4.3_arch-20251019.0.436919_x86_64.AppImage";
            hash = "sha256-1CaVEEoHJ9MQLikyL+ClVuv2wlBZZXmrF7zkBU6V23c=";
          };
        }
    ) {};
in {
  config.perSystem = {pkgs, ...}: {
    packages.mouseless-click = package pkgs;
  };
}
