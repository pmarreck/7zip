{
  description = "7zip — Zig 0.16 wrapper around 7-Zip C sources (static lib + headers)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, zig-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zig = zig-overlay.packages.${system}."0.16.0";
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "7zip";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ zig ];
          dontConfigure = true;
          buildPhase = ''
            export HOME=$TMPDIR
            export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
            mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
            zig build -Doptimize=ReleaseFast --prefix $out
          '';
          installPhase = "true"; # build.zig already installs lib + headers to $out
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ zig pkgs.git ];
        };
      });
}
