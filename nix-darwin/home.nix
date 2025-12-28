# home.nix
# home-manager switch 

{ config, pkgs, ... }:

{
  home.username = "klaudioz";
  home.homeDirectory = "/Users/klaudioz";
  home.stateVersion = "23.05"; # Please read the comment before changing.

# Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # ".zshrc".source = ~/dotfiles/zshrc/.zshrc;
    # ".config/starship".source = ~/dotfiles/starship;
    # ".config/nvim".source = ~/dotfiles/nvim;
    # ".config/nix".source = ~/dotfiles/nix;
    # ".config/nix-darwin".source = ~/dotfiles/nix-darwin;
    # ".config/tmux".source = ~/dotfiles/tmux;
    # ".config/ghostty".source = ~/dotfiles/ghostty;
    # ".config/aerospace".source = ~/dotfiles/aerospace;
    # ".config/sketchybar".source = ~/dotfiles/sketchybar;
    # ".config/nushell".source = ~/dotfiles/nushell;
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings.user.name = "Claudio Canales";
    settings.user.email = "klaudioz@gmail.com";
  };


  # Install global npm packages
  home.activation.npmPackages = config.lib.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    mkdir -p $HOME/.npm-global
    ${pkgs.nodejs}/bin/npm config set prefix $HOME/.npm-global
    ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code @sourcegraph/amp 2>/dev/null || true
  '';

  # Install VS Code extensions
  home.activation.vscodeExtensions = config.lib.dag.entryAfter ["writeBoundary"] ''
    if command -v code &> /dev/null; then
      code --install-extension ms-vscode-remote.remote-containers --force 2>/dev/null || true
    fi
  '';
}
