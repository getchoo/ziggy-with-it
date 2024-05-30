# ziggy-with-it

A small example of a [Nix flake](https://nix.dev/concepts/flakes) for a [Zig](https://ziglang.org/) project!

## Features

- A [development shell](https://nix.dev/tutorials/first-steps/ad-hoc-shell-environments)
- `zig` from `master` via [mitchellh/zig-overlay](https://github.com/mitchellh/zig-overlay)
- A package built with [`zig.hook`](https://ryantm.github.io/nixpkgs/hooks/zig/#zig-hook) and [`nix-community/zon2nix`](https://github.com/nix-community/zon2nix)

## Thanks

- @paperdave for teaching me how to use `zon` (...or just enough to make this flake work)
