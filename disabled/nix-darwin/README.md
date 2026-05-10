# nix-darwin/

## Purpose
Nix-Darwin + Home Manager declarative macOS configuration.

## Contents
- `flake.nix` — Flake entry with inputs/outputs.
- `flake.lock` — Locked dependency revisions.
- `home.nix` — Home Manager module/config.

## Current Stow target result
- `~/.config/flake.nix`
- `~/.config/flake.lock`
- `~/.config/home.nix`

## Usage status
- Usually managed as a standalone flake directory (invoked directly), not symlinked flat into `~/.config`.
- May be used manually rather than through `setup.sh`.
