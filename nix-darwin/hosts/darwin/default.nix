homebrew = {
    enable = true;
    brews = [
      "wireshark"
    ];
    # casks = pkgs.callPackage ./casks.nix {};
    # taps = builtins.attrNames config.nix-homebrew.taps;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
      extraFlags = [
        "--verbose"
        "--debug"
      ];
    };

    masApps = {};
  };```
