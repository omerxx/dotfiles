# television/

## Purpose
Configuration for Television and its "cable" data sources.

## Contents
- `config.toml` — Main Television config.
- `cable/` — Source definitions for many integrations (git, docker, k8s, history, files, etc.).

## Current Stow target result
- `~/.config/config.toml`
- `~/.config/cable/...`

## Usage status
- Potentially mis-targeted. Many tools expect `~/.config/television/config.toml` and `~/.config/television/cable/...`.
