{ config, lib, pkgs, vars, ... }:
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
    # fileSystems."/home/${vars.userName}/.local/share/Trash" = { # Trash big compression
    #     device = "/dev/disk/by-uuid/${vars.UUIDs.root}";
    #     fsType = "btrfs";
    #     options = [
    #         "subvol=@trash"
    #         "noatime"
    #         "compress=zstd:7" # Better compression
    #         "ssd"             # SSD optimizations
    #         "discard=async"   # Async TRIM (hz)
    #         "space_cache=v2"  # Effectieve caching
    #         "autodefrag"
    #     ];
    # };
    
    # Swap partition
    swapDevices = [{
        device = "/dev/disk/by-uuid/${vars.UUIDs.swap}";
    }];
}
