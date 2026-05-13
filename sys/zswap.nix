{ config, lib, pkgs, vars, self, ... }: {
    swapDevices = [{
        device = "/dev/disk/by-uuid/${vars.UUIDs.swap}";
    }];
    boot.zswap = {
        enable = true;
        compressor = "zstd";
        shrinkerEnabled = true;
    };
}
