{config, ...}: {
  config.repo.nixosModules.dm = {...}: {
    services.displayManager.cosmic-greeter.enable = true;
  };
}
