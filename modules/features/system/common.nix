{
  config,
  inputs,
  lib,
  ...
}: let
  flake = config.flake;
in {
  config.flake.modules.nixos.common = {
    config,
    lib,
    pkgs,
    ...
  }: let
    packages = flake.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports =
      (with flake.modules.nixos; [
        bluetooth
        dm
        cosmic
        hyprland-env
        shell
        neovim
        display
        networking
        network-services
        audio
        boot
        localization
      ])
      ++ [
        inputs.nix-gaming.nixosModules.platformOptimizations
      ];

    nixpkgs = {
      overlays = [
        flake.overlays.stable-packages
      ];
      config.allowUnfree = true;
    };

    nix = let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in {
      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        download-buffer-size = 500000000;
        trusted-users = [
          "root"
          "@wheel"
          "aaryap"
        ];
        nix-path = config.nix.nixPath;
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      channel.enable = false;
      registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    hardware.enableAllFirmware = true;
    services.fwupd.enable = true;

    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = ["-L"];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.droid-sans-mono
    ];

    programs.steam = {
      enable = true;
      platformOptimizations.enable = true;
    };

    hardware.system76.enableAll = true;
    hardware.system76.power-daemon.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = lib.mkForce true;

    security.polkit.enable = true;

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
    virtualisation.containers.registries.search = ["docker.io"];
    virtualisation.containerd.enable = true;
    virtualisation.waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };

    environment.systemPackages = with pkgs; [
      gcc
      cachix
      gparted
      nerdctl
      podman-compose
      packages.nydus-bundle
      mission-center
      firmware-updater
      usbutils
      pciutils
      (lib.hiPrio uutils-coreutils-noprefix)
    ];

    services.earlyoom.enable = true;
    zramSwap.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;

    programs.nix-ld.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      opacity = {
        applications = 0.8;
        terminal = 0.8;
        desktop = 0.8;
      };
      polarity = "dark";
      targets.plymouth.enable = false;
      fonts = {
        sansSerif = {
          name = "Inter";
          package = pkgs.inter;
        };
        monospace = {
          name = "FiraCode Nerd Font Mono";
          package = pkgs.nerd-fonts.fira-code;
        };
      };
    };

    users.users.aaryap = {
      initialPassword = "";
      isNormalUser = true;
      description = "Aarya Patel";
      extraGroups = ["wheel" "docker" "dialout" "libvirtd"];
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="aaryap", MODE:="0660"
      KERNEL=="event*", GROUP="aaryap", NAME="input/%k", MODE:="0660"
    '';

    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
