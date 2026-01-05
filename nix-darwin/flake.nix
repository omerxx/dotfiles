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
        pkgs.tmux
        pkgs.fzf
        pkgs.fd
        pkgs.ripgrep
        pkgs.bat
        pkgs.zoxide
        pkgs.atuin
        pkgs.eza
        pkgs.yazi
        pkgs.tree
        pkgs.go
        pkgs.nodejs
        pkgs.bun
        pkgs.pnpm
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
        pkgs.playwright-driver
        pkgs.pv
        pkgs.watch
        pkgs.stow
        pkgs.aichat
        pkgs.gemini-cli
        pkgs.lazygit
        pkgs.uv
        pkgs.delta
        pkgs.cloc
        pkgs.cmatrix
        pkgs.mactop
        pkgs.yt-dlp

        # Fonts
        pkgs.nerd-fonts.jetbrains-mono

        # Cloud CLIs
        pkgs.kubectl
        pkgs.awscli2
        pkgs.google-cloud-sdk
        pkgs.doctl
        pkgs.flyctl
        pkgs.terraform
        pkgs.gh
      ];
      nix.enable = false;  # Let Determinate Systems manage Nix
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      security.pam.services.sudo_local.touchIdAuth = true;
      security.pam.services.sudo_local.watchIdAuth = true;   # Apple Watch for sudo (Mac mini has no Touch ID)
      security.pam.services.sudo_local.reattach = true;      # Fix auth inside tmux/screen

      system.primaryUser = "klaudioz";
      users.users.klaudioz.home = "/Users/klaudioz";
      home-manager.backupFileExtension = "backup";

      system.defaults = {
        dock.autohide = true;
        dock.orientation = "left";
        dock.mru-spaces = false;
        dock.persistent-apps = [];  # Empty dock - no pinned apps
        dock.expose-group-apps = true;  # Group windows by app in Mission Control
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        finder.CreateDesktop = false;           # Hide all desktop icons
        loginwindow.LoginwindowText = "m4-mini";
        screencapture.location = "~/Pictures/screenshots";
        screencapture.target = "clipboard";     # Cmd+Shift+4 copies to clipboard
        screensaver.askForPasswordDelay = 10;
        # Keyboard: fast but controllable key repeat
        NSGlobalDomain.KeyRepeat = 2;           # Fast (default: 6)
        NSGlobalDomain.InitialKeyRepeat = 15;   # Short delay (default: 25)
        # Menu bar hiding is set via activation script (value 2 = auto-hide with notifications)
      };

      # Kernel / launchd resource limits (avoid apps failing with "error.SystemResources").
      launchd.daemons.sysctl-maxproc = {
        serviceConfig = {
          ProgramArguments = [
            "/usr/sbin/sysctl"
            "-w"
            "kern.maxproc=10000"
            "kern.maxprocperuid=10000"
          ];
          RunAtLoad = true;
          StandardOutPath = "/tmp/sysctl-maxproc.out";
          StandardErrorPath = "/tmp/sysctl-maxproc.err";
        };
      };

      launchd.daemons.launchctl-maxproc = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/launchctl"
            "limit"
            "maxproc"
            "10000"
            "10000"
          ];
          RunAtLoad = true;
          StandardOutPath = "/tmp/launchctl-maxproc.out";
          StandardErrorPath = "/tmp/launchctl-maxproc.err";
        };
      };

      launchd.daemons.launchctl-maxfiles = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/launchctl"
            "limit"
            "maxfiles"
            "524288"
            "524288"
          ];
          RunAtLoad = true;
          StandardOutPath = "/tmp/launchctl-maxfiles.out";
          StandardErrorPath = "/tmp/launchctl-maxfiles.err";
        };
      };

      # Set desktop wallpaper and other settings that need non-boolean values
      system.activationScripts.postActivation.text = ''
        # Auto-hide menu bar (2) - keeps notifications working unlike full hide (1)
        sudo -u klaudioz defaults write NSGlobalDomain _HIHideMenuBar -int 2

        osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "/Users/klaudioz/dotfiles/wallpaper.jpeg"'

        # Deploy Chrome managed policies (force-install extensions)
        mkdir -p "/Library/Managed Preferences"
        cp /Users/klaudioz/dotfiles/chrome/com.google.Chrome.plist "/Library/Managed Preferences/"
        chown root:wheel "/Library/Managed Preferences/com.google.Chrome.plist"
        chmod 644 "/Library/Managed Preferences/com.google.Chrome.plist"

        # Install gh-dash extension (runs as user, idempotent)
        sudo -u klaudioz ${pkgs.gh}/bin/gh extension install dlvhdr/gh-dash 2>/dev/null || true
      '';

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.global.lockfiles = true;  # --no-lock was removed from brew bundle

      homebrew.taps = [
        "FelixKratz/formulae"
        "joncrangle/tap"
        "nikitabobko/tap"
        "productdevbook/tap"
        "steipete/tap"
        "tw93/tap"
      ];

      homebrew.casks = [
        "wireshark"
        "google-chrome"
        "ghostty"
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
        "linear-linear"
        "bettermouse"
        "itsycal"
        "qbittorrent"
        "visual-studio-code"
        "zed"
        "zoom"
        "sf-symbols"
        "font-sketchybar-app-font"
        "xbar"
        "codex"
        "steipete/tap/repobar"
        "setapp"
        "tailscale"
        "productdevbook/tap/portkiller"
        "powershell"
        "warp"
      ];

      homebrew.brews = [
        "gitingest"
        "neovim"
        "cmake"
        "imagemagick"
        "ical-buddy"
        "ifstat"
        "opencode"
        "blueutil"
        "libpq"
        "render"
        "cliproxyapi"
        "tw93/tap/mole"
        "felixkratz/formulae/sketchybar"
        "felixkratz/formulae/borders"
        "joncrangle/tap/sketchybar-system-stats"
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
