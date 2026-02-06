# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports =
    (with outputs.nixosModules; [
      # If you want to use modules your own flake exports (from modules/nixos):
      asus-touch-numpad-driver
      bluetooth
      dm
      cosmic
      hyprland-env
      # outputs.nixosModules.gnome
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
      # Or modules from other flakes (such as nixos-hardware):
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-cpu-amd-pstate
      inputs.hardware.nixosModules.common-cpu-amd-zenpower
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-laptop-ssd

      # Import your generated (nixos-generate-config) hardware configuration
      ./hardware-configuration.nix
    ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Optimize the store automatically
      auto-optimise-store = true;
      # Enable flakes and new 'nix' command
      experimental-features = ["nix-command" "flakes"];
      # Increase download-buffer-size
      download-buffer-size = 500000000;
      # Set trusted users
      trusted-users = [
        "root"
        "@wheel"
        "aaryap"
      ];
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Automatically remove old generations
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];

  programs.steam.enable = true;

  # Facial recongition
  services.howdy = {
    enable = true;
    control = "sufficient";
  };
  services.linux-enable-ir-emitter.enable = true;

  # Use system 76 scheduler
  hardware.system76.enableAll = true;
  hardware.system76.power-daemon.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = lib.mkForce true;
  /*
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "com.system76.PowerDaemon" && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
  */

  # enable hibernation?
  security.protectKernelImage = false;
  boot.resumeDevice = "/dev/nvme0n1p7";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable Docker.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Enables Docker-compatible socket at /var/run/docker.sock
    # defaultNetwork.settings.dns_enabled = true;  # Optional but useful for networking
  };

  # Enable waydroid
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gparted
    gcc
    cachix
    gparted
    podman-compose
    (lib.hiPrio uutils-coreutils-noprefix)
  ];

  # memory things
  swapDevices = [
    {
      device = "/dev/nvme0n1p7";
      # size = 16*1024;
      priority = 1;
    }
  ];
  services.earlyoom.enable = true;
  zramSwap.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
  };
  programs.virt-manager.enable = true;

  programs.nix-ld.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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

  networking.hostName = "nixos"; # Define your hostname.

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    aaryap = {
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "";
      isNormalUser = true;
      description = "Aarya Patel";
      # Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "docker" "dialout" "libvirtd"];
    };
  };

  services.udev.extraRules = ''
    # Output: Virtual device creation
    KERNEL=="uinput", GROUP="aaryap", MODE:="0660"

    # Input: Physical device reading
    KERNEL=="event*", GROUP="aaryap", NAME="input/%k", MODE:="0660"
  '';

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
