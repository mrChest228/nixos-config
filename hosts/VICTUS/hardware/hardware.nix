{ config, lib, pkgs, vars, ... }:
{
    imports = [
        /etc/nixos/nixos/hardware/amd-integrated.nix
        /etc/nixos/nixos/hardware/nvidia-prime.nix
        /etc/nixos/nixos/hardware/disks.nix
    ];
}
