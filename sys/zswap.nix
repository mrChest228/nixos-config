{ config, lib, pkgs, vars, com, cur, ... }: {
    boot.zswap.maxPoolPercent = 40; # I have only 16GB ddr4 (default is 25)
}
