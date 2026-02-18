{ config, lib, pkgs, vars, self, ... }:
{
    fileSystems = {
        "/" = {
            device = "/dev/disk/by-uuid/${vars.UUIDs.root}";
            fsType = "btrfs";
            options = [
                "noatime"
                "compress=zstd:1" # Fast compression
                "ssd"             # SSD optimizations
                "discard=async"   # Async TRIM (hz)
                "space_cache=v2"  # Effectieve caching
                "autodefrag"
            ];
        };
        "/boot" = { # ESP
            device = "/dev/disk/by-uuid/${vars.UUIDs.esp}";
            fsType = "vfat";
        };
        # Bind-mounts
        "${vars.configPath}/host" = {
            device = "${vars.configPath}/hosts/${vars.host}";
            fsType = "none";
            options = [ "bind" ];
        };
    };

    systemd.tmpfiles.rules = [
        "d ${self}/host 0755 ${vars.user} ${vars.user} - -"
        # "d /home/${vars.user}/.local/share/Trash 0700 ${vars.user} ${vars.user} - -"
    ];
    # TODO: trash big compression
    
    # Swap partition
    swapDevices = [{
        device = "/dev/disk/by-uuid/${vars.UUIDs.swap}";
    }];
    boot = {
        kernel.sysctl."vm.swappiness" = 20; # Count of swap using (0..100 value)
        kernelParams = [ "resume=UUID=${vars.UUIDs.swap}" ];
    };

    # Optimizations
    services = {
        fstrim.enable = true;
        btrfs.autoScrub = {
            enable = true;
            interval = "monthly";
        };
    };
    zramSwap = {
        enable = true; # Compress unactive RAM (zstd)
        memoryPercent = 100;
        priority = 999;
    };
}
