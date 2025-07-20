{pkgs, ...}: let
  model = "m433ia";
in {
  # i2c for https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver
  hardware.i2c.enable = true;
  systemd.services.asus-touchpad-numpad = {
    description = "Activate Numpad inside the touchpad with top right corner switch";
    documentation = ["https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver"];
    path = [pkgs.i2c-tools];
    script = ''
      cd ${pkgs.fetchFromGitHub {
        owner = "mohamed-badaoui";
        repo = "asus-touchpad-numpad-driver";
        # These needs to be updated from time to time
        rev = "bfbd282025e1aeb2c805a881e01089fe55442e7f";
        sha256 = "sha256-NkJ2xF4111fXDUPGRUvIVXyyFmJOrlSq0u6jJUJFYes=";
      }}
      # In the last argument here you choose your layout.
      ${pkgs.python3.withPackages (ps: [ps.libevdev])}/bin/python asus_touchpad.py ${model}
    '';
    # Probably needed because it fails on boot seemingly because the driver
    # is not ready yet. Alternativly, you can use `sleep 3` or similar in the
    # `script`.
    serviceConfig = {
      RestartSec = "1s";
      Restart = "on-failure";
    };
    wantedBy = ["multi-user.target"];
  };
}
