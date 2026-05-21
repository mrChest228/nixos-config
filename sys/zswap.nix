{ config, lib, pkgs, vars, self, ... }: {
    swapDevices = [{
        device = "/dev/disk/by-partlabel/${vars.host}-swap";
    }];
    boot.zswap = {
        enable = true;
        compressor = "zstd";
        shrinkerEnabled = true;
    };
}
