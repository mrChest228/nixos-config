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
    '';
in
{
    nix.settings = {
        http-connections = 20; # Number of parallel downloads
        max-jobs = 3;          # Number of parallel compilations (TODO: increase this value if needs)
        experimental-features = [ "nix-command" "flakes" ];
        use-xdg-base-directories = true;
        auto-optimise-store = true;
    };
    programs.nh = {
        enable = true;
        flake = vars.configPath;
        clean = {
            enable = true;
            extraArgs = "--keep 3 --keep-since 3d";
            dates = "12:00";
        };
    };

    environment.systemPackages = [
        gen-clean
    ];
    
    # Automatically deleting generations and cleaning /nix/store
    # systemd = {
    #     timers.nix-cg = {
    #         wantedBy = [ "timers.target" ];
    #         timerConfig = {
    #             OnCalendar = "12:00";
    #             Persistent = true;
    #             RandomizeDelaySec = "10m";
    #         };
    #     };
    #     services.nix-cg = {
    #         serviceConfig = {
    #             Type = "oneshot";
    #             User = "root";
    #             CPUSchedulingPolicy = "idle";
    #             IOSchedulingClass = "idle";
    #         };
    #         path = with pkgs; [
    #             nix
    #             gen-clean
    #         ];
    #         script = ''
    #             echo "Generations cleaning"
    #             gen-clean
    #             echo "Nix-collect-garbage's started"
    #             nix-collect-garbage
    #             echo "Done"
    #         '';
    #     };
    # };
}
