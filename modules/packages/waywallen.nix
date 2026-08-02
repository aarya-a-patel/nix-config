{config, ...}: let
  package = pkgs:
    pkgs.callPackage (
      {
        appimageTools,
        fetchurl,
      }:
        appimageTools.wrapType2 {
          pname = "waywallen";
          version = "0.2.6";

          src = fetchurl {
            url = "https://github.com/waywallen/waywallen/releases/download/v0.2.6/waywallen-0.2.6-x86_64.AppImage";
            hash = "sha256-SAUUJN6ldS4Pn2kOpTYMD9/gOsEM+lLKsZDdXF+ocnw=";
          };
        }
    ) {};

  openWallpaperEnginePlugin = pkgs:
    pkgs.callPackage (
      {
        alsa-lib,
        at-spi2-core,
        autoPatchelfHook,
        cairo,
        cmake,
        cups,
        dbus,
        expat,
        ffmpeg_7,
        fetchurl,
        fontconfig,
        freetype,
        glib,
        glslang,
        gtk3,
        lib,
        libdrm,
        libgbm,
        libGL,
        libpulseaudio,
        libva,
        libx11,
        libxcb,
        libxcomposite,
        libxdamage,
        libxext,
        libxfixes,
        libxkbcommon,
        libxrandr,
        libxrender,
        libXScrnSaver,
        lz4,
        makeWrapper,
        nasm,
        ninja,
        nspr,
        nss,
        pango,
        pkg-config,
        stdenv,
        systemd,
        vulkan-headers,
        vulkan-loader,
        wayland,
        writeText,
        zip,
        zlib,
        llvmPackages_22,
      }: let
        version = "0.2.0-unstable-2026-08-02";

        scannerIncludes = [
          llvmPackages_22.libcxxStdenv.cc.libc
          vulkan-headers
          ffmpeg_7
          libva
          libpulseaudio
          libdrm
          libgbm
          libGL
          freetype
          fontconfig
          lz4
          zlib
          waywallenBridge
        ];

        waywallenBridge = stdenv.mkDerivation {
          pname = "waywallen-bridge";
          version = "0.2.6";

          src = fetchurl {
            url = "https://github.com/waywallen/waywallen/archive/refs/tags/v0.2.6.tar.gz";
            hash = "sha256-BjyQlHFeKFD9L0QKr5m4BwtqXvmY0hraWKGUivRaOdM=";
          };

          postUnpack = ''
            sourceRoot="$sourceRoot/bridge"
          '';

          nativeBuildInputs = [
            cmake
            ninja
            pkg-config
          ];

          buildInputs = [
            libgbm
            libGL
            vulkan-headers
            vulkan-loader
          ];
        };

        sources = {
          eigen = fetchurl {
            url = "https://gitlab.com/libeigen/eigen/-/archive/bc3b39870ecb690a623a3f49149a358b95c5781d/eigen-bc3b39870ecb690a623a3f49149a358b95c5781d.tar.gz";
            hash = "sha256-X2VX0aym6VmkuVXFXyk1Jh/TDeWcDHnjW8bVy+HeItE=";
          };
          spirv-reflect = fetchurl {
            url = "https://github.com/KhronosGroup/SPIRV-Reflect/archive/refs/tags/vulkan-sdk-1.4.321.0.tar.gz";
            hash = "sha256-JU7TYSjnq+j7Eu+AQxnQeQ4FkJPBFun+VdQAOIBRX4U=";
          };
          glslang = fetchurl {
            url = "https://github.com/KhronosGroup/glslang/archive/275822a6261ee689aadb1da5f09a0ec2f058685c.tar.gz";
            hash = "sha256-lxhIocxjnOjcJE53ixfv4PaQ4yrDmKdeMdHGetBtPgo=";
          };
          vma = fetchurl {
            url = "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/3aa921224c154a0d2c43912bc88e1c42ce1f7607.tar.gz";
            hash = "sha256-WTXcR9hlm7aB8bchj5A+wXHRDDlQl1L9ZOssna9gHO0=";
          };
          rstd = fetchurl {
            url = "https://github.com/litocpp/rstd/archive/bf5f855ddb1b84390306e0913b89149ac72a3510.tar.gz";
            hash = "sha256-QQgNEQSVCsoMKdXU54b5nXsWEDegIDbH9ApEm3RzZ64=";
          };
          vvk = fetchurl {
            url = "https://github.com/litocpp/vvk/archive/8fcfd34b43a13ade515f029b0b4209bd3684645f.tar.gz";
            hash = "sha256-rebzVWCSeF2ttTmtbqSkzPCf2K4c1ZvuKhi5IiLHlMA=";
          };
          wavsen = fetchurl {
            url = "https://github.com/hypengw/wavsen/archive/d18c74a2e1087ebf318891e58aa8416be755e319.tar.gz";
            hash = "sha256-qsv2XCpWwXoUnucFNm+TKA/0JeKlhWGROsi4YxWCQmI=";
          };
          quickjs = fetchurl {
            url = "https://github.com/quickjs-ng/quickjs/archive/3c051980ab7e783dfbfb1c70c014ce5e05ecf24c.tar.gz";
            hash = "sha256-L6851CVoAfzB4zo2McPkojuecoifgkDUSRQrrqNHo+g=";
          };
          cef = fetchurl {
            url = "https://cef-builds.spotifycdn.com/cef_binary_149.0.4%2Bg2f1bfd8%2Bchromium-149.0.7827.156_linux64_minimal.tar.bz2";
            hash = "sha256-bUNgdnXkfta/pA0c/OE20E53IFKfjxxENdS6Hc0YObI=";
          };
        };

        rstdPatched = stdenv.mkDerivation {
          pname = "rstd-open-wallpaper-engine";
          version = "bf5f855";

          src = sources.rstd;

          postPatch = ''
            substituteInPlace src/std/sys/libc/unix.cppm \
              --replace-fail "using ::read;" "inline auto read(int fd, void* buf, ::size_t count) noexcept -> ::ssize_t { return static_cast<::ssize_t>(::syscall(SYS_read, fd, buf, count)); }" \
              --replace-fail "using ::pread;" "inline auto pread(int fd, void* buf, ::size_t count, ::off_t offset) noexcept -> ::ssize_t { return static_cast<::ssize_t>(::syscall(SYS_pread64, fd, buf, count, offset)); }" \
              --replace-fail "using ::readlink;" "inline auto readlink(char const* path, char* buf, ::size_t bufsiz) noexcept -> ::ssize_t { return static_cast<::ssize_t>(::syscall(SYS_readlink, path, buf, bufsiz)); }" \
              --replace-fail "using ::realpath;" "inline auto realpath(char const* path, char* resolved_path) noexcept -> char* { if (resolved_path != nullptr) return nullptr; return ::canonicalize_file_name(path); }" \
              --replace-fail "using ::open;" "inline auto open(char const* path, int flags) noexcept -> int { return static_cast<int>(::syscall(SYS_openat, AT_FDCWD, path, flags, 0)); }"$'\n'"inline auto open(char const* path, int flags, ::mode_t mode) noexcept -> int { return static_cast<int>(::syscall(SYS_openat, AT_FDCWD, path, flags, mode)); }"
          '';

          installPhase = ''
            runHook preInstall
            cp -R . "$out"
            runHook postInstall
          '';
        };

        depsJson = writeText "open-wallpaper-engine-deps.json" (builtins.toJSON [
          {
            type = "archive";
            url = sources.eigen;
            sha256 = "5f6557d1aca6e959a4b955c55f2935261fd30de59c0c79e35bc6d5cbe1de22d1";
            x-cmake = {
              name = "eigen";
              exclude_from_all = true;
              source_subdir = "cmake-noop";
            };
          }
          {
            type = "archive";
            url = sources.spirv-reflect;
            sha256 = "254ed36128e7abe8fb12ef804319d0790e059093c116e9fe55d4003880515f85";
            x-cmake = {
              name = "spirv_reflect";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            url = sources.glslang;
            sha256 = "971848a1cc639ce8dc244e778b17efe0f690e32ac398a75e31d1c67ad06d3e0a";
            x-cmake = {
              name = "glslang";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            url = sources.vma;
            sha256 = "5935dc47d8659bb681f1b7218f903ec171d10c39509752fd64eb2c9daf601ced";
            x-cmake = {
              name = "vma";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            url = sources.rstd;
            sha256 = "41080d1104950aca0c29d5d4e786f99d7b161037a02036c7f40a449b747367ae";
            x-cmake = {
              name = "rstd";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            url = sources.vvk;
            sha256 = "ade6f3556092785dadb539ad6ea4a4ccf09fd8ae1cd59bee2a18b92222c794c0";
            x-cmake = {
              name = "vvk";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            url = sources.wavsen;
            sha256 = "aacbf65c2a56c17a149ee705366f93280ff425e2a58561913ac8b86315824262";
            x-cmake = {
              name = "wavsen";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            url = sources.quickjs;
            sha256 = "2faf39d4256801fcc1e33a3631c3e4a23b9e72889f8240d449142baea347a3e8";
            x-cmake = {
              name = "quickjs";
              exclude_from_all = true;
            };
          }
          {
            type = "archive";
            only-arches = ["x86_64"];
            url = sources.cef;
            sha256 = "6d43607675e47ed6bfa40d1cfce136d04e7720529f8f1c4435d4ba1dcd1839b2";
            x-cmake = {
              name = "cef";
              exclude_from_all = true;
              source_subdir = "cmake-noop";
            };
          }
        ]);
      in
        llvmPackages_22.libcxxStdenv.mkDerivation {
          pname = "waywallen-open-wallpaper-engine-plugin";
          inherit version;

          src = fetchurl {
            url = "https://github.com/waywallen/open-wallpaper-engine/archive/39f072a9c16b7ccdc730ebf7f223c7ab624b586f.tar.gz";
            hash = "sha256-Lawdh9L4qyS188qKCBg/FIwe/ZpSAOa9hrYCBPiBYPM=";
          };

          nativeBuildInputs = [
            autoPatchelfHook
            cmake
            glslang
            makeWrapper
            nasm
            ninja
            pkg-config
            zip
          ];

          buildInputs = [
            alsa-lib
            at-spi2-core
            cairo
            cups
            dbus
            expat
            ffmpeg_7
            fontconfig
            freetype
            glib
            gtk3
            libdrm
            libgbm
            libGL
            libpulseaudio
            libva
            libx11
            libxcb
            libxcomposite
            libxdamage
            libxext
            libxfixes
            libxkbcommon
            libxrandr
            libxrender
            libXScrnSaver
            lz4
            nspr
            nss
            pango
            systemd
            vulkan-headers
            vulkan-loader
            waywallenBridge
            wayland
            zlib
          ];

          postPatch = ''
            cp ${depsJson} deps.json
            substituteInPlace waywallen/plugins/org.waywallen.open-wallpaper-engine/plugin.toml.in \
              --replace-fail 'fps    = { type = "u32", default = 30,' 'fps    = { type = "u32", default = 60,'
            substituteInPlace waywallen/plugins/org.waywallen.open-wallpaper-engine/weweb-renderer.toml.in \
              --replace-fail 'fps = { type = "u32", default = 30,' 'fps = { type = "u32", default = 60,'
            substituteInPlace waywallen/scene_entry.cpp \
              --replace-fail 'uint32_t    initial_fps { 30 };' 'uint32_t    initial_fps { 60 };'
          '';

          cmakeFlags = [
            "-DBUILD_TESTS=OFF"
            "-DBUILD_VIEWER=OFF"
            "-DBUILD_WAYWALLEN=ON"
            "-DBUILD_WESCENE=ON"
            "-DBUILD_WEWEB=ON"
            "-DFETCHDEPS_LOCAL_rstd=${rstdPatched}"
            "-DOWE_WAYWALLEN_PLUGIN_BUNDLE_LAYOUT=ON"
          ];

          env.CXXFLAGS =
            "-I${llvmPackages_22.libcxx.dev}/include/c++/v1 "
            + lib.concatMapStringsSep " " (pkg: "-I${lib.getDev pkg}/include") scannerIncludes
            + " -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0";
          env.NIX_LDFLAGS = "--allow-shlib-undefined";

          postFixup = ''
            mkdir -p "$out/share/waywallen/plugins"
            (
              cd "$out"
              zip -qr "$out/share/waywallen/plugins/org.waywallen.open-wallpaper-engine-${version}-linux-x86_64.zip" \
                files.txt \
                plugin.toml \
                main.lua \
                wallpaper_engine \
                bin
            )
          '';

          meta = {
            description = "Wallpaper Engine plugin bundle for Waywallen";
            homepage = "https://github.com/waywallen/open-wallpaper-engine";
            license = lib.licenses.gpl3Only;
            platforms = ["x86_64-linux"];
          };
        }
    ) {};
in {
  config = {
    perSystem = {pkgs, ...}: {
      packages.waywallen = package pkgs;
      packages.waywallen-open-wallpaper-engine-plugin = openWallpaperEnginePlugin pkgs;
    };
  };
}
