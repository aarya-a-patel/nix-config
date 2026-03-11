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
          nix.settings.substituters = ["https://attic.xuyh0120.win/lantian"];
          nix.settings.trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];

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
