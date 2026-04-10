{pkgs, ...}: {
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.hfphsp-backend"] = "native",
        # Avoid legacy HSP fallback while keeping HFP headset mic support.
        ["bluez5.headset-roles"] = "[ hfp_hf hfp_ag ]"
      }
    '')
  ];
  services.ofono.enable = false;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };
  services.blueman.enable = true;
}
