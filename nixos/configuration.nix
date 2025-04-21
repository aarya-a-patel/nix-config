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
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.asus-touch-numpad-driver
    outputs.nixosModules.bluetooth
    outputs.nixosModules.dm
    outputs.nixosModules.kde
    outputs.nixosModules.shell
    outputs.nixosModules.neovim

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    ./gpu-configuration.nix

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
      experimental-features = [ "nix-command" "flakes" ];
      # Increase download-buffer-size
      download-buffer-size = 500000000;
      # Set trusted users
      trusted-users = [
        "root"
        "@wheel"
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

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    extraInstallCommands = ''
      echo "default @saved" >> /boot/loader/loader.conf
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };
  boot.initrd.verbose = false;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["quiet" "udev.log_level=0"];

  # Enable NTFS
  boot.supportedFilesystems.ntfs = true;

  # Auto upgrade
  /*
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
  */

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable iwd (better wifi).
  # networking.wireless.iwd.enable = true;
  # networking.wireless.iwd.settings = {
  #   General.EnableNetworkConfiguration = true;
  #   IPv6.Enabled = true;
  #   Settings.AutoConnect = true;
  # };
  # networking.networkmanager.wifi.backend = "iwd";

  # Enable the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # System clock is local time
  time.hardwareClockInLocalTime = true;

  # Set your time zone.
  time.timeZone = "America/Indiana/Indianapolis";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  programs.steam.enable = true;

  # SSH
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    startWhenNeeded = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
  programs.mosh.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    xkb = {
      layout = "us";
      variant = "";
    };
    excludePackages = [ pkgs.xterm ];
  };

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


  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable Docker.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Enables Docker-compatible socket at /var/run/docker.sock
    # defaultNetwork.settings.dns_enabled = true;  # Optional but useful for networking
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    qemu_full
    quickemu
    wineWowPackages.waylandFull
    winetricks
    gcc
    cachix
    gparted
    lutris
    (hiPrio uutils-coreutils-noprefix)
  ];

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;
  } ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [
          pkgs.OVMFFull.fd
        ];
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
      extraGroups = [ "networkmanager" "wheel" "docker" "dialout" "libvirtd" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
