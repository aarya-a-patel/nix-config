{config, ...}: {
  config.flake.modules.nixos.facial-recognition = {...}: {
    services.howdy = {
      enable = true;
      control = "sufficient";
    };
    services.linux-enable-ir-emitter.enable = true;
  };
}
