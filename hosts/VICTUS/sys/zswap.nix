{ config, lib, pkgs, vars, self, ... }: {
    boot.zswap.maxPoolPercent = 40; # I have only 16GB ddr4
}
