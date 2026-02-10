{ config, lib, pkgs, vars, ... }:
{
    nix.settings = {
        http-connections = 20; # Number of parallel downloads
        max-jobs = 3;          # Number parallel compilations
        experimental-features = [ "nix-command" "flakes" ];
        use-xdg-base-directories = true;
    };
    programs.nh = {
        enable = true;
        flake = vars.configPath;
        clean = {
            enable = true;
            extraArgs = "--keep 3 --keep-since 3d";
            dates = "daily";
        };
    };
}
