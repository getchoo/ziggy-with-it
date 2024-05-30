{
  description = "oh yeah. we're getting ziggy with it now.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zig-overlay,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});

    # https://github.com/mitchellh/zig-overlay?tab=readme-ov-file#usage
    zigVersion = "master-2024-05-08";
    zigFor = system: zig-overlay.packages.${system}.${zigVersion};
  in {
    devShells = forAllSystems ({
      pkgs,
      system,
      ...
    }: {
      default = pkgs.mkShellNoCC {
        inputsFrom = [self.packages.${system}.ziggy-with-it];
      };
    });

    packages = forAllSystems ({
      lib,
      pkgs,
      system,
      ...
    }: rec {
      default = ziggy-with-it;
      ziggy-with-it = pkgs.stdenvNoCC.mkDerivation {
        pname = "ziggy-with-it";
        version = self.shortRev or self.dirtyShortRev or "waaaa";

        src = with lib.fileset;
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
          ln -s ${pkgs.callPackage ./deps.nix {}} $ZIG_GLOBAL_CACHE_DIR/p
        '';

        nativeBuildInputs = [
          (pkgs.zig.hook.override {
            # FIXME: `zig.hook` requires `zig` to have it's `meta` attribute
            # zig-overlay requires this `meta` attribute..yay
            zig = zigFor system // {inherit (pkgs.zig) meta;};
          })
        ];
      };
    });
  };
}
