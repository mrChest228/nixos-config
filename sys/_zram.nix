{ config, lib, libs, pkgs, vars, self, ... }:
{
    # RAM compress (zstd)
    zramSwap = { # TODO: lib.mkDefault 100% & 16GB max
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 999;
    };
}
