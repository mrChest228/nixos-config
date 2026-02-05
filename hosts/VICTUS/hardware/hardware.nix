{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = map (name: self + "/hardware/${name}") [
        "disks.nix"
        "amd-integrated.nix"
        "nvidia-prime.nix"
    ];
}
