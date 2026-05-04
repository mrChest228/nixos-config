{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = map (name: self + "/sys//hardware/${name}") [
        "memory.nix"
        "amd-integrated.nix"
        "nvidia-prime.nix"
    ];
    system.stateVersion = "25.11";
}
