{config, ...}: let
  module = {...}: {
    security.rtkit.enable = true;
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
        extraConfig = {
          pipewire."92-screen-share-stability" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.quantum" = 1024;
              "default.clock.min-quantum" = 512;
              "default.clock.max-quantum" = 2048;
              "default.clock.allowed-rates" = [48000];
            };
          };
        };
      };
    };
  };
in {
  config.flake.modules.nixos.audio = module;
}
