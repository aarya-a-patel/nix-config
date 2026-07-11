{inputs, ...}: {
  config = {
    flake.overlays.stable-packages = final: _prev: {
      stable = import inputs.nixpkgs-stable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };

    flake.overlays.cosmic-no-pop-gtk-theme = final: prev: {
      cosmic-settings-daemon = prev.cosmic-settings-daemon.override {
        pop-gtk-theme = final.runCommand "cosmic-pop-sounds-placeholder" {} ''
          mkdir -p "$out/share/sounds/Pop"
        '';
      };
    };
  };
}
