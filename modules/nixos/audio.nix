{...}: {
  # Enable sound with pipewire.
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
            # Give screen capture and browser audio a little more scheduling
            # headroom to reduce underruns during screen sharing.
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 2048;
            "default.clock.allowed-rates" = [48000];
          };
        };
      };
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
