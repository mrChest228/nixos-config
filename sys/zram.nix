{ config, lib, libs, pkgs, vars, self, ... }:
{
    # RAM compress (zstd)
    zramSwap = { # TODO: lib.mkDefault 100%
        enable = true;
        memoryPercent = 100;
        priority = 999;
    };
}
