{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [
        "${self}/nixos/hardware/amd-integrated.nix"
        "${self}/nixos/hardware/nvidia-prime.nix"
    ];
}
