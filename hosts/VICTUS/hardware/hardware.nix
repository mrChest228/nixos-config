{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = map (name: self + "/hardware/${name}") [
        "memory.nix"
        "amd-integrated.nix"
        "nvidia-prime.nix"
    ];
}
