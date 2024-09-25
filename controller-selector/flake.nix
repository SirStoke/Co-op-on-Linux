{
  description = "Build environment for controller-selector";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gcc
            gnumake
            pkg-config
            udev
            libevdev
            SDL2
            SDL2_ttf
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
              pkgs.udev
              pkgs.libevdev
              pkgs.SDL2
              pkgs.SDL2_ttf
            ]}"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "controller-selector";
          src = ./.;

          buildInputs = with pkgs; [
            udev
            libevdev
            SDL2
            SDL2_ttf
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildPhase = ''
            export CXXFLAGS="$CXXFLAGS $(pkg-config --cflags sdl2)"
            export LDFLAGS="$LDFLAGS $(pkg-config --libs sdl2)"
            make OBJ_NAME=controller-selector CXX=${pkgs.gcc}/bin/g++ LIBS="-ludev -levdev -lSDL2 -lSDL2_ttf"
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp controller-selector $out/bin/
            mkdir -p $out/share/co-op-on-linux
            cp -r assets $out/share/co-op-on-linux/
          '';
        };
      }
    );
}
