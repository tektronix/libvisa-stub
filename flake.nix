{
  description = "A stub library to build VISA applications against, built against glibc 2.34";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      glibcVersion = "2.34";

      # nixpkgs' own glibc is much newer than 2.34, so compile with `zig cc`,
      # which can link against any specific glibc version.
      zigCC = pkgs: pkgs.writeShellScript "zig-cc" ''
        exec ${pkgs.zig}/bin/zig cc \
          -target ${pkgs.stdenv.hostPlatform.parsed.cpu.name}-linux-gnu.${glibcVersion} "$@"
      '';
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          pname = "visa-stub";
          version = "0.0.0";

          # Exclude any local CMake build directory so its cache can't leak in.
          src = nixpkgs.lib.cleanSourceWith {
            src = self;
            filter = path: type: !(type == "directory" && baseNameOf path == "build");
          };

          nativeBuildInputs = [ pkgs.cmake ];

          cmakeFlags = [ "-DCMAKE_C_COMPILER=${zigCC pkgs}" ];

          # zig needs a writable cache directory inside the build sandbox.
          preConfigure = ''
            export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
            export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-cache
          '';

          # CMakeLists.txt has no install rules; copy the build outputs directly.
          installPhase = ''
            runHook preInstall
            mkdir -p $out/lib $out/include
            cp -a out/* $out/lib/
            cp ../visa.h ../visatype.h $out/include/
            runHook postInstall
          '';
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.cmake pkgs.zig ];
          # A plain `cmake ..` in the shell picks up the glibc 2.34 compiler.
          CC = zigCC pkgs;
        };
      });
    };
}
