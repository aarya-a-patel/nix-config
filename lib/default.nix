{
  outputs,
  inputs,
}: rec {
  mapListToAttrs = f: arr: builtins.listToAttrs (map f arr);

  mkSystem = {
    machine,
    hostname,
    userhome,
    username,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs hostname username;};
      modules = [
        outputs.cachix
        inputs.stylix.nixosModules.stylix
        outputs.nixosModules.common
        machine
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            # useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";

            users.${username} = import userhome;

            extraSpecialArgs = {inherit inputs outputs username;};
          };
        }
        inputs.determinate.nixosModules.default
      ];
    };

  mkSystems =
    mapListToAttrs
    (system: {
      name = system.hostname;
      value = mkSystem system;
    });
}
