{ config, lib, pkgs, vars, self, ... }:
{
    fileSystems."/" = {
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
    fileSystems."/boot" = { # ESP
        device = "/dev/disk/by-uuid/${vars.UUIDs.esp}";
        fsType = "vfat";
    };

    systemd.tmpfiles.rules = [
        # "d /home/${vars.user}/config      0755 ${vars.user} ${vars.user} - -"
        "d ${self}/host 0755 ${vars.user} ${vars.user} - -"
    ];
    fileSystems."${self}/host" = {
        device = "${self}/hosts/${vars.host}";
        fsType = "none";
        options = [ "bind" ];
    };
    # fileSystems."/home/${vars.user}/.local/share/Trash" = { # Trash big compression
    #     device = "/dev/disk/by-uuid/${vars.UUIDs.root}";
    #     fsType = "btrfs";
    #     options = [
    #         "subvol=@trash"
    #         "noatime"
    #         "compress=zstd:15" # Good compression
    #         "ssd"              # SSD optimizations
    #         "discard=async"    # Async TRIM (hz)
    #         "space_cache=v2"   # Effectieve caching
    #         "autodefrag"
    #     ];
    # };
    
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
