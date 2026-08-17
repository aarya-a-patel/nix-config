{config, ...}: let
  package = pkgs:
    pkgs.callPackage (
      {
        adwaita-icon-theme,
        alsa-lib,
        autoPatchelfHook,
        config,
        copyDesktopItems,
        curl,
        dbus-glib,
        fetchzip,
        ffmpeg_9,
        gtk3,
        lib,
        libGL,
        libva,
        libXtst,
        makeDesktopItem,
        patchelfUnstable,
        pciutils,
        pipewire,
        stdenv,
        wrapGAppsHook3,
        writeText,
        policies ? {},
        extraPolicies ? {},
        enablePrivateDesktopEntry ? false,
      }: let
        pname = "zen-stable";
        version = "1.21.14b";
        libName = "zen-bin-${version}";

        policiesJson = writeText "zen-policies.json" (builtins.toJSON {
          policies = (config.firefox.policies or {}) // policies // extraPolicies;
        });

        desktopItem = makeDesktopItem {
          name = pname;
          desktopName = "Zen Browser";
          genericName = "Web Browser";
          exec = "${pname} %u";
          icon = "zen";
          categories = [
            "Network"
            "WebBrowser"
          ];
          mimeTypes = [
            "text/html"
            "application/xhtml+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/about"
            "x-scheme-handler/unknown"
          ];
          startupWMClass = pname;
          startupNotify = true;
        };
      in
        stdenv.mkDerivation {
          inherit pname version;

          src = fetchzip {
            url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
            hash = "sha256-GAqKctJrNg5zwFoluZXTKDuBvt416/qaBEQMsGOKUk4=";
          };

          nativeBuildInputs = [
            autoPatchelfHook
            copyDesktopItems
            patchelfUnstable
            wrapGAppsHook3
          ];

          buildInputs = [
            adwaita-icon-theme
            alsa-lib
            curl
            dbus-glib
            ffmpeg_9
            gtk3
            libGL
            libva
            libXtst
            pciutils
            pipewire
          ];

          desktopItems = [desktopItem];

          passthru = {
            applicationName = "Zen Browser";
            binaryName = pname;
            libName = libName;
            gtk3 = gtk3;
            ffmpegSupport = true;
            pipewireSupport = true;
            alsaSupport = true;
            gssSupport = true;
          };

          installPhase = ''
            runHook preInstall

            mkdir -p "$out/lib/${libName}" "$out/bin"
            cp -r . "$out/lib/${libName}"
            ln -s "$out/lib/${libName}/zen" "$out/bin/${pname}"

            mkdir -p "$out/lib/${libName}/distribution"
            ln -s ${policiesJson} "$out/lib/${libName}/distribution/policies.json"

            install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
              $out/share/applications/${pname}.desktop

            for size in 16 32 48 64 128; do
              install -Dm444 "$out/lib/${libName}/browser/chrome/icons/default/default''${size}.png" \
                "$out/share/icons/hicolor/''${size}x''${size}/apps/zen.png"
              install -Dm444 "$out/lib/${libName}/browser/chrome/icons/default/default''${size}.png" \
                "$out/share/icons/hicolor/''${size}x''${size}/apps/zen-browser.png"
            done

            runHook postInstall
          '';
        }
    ) {};
in {
  config.perSystem = {pkgs, ...}: {
    packages.zen-stable = package pkgs;
  };
}
