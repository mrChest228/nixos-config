{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = [
        "${self}/hardware/amd-integrated.nix"
        "${self}/hardware/nvidia-prime.nix"
    ];
}
