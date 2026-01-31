{ config, libs, lib, pkgs, vars, self, ... }:
{
    imports = map (name: self + "/hardware/${name}") [
        "amd-integrated.nix"
        "nvidia-prime.nix"
    ];
}
