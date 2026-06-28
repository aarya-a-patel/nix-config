{config, ...}: {
  config.flake.modules.nixos.dm = {...}: {
    services.displayManager.cosmic-greeter.enable = true;
  };
}
