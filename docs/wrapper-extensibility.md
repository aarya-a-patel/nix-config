# Extending wrapped packages downstream

This flake exports reusable `nix-wrapper-modules` configurations so downstream
flakes can customize a package without copying its configuration. This guide is
for agents modifying flakes that consume this repository.

## Available interfaces

The following names are exported under both `wrapperModules` and `packages`:

- `neovim`
- `helix`
- `kitty`
- `btop`
- `btop-cuda`

Use `wrapperModules.<name>` when defining another wrapper module. This is the
preferred interface for a downstream flake because composition happens before
the package is built. Use `packages.<system>.<name>.wrap` for a local package
customization or when module outputs are unnecessary.

Both interfaces preserve the `nix-wrapper-modules` module system. Generated
packages retain `.wrap`, `.apply`, and `.eval`, including after another `.wrap`
call.

## Compose a downstream wrapper module

Make the downstream flake and this flake use the same `nixpkgs` and
`nix-wrapper-modules` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-wrapper-modules = {
      url = "github:birdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-config = {
      url = "github:aarya-a-patel/nix-config";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-wrapper-modules.follows = "nix-wrapper-modules";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.nix-wrapper-modules.flakeModules.wrappers];
      systems = ["x86_64-linux"];

      flake.wrappers.custom-neovim = {
        lib,
        pkgs,
        ...
      }: {
        imports = [inputs.nix-config.wrapperModules.neovim];

        settings.aliases = ["nvim"];
        runtimePkgs = [pkgs.nil];

        # Apply the priority to the whole option to retain the base specs.
        specs = lib.mkDefault {
          sensible = pkgs.vimPlugins.vim-sensible;
        };
      };
    };
}
```

The flake-parts integration builds this as
`packages.<system>.custom-neovim` and exports it again as
`wrapperModules.custom-neovim`.

The imported wrapper provides defaults, not immutable policy. Ordinary
downstream values override `lib.mkDefault` configuration. Explicit package
choices in this flake use `lib.mkOverride 900`, so an ordinary downstream
`package = ...` also wins.

## Extend an existing package

For a package-only result, call `.wrap` on the exported package:

```nix
perSystem = {
  inputs',
  pkgs,
  ...
}: let
  base = inputs'.nix-config.packages.neovim;
  withTools = base.wrap {
    runtimePkgs = [pkgs.nil];
  };
in {
  packages.custom-neovim = withTools.wrap ({lib, ...}: {
    settings.aliases = ["nvim"];
    specs = lib.mkDefault {
      sensible = pkgs.vimPlugins.vim-sensible;
    };
  });
};
```

Each call re-evaluates the accumulated modules and returns another extensible
package. Do not use `overrideAttrs` for wrapper configuration; it operates on
the resulting derivation rather than the wrapper module options.

## Merge and priority rules

- `runtimePkgs` uses normal list merging, so downstream lists append.
- Settings and other producer preferences generally use `lib.mkDefault`;
  ordinary downstream definitions override them.
- Neovim `specs` is defaulted as one attribute set. To add specs while retaining
  the producer's specs, write `specs = lib.mkDefault { ... };` exactly. Writing
  only `specs.newPlugin = ...;` at normal priority replaces the defaulted set.
- Use `lib.mkForce` only when a conflicting non-default definition cannot be
  resolved through normal priorities.
- Set `package` normally in downstream modules. It overrides this flake's
  priority-900 package selection without `mkForce`.

After changing a downstream wrapper, build the generated package and verify any
configuration whose merge behavior matters through the package's
`configuration` passthru.
