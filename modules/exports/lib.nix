{
  config,
  inputs,
  lib,
  ...
}: let
  flake = config.flake;
in {
  config.flake = {
    cachix = import ../../cachix.nix;
    nixosModules = flake.modules.nixos;
    homeModules = lib.filterAttrs (name: _: !(builtins.elem name ["aaryap" "wsl"])) flake.modules.homeManager;

    lib = {
      mkNixosConfiguration = {
        hostname,
        username,
        homeProfile,
        system ? "x86_64-linux",
        modules ? [],
        specialArgs ? {},
      }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs =
            {
              inherit inputs hostname username;
            }
            // specialArgs;
          modules =
            [
              flake.cachix
              inputs.stylix.nixosModules.stylix
              flake.modules.nixos.common
            ]
            ++ modules
            ++ [
              inputs.home-manager.nixosModules.home-manager
              {
                nix.settings.substituters = ["https://attic.xuyh0120.win/lantian"];
                nix.settings.trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];

                home-manager = {
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  users.${username} = flake.modules.homeManager.${homeProfile};
                  extraSpecialArgs = {
                    inherit inputs username;
                  };
                };
              }
              inputs.determinate.nixosModules.default
            ];
        };

      mkHomeConfiguration = {
        profile,
        system,
        modules ? [],
        extraSpecialArgs ? {},
      }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          extraSpecialArgs =
            {
              inherit inputs;
            }
            // extraSpecialArgs;
          modules =
            [
              inputs.stylix.homeModules.stylix
              flake.modules.homeManager.${profile}
            ]
            ++ modules;
        };
    };
  };
}
