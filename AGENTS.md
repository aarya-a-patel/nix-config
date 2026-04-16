# Repository Guidelines

## Project Structure & Module Organization
This repository is a flake-based NixOS and Home Manager configuration. `flake.nix` wires the repo together and imports `modules/`. Host definitions live in `modules/hosts/` and hardware-specific files live under `machines/`. Reusable system and user modules are grouped in `modules/features/` by area such as `desktop/`, `network/`, `shell/`, and `system/`. Home profiles live in `modules/profiles/`. Custom derivations are defined in `modules/packages/`. Static assets for tools like Neovim, Waybar, and WezTerm are kept in `modules/_assets/`.

## Build, Test, and Development Commands
Use the flake entry points directly:

- `nix fmt` formats the repo with `alejandra`.
- `nix build .#nixosConfigurations.aap-zenbook.config.system.build.toplevel` evaluates and builds the Zenbook system.
- `nix build .#nixosConfigurations.aap-nix-desktop.config.system.build.toplevel` evaluates and builds the desktop system.
- `nix build .#homeConfigurations.aaryap@nixos.activationPackage` builds the main standalone Home Manager profile.
- `nix build .#apply-pilot` builds one exported package; swap in `mouseless-click`, `nydus`, or `nydus-snapshotter` as needed.
- `sudo nixos-rebuild switch --flake .#aap-zenbook` applies a host configuration locally when you are ready to switch.

## Coding Style & Naming Conventions
Keep Nix files formatted with `alejandra`; run `nix fmt` before committing. Follow the existing style: two-space indentation, trailing semicolons, lowercase kebab-case filenames such as `nvidia-gpu.nix`, and concise attribute names grouped by concern. Prefer adding shared logic under `modules/features/` or `modules/packages/` instead of duplicating host-specific configuration.

## Testing Guidelines
There is no separate unit test suite here; validation is build-based. For any change, build the affected target first: host rebuilds for `modules/hosts/` or `machines/`, standalone Home Manager builds for `modules/profiles/`, and package builds for `modules/packages/`. Changes should evaluate cleanly before a switch.

## Commit & Pull Request Guidelines
Recent history uses short, imperative commit messages such as `Add ollama to laptop`, `flake update`, and `Initial refactor`. Keep commits focused and use the same style. Pull requests should state which host, profile, or package changed, list the commands you ran to validate it, and note any manual post-switch checks. Include screenshots only for visible desktop or theming changes.

## Security & Configuration Tips
Do not commit secrets, machine-specific tokens, or private keys. Keep hardware-specific changes isolated to `machines/` or the matching host module, and avoid broad edits to shared modules unless the change is intentionally cross-host.
