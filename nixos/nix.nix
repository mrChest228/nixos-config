{ config, lib, pkgs, vars, ... }:
let
    # gen-clean command, that deletes all gens except at least 3 and at least 3 days
    gen-clean = pkgs.writeShellScriptBin "gen-clean" ''
        #!/bin/sh
        PROFILE="/nix/var/nix/profiles/system"
        KEEP_GENS=3
        KEEP_DAYS=3

        CUTOFF=$(date -d "-$KEEP_DAYS days" +%s)
        echo "CUTOFF: $CUTOFF"

        ids_to_die=""

        while read -r id date time misc; do
            gen_ts=$(date -d "$date $time" +%s)
            if [[ $gen_ts -lt $CUTOFF && -z $misc ]]; then
                ids_to_die="$ids_to_die $id"
                echo "Gen to die: id: $id  time: $date $time ($gen_ts)"
            fi
        done < <(nix-env -p "$PROFILE" --list-generations | head -n -$KEEP_GENS)

        echo "All IDs to die: $ids_to_die"
        nix-env -p $PROFILE --delete-generations $ids_to_die
        echo "Updating bootloader"
        sudo /run/current-system/bit/switch-to-configuration boot
    '';
    clean = pkgs.writeShellScriptBin "clean" ''
        nh clean all --keep 3 --keep-since 3d --optimise
        sudo /run/current-system/bin/switch-to-configuration boot # Updating bootloader
    '';
in
{
    nix = {
        channel.enable = false;
        settings = {
            http-connections = 20; # Number of parallel downloads
            max-jobs = 14;         # Number of parallel compilations
            # experimental-features = [ "nix-command" "flakes" ]; # Enabled by default in Determinate-nix
            use-xdg-base-directories = true;
            # Determinate
            auto-optimise-store = false; # Nh do it itself
            lazy-trees = true;
            eval-cores = 0;

            substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
                # TODO: Leave one of them
                "https://hyprland.cachix.org"
                "https://niri.cachix.org"

                "https://nix-gaming.cachix.org"
            ];

            trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="

                "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
            ];
        };
    };
    programs.nh = {
        enable = true;
        flake = vars.configPath;
    };

    environment.systemPackages = [
        clean
    ];
    
    # Nh auto clean, but with bootloader updating
    systemd = {
        timers.clean = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnCalendar = "12:00";
                Persistent = true;
                RandomizeDelaySec = "10m";
            };
        };
        services.clean = {
            serviceConfig = {
                Type = "oneshot";
                User = "root";
                CPUSchedulingPolicy = "idle";
                IOSchedulingClass = "idle";
            };
            path = with pkgs; [
                nh
                clean
            ];
            script = ''
                clean
            '';
        };
    };
}
