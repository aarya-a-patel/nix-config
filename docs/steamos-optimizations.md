# SteamOS-Style Optimizations

This repo applies the portable parts of SteamOS' gaming stack without turning
the machine into a console appliance.

Implemented:

- Steam platform optimizations from `nix-gaming`.
- Gamescope and GameMode for per-game compositor and scheduler policy.
- NTSYNC module loading on kernels new enough to provide it.
- Explicit 32-bit graphics support for Steam and Proton.
- zram, earlyoom, low-swappiness VM tuning, and weekly SSD trim.
- Steam launch wrappers for common Gamescope modes:
  - `steam-gamescope-fsr`
  - `steam-gamescope-1080p`
  - `steam-gamescope-native`
  - `steam-gamescope-debug`
  - `steam-bigpicture-gamescope`
- `steamos-optimization-report` for post-switch validation.

Intentionally conservative:

- Steam Gamescope session is available behind
  `aaryap.steamosOptimizations.gameModeSession`, but is disabled by default.
  The NVIDIA desktop force-disables it because embedded DRM Gamescope sessions
  show artifacts and `gamescope-wl` crashes there.
- Use `steam-bigpicture-gamescope` from COSMIC or Hyprland when a Steam
  Big Picture style shell is desired without giving Gamescope the whole KMS
  display path. It detects the current desktop resolution and refresh rate via
  `xrandr`; override with `GAMESCOPE_WIDTH`, `GAMESCOPE_HEIGHT`, and
  `GAMESCOPE_REFRESH` if needed.
- `scx_lavd` is behind
  `aaryap.steamosOptimizations.experimentalLavdScheduler`; Valve lists LAVD as
  beta SteamOS functionality, so the default scheduler remains unchanged.
- Deck-specific firmware, display calibration, immutable root updates, and
  handheld TDP controls are not copied to desktop or laptop hosts.

Validation after switching:

```sh
steamos-optimization-report
```

For Steam launch options, use a wrapper before `%command%`, for example:

```sh
steam-gamescope-debug %command%
```
