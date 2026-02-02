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

    # Symlink from ~/config to /etc/nixos/home-manager
    systemd.tmpfiles.rules = [
        "d /home/${vars.user}/config 0755 ${vars.user} ${vars.user} - -"
        "d /etc/nixos/host 0755 root root - -"
    ];
    fileSystems."/home/${vars.user}/config" = {
        device = "/etc/nixos/home-manager";
        fsType = "none";
        options = [ "bind" ];
    };
    fileSystems."/etc/nixos/host" = {
        device = "/etc/nixos/hosts/${vars.host}";
        fsType = "none";
        options = [ "bind" ];
    };
    # fileSystems."/home/${vars.user}/.local/share/Trash" = { # Trash big compression
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
    boot = {
        kernel.sysctl."vm.swappiness" = 10; # Lower count of swap using (0..100 value)
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
