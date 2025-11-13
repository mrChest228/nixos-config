{ config, lib, pkgs, vars, ... }:
{
    imports = [
        ./amd-integrated.nix
        ./disks.nix
        ./nvidia-prime.nix
        ./other.nix
    ];
}
