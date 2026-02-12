{
  description = "Aarya's Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    # Also see the 'stable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:NixOS/nixos-hardware/master";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    bacon-ls = {
      url = "github:crisidev/bacon-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Determinate Nix
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaperengine = {
      url = "github:aarya-a-patel/simple-linux-wallpaperengine-gui/config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;
    lib = import ./lib {inherit inputs outputs;};
    cachix = import ./cachix.nix;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = outputs.lib.mkSystems [
      {
        hostname = "aap-zenbook";
        username = "aaryap";
        machine = ./machines/asus-zenbook;
        userhome = ./home-manager/home.nix;
      }
      {
        hostname = "aap-nix-desktop";
        username = "aaryap";
        machine = ./machines/desktop;
        userhome = ./home-manager/home.nix;
      }
    ];

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "aaryap@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
          username = "aaryap";
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
        ];
      };
      "aarya@AAP-Desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
          username = "aarya";
        };
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/wsl-home.nix
        ];
      };
    };
  };
}
