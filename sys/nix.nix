{ config, lib, pkgs, vars, self, ... }: {
    nix = {
        channel.enable = false;
        settings = {
            http-connections = 20; # Number of parallel downloads
            download-attempts = 3;
            max-jobs = 14;         # Number of parallel compilations
            # experimental-features = [ "nix-command" "flakes" ]; # Enabled by default in Determinate-nix
            use-xdg-base-directories = true;
            # Determinate
            lazy-trees = true;
            eval-cores = 0;
            allowed-users = [ "root" "@wheel" ]; # For nix-daemon

            substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"

                "https://niri.cachix.org"

                "https://nix-gaming.cachix.org"
            ];

            trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

                "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="

                "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
            ];
        };
    };
    programs.nh = {
        enable = true;
        flake = vars.configPath;
        clean = {
            enable = true;
            dates = "02:00"; # For servers. Notebooks run it after the turning on. They don't need to wait the 12 PM
            extraArgs = "--keep 3 --keep-since 3d";
        };
    };

    nix = { # Disable store optimise. It break the bcachefs and its builtin optimisations
        settings.auto-optimise-store = false;
        optimise.automatic = false;
        gc.automatic = false;
    };
    
    # Nh auto clean + bootloader updating
    systemd = {
        timers.nh-clean.timerConfig = {
            Persistent = true;
            RandomizedDelaySec = "15m";
            AccuracySec = "1m"; # Wait at most 1 minute to group service with other. It needs for battery saving
        };
        services.nh-clean = {
            serviceConfig = {
                CPUSchedulingPolicy = "idle";
                IOSchedulingClass = "idle";
            };
            postStop = "/run/current-system/bin/switch-to-configuration boot || true";
        };
    };
}
