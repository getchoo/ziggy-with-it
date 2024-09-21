{
  description = "oh yeah. we're getting ziggy with it now.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        # We don't use this
        flake-compat.follows = "";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      zig-overlay,
    }:
    let
      inherit (nixpkgs) lib;

      # https://github.com/mitchellh/zig-overlay?tab=readme-ov-file#usage
      zigVersion = "master-2024-05-08";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        zig = zig-overlay.packages.${system}.${zigVersion}.overrideAttrs {
          # FIXME: `zig.hook` requires `zig` to have it's `meta` attribute
          # zig-overlay doesn't provide this...yay
          inherit (pkgs.zig) meta;
        };
      in
      rec {
        devShells.default = pkgs.mkShellNoCC {
          packages = [ zig ];
        };

        formatter = pkgs.nixfmt-rfc-style;

        packages = {
          default = packages.ziggy-with-it;

          ziggy-with-it = pkgs.stdenvNoCC.mkDerivation {
            pname = "ziggy-with-it";
            version = self.shortRev or self.dirtyShortRev or "waaaa";

            src =
              with lib.fileset;
              toSource {
                root = ./.;
                fileset = unions [
                  (gitTracked ./src)
                  ./build.zig
                  ./build.zig.zon
                ];
              };

            # `deps.nix` is generated with by running `zon2nix`
            # https://github.com/nix-community/zon2nix
            postPatch = ''
              ln -s ${pkgs.callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
            '';

            nativeBuildInputs = [
              # We can use nixpkgs' `zig.hook`, but with our own `zig`
              (pkgs.zig.hook.override { inherit zig; })
            ];
          };
        };
      }
    );
}
