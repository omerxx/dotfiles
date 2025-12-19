{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        # Existing
        pkgs.vim
        pkgs.direnv
        pkgs.sshs
        pkgs.glow
        pkgs.nushell
        pkgs.carapace

        # Core tools
        pkgs.neovim
        pkgs.tmux
        pkgs.fzf
        pkgs.fd
        pkgs.ripgrep
        pkgs.bat
        pkgs.zoxide
        pkgs.atuin
        pkgs.eza
        pkgs.tree
        pkgs.go
        pkgs.nodejs
        pkgs.rustup
        pkgs.xh
        pkgs.kubectx
        pkgs.starship
        pkgs.jq
        pkgs.yq

        # Security tools
        pkgs.nmap
        pkgs.gobuster
        pkgs.ffuf
        pkgs.ngrok

        # Developer utilities
        pkgs.aichat
        pkgs.lazygit
        pkgs.uv
        pkgs.delta

        # Cloud CLIs
        pkgs.kubectl
        pkgs.awscli2
        pkgs.google-cloud-sdk
        pkgs.doctl
        pkgs.flyctl
      ];
      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      security.pam.enableSudoTouchIdAuth = true;

      users.users.klaudioz.home = "/Users/klaudioz";
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "devops-toolbox";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;

      homebrew.taps = [
        "FelixKratz/formulae"
        "koekeishiya/formulae"
        "nikitabobko/tap"
      ];

      homebrew.casks = [
        "wireshark"
        "google-chrome"
        "ghostty"
        "wezterm"
        "nikitabobko/tap/aerospace"
        "hammerspoon"
        "telegram"
        "slack"
        "discord"
        "obsidian"
        "arc"
        "cursor"
        "windsurf"
        "qspace-pro"
        "granola"
        "firefox"
        "devonthink"
        "vial"
        "raycast"
        "gitify"
        "1password"
        "linear"
        "linearmouse"
        "itsycal"
        "qbittorrent"
        "screen-studio"
        "visual-studio-code"
        "readdle-spark"
      ];

      homebrew.brews = [
        "imagemagick"
        "ical-buddy"
        "sketchybar"
        "borders"
        "skhd"
      ];
    };
  in
  {
    darwinConfigurations."Claudios-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
	configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.klaudioz = import ./home.nix;
        }
      ];
    };

    darwinConfigurations."m4-mini" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
	configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.klaudioz = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Claudios-MacBook-Pro".pkgs;
  };
}
