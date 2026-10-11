{
  description = "Flutter development and build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      android-nixpkgs,
      ...
    }:
    let
      # android-nixpkgs builds the SDK for x86_64-linux only, and nixpkgs has
      # dropped x86_64-darwin. Declaring the systems here rather than spreading
      # every default one keeps nix flake show from advertising outputs that
      # throw the moment they are evaluated.
      supportedSystems = [ "x86_64-linux" ];

      nixpkgsConfig = {
        # Spelled out instead of left to the default: Flutter is BSD-3 and every
        # Android SDK component used below is permissively licensed, so nothing
        # here needs it. Saying so stops a future dependency from quietly
        # widening the policy.
        allowUnfree = false;
        android_sdk.accept_license = true;
      };

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              config = nixpkgsConfig;
            };
          }
        );
    in
    {
      # An FHS environment rather than a plain mkShell. `flutter build linux`
      # drives CMake, which resolves GTK and GLib through pkg-config and hands
      # the result to the system linker, and that combination keeps its own
      # opinion about where libraries live. A normal nix shell answers those
      # lookups with LD_LIBRARY_PATH and wrapper scripts, which is not always
      # enough: the linker ends up versioning symbols against a different libc
      # than the one the libraries were built with, and the build dies with
      # undefined references such as sinh@GLIBC_2.44.
      #
      # buildFHSEnvBubblewrap answers them instead. It assembles a real root with
      # /usr and /lib, runs its own ldconfig so ld.so.cache matches exactly what
      # is installed, and its init sources /etc/profile before running the shell.
      devShells = forEachSupportedSystem (
        {
          pkgs,
          ...
        }:
        let
          # `flutter doctor` rejects anything older than platform 36 with
          # "Flutter requires Android SDK 36", so the platform has to track
          # whatever the SDK asks for rather than sit at an arbitrary version.
          androidSdk = android-nixpkgs.sdk.${pkgs.system} (
            sdkPkgs: with sdkPkgs; [
              cmdline-tools-latest
              build-tools-36-0-0
              platform-tools
              platforms-android-36
              platforms-android-34
            ]
          );

          fhsEnv = pkgs.buildFHSEnv {
            name = "flutter-fhs-env";

            extraOutputsToInstall = [ "dev" ];

            # Everything the toolchain needs has to be installed in the FHS root,
            # not merely be on PATH: the linker finds GTK through ld.so.cache
            # rather than through PATH, so a library that is reachable but not
            # installed is invisible to it. The GTK set mirrors what the Flutter
            # SDK's own Linux desktop build expects.
            targetPkgs =
              pkgs': with pkgs'; [
                glibc
                zlib
                stdenv.cc.cc.lib

                flutter
                # chromium
                jdk17
                cmake
                ninja
                pkg-config
                clang
                gcc
                binutils

                gtk3
                glib
                pcre2
                libepoxy
                cairo
                pango
                atk
                gdk-pixbuf
                harfbuzz
                libx11
                libdeflate

                gst_all_1.gstreamer
                gst_all_1.gst-plugins-base
                ffmpeg
                libunwind
                shaderc

                lcms2
                systemd
                openssl

                vulkan-headers
                vulkan-loader
                libass
                libplacebo
                libGL
                orc
                mpv
                libdrm
                libxtst
                libdovi
                libxkbcommon
                libdatrie
                libselinux
                libsepol
                libthai
                libass
                libsysprof-capture
                libxdmcp
                libplacebo
                libunwind
                libGL
                libdvdnav
                libdvdread
                libdvdcss
                libarchive
                libbluray
                libxml2
                libuchardet
                libdisplay-info
                alsa-lib
                zimg
                openal
                pulseaudio
                libcaca
                libgbm
                libxscrnsaver
                libxpresent
                nv-codec-headers-12
                libva
                libvdpau

                lua
                rubberband
                mujs
                pipewire
                wayland

                flutter_rust_bridge_codegen
              ];

            # Appended to the FHS /etc/profile, which the environment's init
            # sources before handing over the shell. Putting the exports here
            # rather than in runScript is what makes them visible to an
            # interactive session as well.
            profile = ''
              export JAVA_HOME="${pkgs.jdk17}"
              export ANDROID_HOME="${androidSdk}/share/android-sdk"
              export ANDROID_SDK_ROOT="$ANDROID_HOME"

              # flutter doctor looks for a "google-chrome" binary, which the
              # nixpkgs chromium package does not install under that name.
              export CHROME_EXECUTABLE="$(dirname $(dirname $(which chromium)))/bin/chromium"
            '';
          };
        in
        {
          default = fhsEnv.env;
        }
      );

      # buildFlutterApplication is a passthru attribute on the flutter package,
      # not a top-level nixpkgs export, so it is reached through the package.
      # It drives `flutter pub get` and `flutter build` itself, links the built
      # binary into bin/, writes the .desktop file, and wraps the result with
      # the GTK runtime libraries via wrapGAppsHook3.
      #
      # This expects to sit at the root of a Flutter project: pub2nix resolves
      # every dependency out of src, so pubspec.yaml has to sit next to this
      # file and autoPubspecLock has to find a pubspec.lock to pin them.
      packages = forEachSupportedSystem (
        {
          pkgs,
          ...
        }:
        let
          app = pkgs.flutter.buildFlutterApplication {
            pname = "cosmox_client";
            version = "0.1.0";
            src = ./.;
            autoPubspecLock = ./pubspec.lock;
          };
        in
        {
          default = app;
          linux = app;
          web = app.overrideAttrs (_: {
            targetFlutterPlatform = "web";
          });
        }
      );

      apps = forEachSupportedSystem (
        {
          pkgs,
          ...
        }:
        {
          default = {
            type = "app";
            program = "${self.packages.${pkgs.system}.default}/bin/app";
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
