{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.openclawContainer;
  containerName = "openclaw";
  rootfs = "/var/lib/machines/openclaw";
  marker = "${rootfs}/.openclaw-provisioned";
  workspacePath = "/home/${cfg.username}/Documents/openclaw";
  debSuite = "stable";
  debMirror = "https://deb.debian.org/debian";
  hostSystem = pkgs.stdenv.hostPlatform.system;
  debArch =
    if hostSystem == "x86_64-linux"
    then "amd64"
    else if hostSystem == "aarch64-linux"
    then "arm64"
    else throw "openclaw-container: unsupported host system ${hostSystem}";
  user = config.users.users.${cfg.username};
  userGroup = user.group or cfg.username;
in {
  options.services.openclawContainer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Provision and manage the OpenClaw systemd-nspawn container.";
    };

    username = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Host username to mirror inside the container.";
      example = "aaryap";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.username != null && cfg.username != "";
        message = "services.openclawContainer.username must be set.";
      }
      {
        assertion = lib.hasAttr cfg.username config.users.users;
        message = "User ${cfg.username} must exist in users.users.";
      }
    ];

    # Ensure the host workspace exists and is owned by the host user.
    systemd.tmpfiles.rules = [
      "d ${workspacePath} 0755 ${cfg.username} ${userGroup} - -"
    ];

    systemd.nspawn.${containerName} = {
      enable = true;
      execConfig = {
        Boot = true;
        NotifyReady = true;
      };
      filesConfig = {
        # Bind mounts are host paths; ownership is preserved because we map the user UID/GID.
        Bind = [
          "${workspacePath}:${workspacePath}"
        ];
      };
      networkConfig = {
        # Private=no uses the host network stack for simple, reliable networking.
        Private = false;
      };
    };

    systemd.services.openclaw-rootfs = {
      description = "Bootstrap Debian rootfs for OpenClaw container (idempotent)";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "openclaw-rootfs-bootstrap" ''
          set -euo pipefail

          # Debootstrap runs only if the persistent rootfs is missing.
          if [ -d "${rootfs}" ]; then
            exit 0
          fi

          install -d -m 0755 "${rootfs}"
          ${pkgs.debootstrap}/bin/debootstrap \
            --arch=${debArch} \
            --include=systemd-sysv,dbus,ca-certificates,gnupg \
            ${debSuite} "${rootfs}" ${debMirror}

          if [ ! -s "${rootfs}/etc/machine-id" ]; then
            ${pkgs.systemd}/bin/systemd-machine-id-setup --root="${rootfs}"
          fi
        '';
      };
    };

    systemd.services.openclaw-provision = {
      description = "Provision OpenClaw container (packages, user, Homebrew, OpenClaw)";
      wantedBy = ["multi-user.target"];
      after = [
        "network-online.target"
        "openclaw-rootfs.service"
      ];
      requires = ["openclaw-rootfs.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "openclaw-provision" ''
                              set -euo pipefail

                              host_uid="$(${pkgs.coreutils}/bin/id -u ${cfg.username})"
                              host_gid="$(${pkgs.coreutils}/bin/id -g ${cfg.username})"
                              host_group="$(${pkgs.coreutils}/bin/id -gn ${cfg.username})"

                              # Provisioning is idempotent via a marker file.
                              if [ -f "${marker}" ]; then
                                ${pkgs.systemd}/bin/systemd-nspawn \
                                  --quiet \
                                  -D "${rootfs}" \
                                  /bin/bash -euo pipefail -c '
                                    /bin/sh -c "/bin/cat > /etc/profile.d/openclaw-path.sh <<'EOF'
          # Ensure Homebrew and OpenClaw are on PATH for all shells.
            export PATH=\"\\\$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/${cfg.username}/.npm-global/bin\"
          EOF"
                                    /usr/bin/chmod 0644 /etc/profile.d/openclaw-path.sh
                                  '
                                exit 0
                              fi

                              ${pkgs.systemd}/bin/systemd-nspawn \
                                --quiet \
                                -D "${rootfs}" \
                                --resolv-conf=copy-host \
                                --setenv=DEBIAN_FRONTEND=noninteractive \
                                --setenv=HOST_UID="$host_uid" \
                                --setenv=HOST_GID="$host_gid" \
                                --setenv=HOST_GROUP="$host_group" \
                                /bin/bash -euo pipefail -c '
                                  /usr/bin/apt-get update
                                  /usr/bin/apt-get install -y --no-install-recommends \
                                    curl git build-essential sudo nodejs npm golang-go

                                  echo "${containerName}" > /etc/hostname
                                  if ! /usr/bin/grep -qE "^[[:space:]]*127\\.0\\.1\\.1[[:space:]]+${containerName}" /etc/hosts; then
                                    echo "127.0.1.1 ${containerName}" >> /etc/hosts
                                  fi

                                  /usr/sbin/groupadd -g "$HOST_GID" "$HOST_GROUP" || true
                                  /usr/sbin/useradd -m -u "$HOST_UID" -g "$HOST_GID" -s /bin/bash ${cfg.username} || true
                                  /usr/bin/chown -R "$HOST_UID:$HOST_GID" "/home/${cfg.username}"
                                  /usr/bin/mkdir -p "/home/${cfg.username}/.cache"
                                  /usr/bin/chown -R "$HOST_UID:$HOST_GID" "/home/${cfg.username}/.cache"

                                  /bin/sh -c "/bin/cat > /etc/profile.d/openclaw-path.sh <<'EOF'
          # Ensure Homebrew and OpenClaw are on PATH for all shells.
          if [ -n \"\$PATH\" ]; then
            export PATH=\"\\\$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/${cfg.username}/.npm-global/bin\"
          else
            export PATH=\"/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/${cfg.username}/.npm-global/bin\"
          fi
          EOF"
                                  /usr/bin/chmod 0644 /etc/profile.d/openclaw-path.sh

                                  echo "${cfg.username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-openclaw-user
                                  /usr/bin/chmod 0440 /etc/sudoers.d/90-openclaw-user

                                  /usr/bin/su - ${cfg.username} -c "NONINTERACTIVE=1 /bin/bash -c \"\$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                                  /usr/bin/su - ${cfg.username} -c "/usr/bin/curl -fsSL https://openclaw.ai/install.sh | /bin/bash -s -- --no-onboard"
                                '

                              touch "${marker}"
        '';
      };
    };

    systemd.services."systemd-nspawn@${containerName}" = {
      overrideStrategy = "asDropin";
      wantedBy = ["machines.target"];
      after = [
        "openclaw-rootfs.service"
        "openclaw-provision.service"
      ];
      requires = [
        "openclaw-rootfs.service"
        "openclaw-provision.service"
      ];
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "openclaw-shell" ''
        # Enter the running container as the host user.
        exec machinectl shell --uid=${cfg.username} ${containerName} /bin/bash -l
      '')
    ];

    # Reset container: stop, remove rootfs, and re-run provisioning on next boot.
    # Example:
    #   systemctl stop systemd-nspawn@openclaw
    #   rm -rf /var/lib/machines/openclaw
    #   systemctl start openclaw-rootfs openclaw-provision
  };
}
