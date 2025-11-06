{ config, lib, pkgs, vars, ... }:
{
    nix = {
        settings = {
            substituters = [ # Download sources
                "https://cache.nixos.org/"
            ];
            http-connections = 20; # Number of parallel downloads
            max-jobs = 3; # Number parallel compilations
        };
    };
}
