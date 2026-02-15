{ config, lib, pkgs, vars, ... }:
{
    nix.settings = {
        http-connections = 20; # Number of parallel downloads
        max-jobs = 3;          # Number of parallel compilations (TODO: increase this value if needs)
        experimental-features = [ "nix-command" "flakes" ];
        use-xdg-base-directories = true;
    };
    
    # nh clean all --keep 3 --keep-days 3, but that doesn't crush my generations
    systemd = {
        timers.nixos-cleanup = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnCalendar = "12:00";
                Persistent = true;
                RandomizeDelaySec = "10m";
            };
        };
        services.nixos-cleanup = {
            serviceConfig = {
                Type = "oneshot";
                User = "root";
                CPUSchedulingPolicy = "idle";
                IOSchedulingClass = "idle";
            };
            script = ''
                PROFILE="/nix/var/nix/profiles/system"
                KEEP_GENS=3
                KEEP_DAYS=3

                echo "--- nixos-cleanup's started ---"

                CUTOFF=$(date -d "-$KEEP_DAYS days" +%s)
                echo "CUTOFF: $CUTOFF"

                ids_to_die=""

                nix-env -p "$PROFILE" --list-generations | head -n -$KEEP_GENS | while read -r id date time misc; do
                    gen_ts=$(date -d "$date $time" +%s)
                    if [[ $gen_ts -lt $CUTOFF && -z $misc ]]; then
                        ids_to_die="$ids_to_die $id"
                        echo "Gen to die: id: $id  time: $date $time ($gen_ts)"
                    fi
                done

                echo "All IDs to die: $ids_to_die"
                nix-env -p $PROFILE --delete-generations $ids_to_die

                echo "Nix store cleaning"
                echo "Nix-collect-garbage's started"
                nix-collect-garbage
                echo "Nix-stote optimize's started"
                nix-store --optimize
                echo "--- Done ---"
            '';
        };
    };
}
