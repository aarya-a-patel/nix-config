{config, ...}: let
  packageSet = pkgs:
    pkgs.callPackage (
      {
        lib,
        stdenvNoCC,
        fetchurl,
        symlinkJoin,
      }: let
        systemToArch = {
          x86_64-linux = "amd64";
          aarch64-linux = "arm64";
        };

        arch =
          systemToArch.${stdenvNoCC.hostPlatform.system}
            or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

        nydusVersion = "2.4.0";
        nydusTag = "v${nydusVersion}";

        snapshotterTag = "v0.15.11";
        snapshotterVersion = lib.removePrefix "v" snapshotterTag;

        mkBinaryTarballPackage = {
          pname,
          version,
          src,
          extraInstall ? "",
        }:
          stdenvNoCC.mkDerivation {
            inherit pname version src;

            dontConfigure = true;
            dontBuild = true;
            dontStrip = true;

            unpackPhase = ''
              runHook preUnpack
              mkdir source
              tar -xvf "$src" -C source
              runHook postUnpack
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out/bin"
              mkdir -p "$out/share/${pname}"

              cp -R source/. "$out/share/${pname}/"

              while IFS= read -r -d "" f; do
                install -Dm755 "$f" "$out/bin/$(basename "$f")"
              done < <(find source -type f -path '*/bin/*' -perm -0100 -print0)

              while IFS= read -r -d "" f; do
                base="$(basename "$f")"
                case "$base" in
                  *.sh|*.txt|*.md|LICENSE*|README*)
                    continue
                    ;;
                esac
                if [ ! -e "$out/bin/$base" ]; then
                  install -Dm755 "$f" "$out/bin/$base"
                fi
              done < <(find source -type f -perm -0100 ! -path '*/bin/*' -print0)

              ${extraInstall}

              runHook postInstall
            '';

            meta = with lib; {
              description = "Repackaged upstream ${pname} binary release tarball";
              platforms = platforms.linux;
              license = licenses.asl20;
            };
          };

        nydus = mkBinaryTarballPackage {
          pname = "nydus";
          version = nydusVersion;
          src = fetchurl {
            url = "https://github.com/dragonflyoss/nydus/releases/download/${nydusTag}/nydus-static-${nydusTag}-linux-${arch}.tgz";
            hash = "sha256-5PfeZyztYDHBPDw4pZmZP4qBA7DPhfmweD9fX6fIs9w=";
          };

          extraInstall = ''
            if [ -d source/nydus-static/configs ]; then
              mkdir -p "$out/etc/nydus"
              cp -R source/nydus-static/configs "$out/etc/nydus/"
            elif [ -d source/configs ]; then
              mkdir -p "$out/etc/nydus"
              cp -R source/configs "$out/etc/nydus/"
            fi
          '';
        };

        nydus-snapshotter = mkBinaryTarballPackage {
          pname = "nydus-snapshotter";
          version = snapshotterVersion;
          src = fetchurl {
            url = "https://github.com/containerd/nydus-snapshotter/releases/download/${snapshotterTag}/nydus-snapshotter-${snapshotterTag}-linux-${arch}.tar.gz";
            hash = "sha256-sfKVD2irdSk0DD+/+my96R2UF0mjgG3H3geH7dtEO5U=";
          };
        };
      in {
        inherit nydus nydus-snapshotter;

        all = symlinkJoin {
          name = "nydus-bundle-${nydusVersion}-${snapshotterVersion}";
          paths = [nydus nydus-snapshotter];
        };
      }
    ) {};
in {
  config.perSystem = {pkgs, ...}: let
    packages = packageSet pkgs;
  in {
    packages = {
      nydus = packages.nydus;
      nydus-snapshotter = packages.nydus-snapshotter;
      nydus-bundle = packages.all;
    };
  };
}
